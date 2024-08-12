import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/quiz_question.dart';
import 'db_helper.dart';

class DBUtils {
  Future<bool> isSurveyCompleted() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'metadata', // Table name for storing metadata
      where: 'key = ?',
      whereArgs: ['surveyCompleted'],
    );
    if (result.isNotEmpty && result.first['value'] == 'true') {
      return true;
    }
    return false;
  }

  Future<void> setSurveyCompleted() async {
    final db = await DBHelper().database;
    await db.insert(
      'metadata', // Table name for storing metadata
      {'key': 'surveyCompleted', 'value': 'true'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> fetchAndSaveQuizzes() async {
    final db = await DBHelper().database;

    // Fetch topics, subjects, and trending topics from the database
    final List<Map<String, dynamic>> topics = await db.query('topics');
    final List<Map<String, dynamic>> subjects = await db.query('subjects');
    final List<Map<String, dynamic>> trendingTopics =
        await db.query('trending_topics');

    final List<String> topicNames =
        topics.map((topic) => topic['title'] as String).toList();
    final List<String> subjectNames =
        subjects.map((subject) => subject['name'] as String).toList();
    final List<String> trendingTopicNames = trendingTopics
        .map((trendingTopic) => trendingTopic['topic'] as String)
        .toList();

    // Log the retrieved data
    print('Retrieved Topics: $topicNames');
    print('Retrieved Subjects: $subjectNames');
    print('Retrieved Trending Topics: $trendingTopicNames');

    // Helper function to call API and save quizzes
    Future<void> callApiAndSaveQuizzes(String type, List<String> names) async {
      if (names.isEmpty) {
        print('No $type available, skipping API call for $type.');
        return;
      }
      print(
          '****************************************************************************');
      print('Generating Quizzes for $type. start');
      List<String> instructions = [
        'Generate multiple choice quiz related to user interested $type and the $type are: ${names.join(', ')}',
        'Generate 5 different quizzes and each topic contains a maximum of 10 questions.',
        'The response should contain quizTitle, quizDescription, imageURL (any image from web), questionText, multiple choices, correct choice, reason why correct choice, and any list of links to learn more.'
      ];

      // Construct the request payload
      final requestPayload = {
        "instructions": instructions,
      };
      final String requestPayloadJson = jsonEncode(requestPayload);

      final String apiUrl =
          'https://google-gemini-hackathon.onrender.com/gemini?promt=${Uri.encodeComponent(requestPayloadJson)}';
      print('API URL: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));

      // Log the response status code
      print(
          'Response Status Code for quizzes for $type: ${response.statusCode}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          final data = jsonDecode(response.body);
          parseQuizResponse(data);
        } else {
          // Handle plain text response
          String responseText = response.body;
          //  print('Received plain text response: $responseText');
          await parsePlainTextResponse(responseText, type);
        }
      }
      print(
          '****************************************************************************');
      print('Generating Quizzes for $type. End');
    }

    // Process topics
    await callApiAndSaveQuizzes('topics', topicNames);

    // Process subjects
    await callApiAndSaveQuizzes('subjects', subjectNames);

    // Process trending topics
    await callApiAndSaveQuizzes('trending_topics', trendingTopicNames);
  }

  void parseQuizResponse(dynamic data) {
    // Parse the JSON response and create a list of QuizQuestion objects.
    for (var item in data) {
      print('Parsed questions: $item');
    }
  }

  Future<void> parsePlainTextResponse(String responseText, String type) async {
    print(
        '****************************************************************************');
    print('parsePlainTextResponse Quizzes for $type. Start');
    final db = await DBHelper().database;
    List<String> lines = responseText.split('\n');
    String quizTitle = '';
    String quizDescription = '';
    String imageURL = '';
    int questionNumber = 0;
    List<Map<String, dynamic>> questions = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.startsWith('## Quiz')) {
        if (quizTitle.isNotEmpty) {
          // Save the previous quiz and its questions
          final quizOverview = {
            'quizTitle': quizTitle,
            'quizDescription': quizDescription,
            'quizType': type,
            'imageUrl': imageURL,
            'status': 'Not Attempted',
            'creationDate': DateTime.now().toIso8601String()
          };
          final quizId = await db.insert('QuizOverviews', quizOverview);
          print('Inserted Quiz Overview: $quizOverview with ID $quizId');

          for (var question in questions) {
            question['quizId'] = quizId;
            await db.insert('MyTopicsQuizzes', question);
            print('Inserted Question: $question for Quiz ID $quizId');
          }
          print(
              'Total questions inserted for Quiz ID $quizId: ${questions.length}');
        }

        // Start a new quiz
        quizTitle = '';
        quizDescription = '';
        imageURL = '';
        questionNumber = 0;
        questions = [];
        continue;
      }

      if (line.startsWith('**quizTitle:**')) {
        quizTitle = line.replaceFirst('**quizTitle:**', '').trim();
        print('Parsed quizTitle: $quizTitle');
      } else if (line.startsWith('**quizDescription:**')) {
        quizDescription = line.replaceFirst('**quizDescription:**', '').trim();
        print('Parsed quizDescription: $quizDescription');
      } else if (line.startsWith('**imageURL:**')) {
        imageURL = line.replaceFirst('**imageURL:**', '').trim();
        print('Parsed imageURL: $imageURL');
      } else if (line.startsWith('**Question')) {
        questionNumber++;
        Map<String, dynamic> question = {
          'questionNumber': questionNumber,
        };
        questions.add(question);
        print('Started new Question $questionNumber');
      } else if (line.startsWith('**questionText:**')) {
        if (questions.isNotEmpty) {
          questions.last['questionText'] =
              line.replaceFirst('**questionText:**', '').trim();
          print('Parsed questionText: ${questions.last['questionText']}');
        } else {
          print(
              'Warning: Question text found without a preceding question header.');
        }
      } else if (line.startsWith('**multipleChoices:**')) {
        if (questions.isNotEmpty) {
          List<String> choices = [];
          while (++i < lines.length && lines[i].trim().startsWith('*')) {
            choices.add(lines[i].trim().replaceFirst('*', '').trim());
          }
          print('saving choices as ');
          print(choices.toString());
          questions.last['choices'] = jsonEncode(choices);
          print('Parsed multipleChoices: $choices');
          i--;
        } else {
          print(
              'Warning: Multiple choices found without a preceding question header.');
        }
      } else if (line.startsWith('**correctChoice:**')) {
        if (questions.isNotEmpty) {
          questions.last['correctChoice'] =
              line.replaceFirst('**correctChoice:**', '').trim();
          print('Parsed correctChoice: ${questions.last['correctChoice']}');
        } else {
          print(
              'Warning: Correct choice found without a preceding question header.');
        }
      } else if (line.startsWith('**reasonWhyCorrectChoice:**')) {
        if (questions.isNotEmpty) {
          questions.last['reason'] =
              line.replaceFirst('**reasonWhyCorrectChoice:**', '').trim();
          print('Parsed reasonWhyCorrectChoice: ${questions.last['reason']}');
        } else {
          print('Warning: Reason found without a preceding question header.');
        }
      } else if (line.startsWith('**linksToLearnMore:**')) {
        if (questions.isNotEmpty) {
          List<String> links = [];
          while (++i < lines.length && lines[i].trim().startsWith('*')) {
            links.add(lines[i].trim().replaceFirst('*', '').trim());
          }
          questions.last['links'] = jsonEncode(links);
          print('Parsed linksToLearnMore: $links');
          i--;
        } else {
          print('Warning: Links found without a preceding question header.');
        }
      }
    }

    // Save the last quiz and its questions
    if (quizTitle.isNotEmpty) {
      final quizOverview = {
        'quizTitle': quizTitle,
        'quizDescription': quizDescription,
        'quizType': type,
        'imageUrl': imageURL,
        'status': 'Not Attempted',
        'creationDate': DateTime.now().toIso8601String()
      };
      final quizId = await db.insert('QuizOverviews', quizOverview);
      print('Inserted Quiz Overview: $quizOverview with ID $quizId');

      String questionsTable;
      if (type == 'topics') {
        questionsTable = 'MyTopicsQuizzes';
      } else if (type == 'subjects') {
        questionsTable = 'MySubjectQuizzes';
      } else {
        questionsTable = 'FeaturedQuizzes';
      }

      for (var question in questions) {
        question['quizId'] = quizId;
        await db.insert(questionsTable, question);
        print('Inserted Question: $question for Quiz ID $quizId');
      }
      print(
          'Total questions inserted for Quiz ID $quizId: ${questions.length}');

      // if (questions.isEmpty) {
      //   await db.delete('QuizOverviews', where: 'id = ?', whereArgs: [quizId]);
      //   print('Deleted Quiz Overview with ID $quizId due to no questions.');
      // }
    }

    print(
        '****************************************************************************');
    print('parsePlainTextResponse Quizzes for $type. End');
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(
      String quizId, String quizType) async {
    final db = await DBHelper().database;
    String tableName = 'QuizzQuestions';

    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'quizId = ?',
      whereArgs: [quizId],
      orderBy: 'questionNumber',
    );

    return List.generate(maps.length, (i) {
      return QuizQuestion.fromMap(maps[i]);
    });
  }

  Future<void> insertQuizScoreDetails(
    double score,
    String quizId,
    String topicName,
  ) async {
    final db = await DBHelper().database;
    await db.insert(
      'QuizScores',
      {
        'quizId': quizId,
        'attemptedDate': DateTime.now().toIso8601String(),
        'percentageScored': score,
        'topicName': topicName
      },
    );
    // Navigate to results page or show results
  }

  Future<void> insertSurveyData(Map<String, String> data) async {
    final db = await DBHelper().database;
    await db.insert(
      'survey_data',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSubject(Map<String, String> subject) async {
    final db = await DBHelper().database;
    await db.insert(
      'subjects',
      subject,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTopicOfInterest(Map<String, String> subject) async {
    final db = await DBHelper().database;
    await db.insert(
      'topics_of_interest',
      subject,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTopic(Map<String, String> topic) async {
    final db = await DBHelper().database;
    await db.insert(
      'topics',
      topic,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTrendingTopic(Map<String, String> topic) async {
    final db = await DBHelper().database;
    await db.insert(
      'trending_topics',
      topic,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearSubjects() async {
    final db = await DBHelper().database;
    await db
        .delete('subjects'); // Replace 'MySubjects' with your actual table name
  }

  Future<void> clearTopics() async {
    final db = await DBHelper().database;
    await db.delete('topics'); // Replace 'MyTopics' with your actual table name
  }

  Future<void> clearTopicsOfInterest() async {
    final db = await DBHelper().database;
    await db.delete(
        'trending_topics'); // Replace 'MyTopics' with your actual table name
  }

  Future<void> insertQuizzes(String jsonResponse, String topicType) async {
    final db = await DBHelper().database;

    // List of default image URLs
    final List<String> defaultImageUrls = [
      'https://cdn.neurosys.com/wp-content/webp-express/webp-images/uploads/2023/11/what-is-deep-learning.jpg.webp',
      'https://www.nttdata.com/sg/en/-/media/nttdataapac/ndsg/services/big-data-solutions/big-data-platform/services-bigdata-bigdataplatform-header-2732x1536.jpg?h=1536&iar=0&w=2732&rev=d8893d309b9c402a80f232077e738fed',
      'https://website-assets-fw.freshworks.com/attachments/ck340ov180hsy65g0yxb6gbhb-1-chatbots-for-marketing-smm.one-half.png',
      'https://bernardmarr.com/wp-content/uploads/2023/07/Quantum-Computing_-What-Every-CEO-Needs-to-Know.jpg',
      'https://wellsaidlabs.com/wp-content/uploads/2023/09/blog_ai-ethics-1024x576.jpg',
      'https://cdn.educba.com/academy/wp-content/uploads/2019/08/What-is-supervised-learning.jpg',
      'https://www.cwstechnology.com/wp-content/uploads/2024/05/natural-language-processing.jpg',
      'https://media.licdn.com/dms/image/D5612AQGDKhZPs-jXMw/article-cover_image-shrink_720_1280/0/1701959179280?e=1728518400&v=beta&t=juGFhD4bqV7P5VoWpUOAl3LvBckN77CRZx7mVzeTclI',
      'https://www.spiceworks.com/wp-content/uploads/2022/01/Main-Components-of-a-Distributed-System.png',
      'https://justtotaltech.com/wp-content/uploads/2021/04/JTT-Top-11-Data-Mining-Techniques-of-2021-1-1.png',
      'https://imageio.forbes.com/specials-images/imageserve/642bc7aea9b99c12f3deb166/0x0.jpg?format=jpg&height=900&width=1600&fit=bounds'
    ];

    Future<String> getValidImageUrl(String imageUrl) async {
      if (imageUrl == null ||
          imageUrl.isEmpty ||
          !(imageUrl.endsWith('.jpg') ||
              imageUrl.endsWith('.png') ||
              imageUrl.endsWith('.jpeg'))) {
        // Return a random default URL if the provided URL is null, empty, or does not end with .jpg, .png, or .jpeg
        return (defaultImageUrls..shuffle()).first;
      }

      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200 &&
            response.headers['content-type']?.startsWith('image/') == true) {
          return imageUrl;
        } else {
          // Return a random default URL if the image URL is invalid
          return (defaultImageUrls..shuffle()).first;
        }
      } catch (e) {
        // Return a random default URL if any error occurs during validation
        return (defaultImageUrls..shuffle()).first;
      }
    }

    try {
      // Decode the JSON response
      final Map<String, dynamic> data = json.decode(jsonResponse);
      final List<dynamic> quizOverviews = data['QuizOverviews'];

      for (var i = 0; i < quizOverviews.length && i < 3; i++) {
        var quiz = quizOverviews[i];

        try {
          // Validate the image URL
          final validImageUrl = await getValidImageUrl(quiz['imageUrl']);

          // Insert into QuizOverviews table
          final quizId = await db.insert(
            'QuizOverviews',
            {
              'quizTitle': quiz['quizTitle'],
              'quizDescription': quiz['quizDescription'],
              'quizType': topicType,
              'topicName': quiz['topicName'],
              'imageUrl':
                  validImageUrl, // Use the validated or default image URL
              'creationDate': DateTime.now().toIso8601String(),
              'status': 'Not Attempted',
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          print('quz over');
          // Insert questions into QuizzQuestions table
          final List<dynamic> questions = quiz['questions'];
          for (var question in questions) {
            try {
              await db.insert(
                'QuizzQuestions',
                {
                  'quizId': quizId,
                  'questionNumber': question['questionNumber'],
                  'questionText': question['questionText'],
                  'choices': json.encode(question['choices']),
                  'correctChoice': question['correctChoice'],
                  'reason': question['reason'],
                  'links': json.encode(question['links'] ?? []),
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            } catch (questionError) {
              print(
                  'Error inserting question ${question['questionText']} for quiz ${quiz['quizTitle']}: $questionError');
            }
          }
        } catch (quizError) {
          print('Error inserting quiz ${quiz['quizTitle']}: $quizError');
        }
      }
    } catch (e) {
      print('Error processing quiz data: $e');
    }
  }

  Future<void> insertLearningPathData(String jsonResponse) async {
    final db = await DBHelper().database;
    try {
      // Parse the JSON response
      final Map<String, dynamic> data = jsonDecode(jsonResponse);
      print('Inserting learning path for title ${data['title']}');
      // Extract title and brief description
      final String title = data['title'];
      final String description = data['briefDescription'];

      // Insert data into learningPathOverviews
      final int lpId = await db.insert(
        'learningPathOverviews',
        {
          'title': title,
          'description': description,
          'creationDate': DateTime.now().toIso8601String(),
          'status': 'Not Attempted',
        },
      );

      // Extract learning path steps
      final List<dynamic> steps = data['learningPath'];

      // Insert each step into learningPathSteps with seqNumber
      int seqNumber = 1;
      for (final step in steps) {
        await db.insert(
          'learningPathSteps',
          {
            'lpId': lpId,
            'seqNumber': seqNumber,
            'topicTitle': step['topicTitle'],
            'topicBrief': step['topicBrief'],
            'links': step['link'],
          },
        );
        seqNumber++;
      }
    } catch (e) {
      print('Error inserting learning path data: $e');
      // Handle any errors that occur during the insertion
    }
  }

  Future<String> createJsonRequestBody() async {
    final db = await DBHelper().database;

    // Extracting data from QuizScores table
    final List<Map<String, dynamic>> quizScores = await db.query('QuizScores');

    // Extracting data from SurveyData table
    final List<Map<String, dynamic>> surveyData = await db.query('SurveyData');

    // Extracting data from exam_scores table
    final List<Map<String, dynamic>> examScores = await db.query('exam_scores');

    // Extracting data from project_grades table
    final List<Map<String, dynamic>> projectGrades =
        await db.query('project_grades');

    // Extracting data from teacher_feedback table
    final List<Map<String, dynamic>> teacherFeedback =
        await db.query('teacher_feedback');

    // Extracting data from topics table
    final List<Map<String, dynamic>> topics = await db.query('topics');

    // Extracting data from subjects table
    final List<Map<String, dynamic>> subjects = await db.query('subjects');

    // Creating a JSON object by combining the extracted data
    final Map<String, dynamic> requestBody = {
      'quizScores': quizScores,
      'surveyData': surveyData,
      'examScores': examScores,
      'projectGrades': projectGrades,
      'teacherFeedback': teacherFeedback,
      'topics': topics,
      'subjects': subjects,
    };

    // Convert the JSON object to a string
    String jsonString = jsonEncode(requestBody);

    // Return the JSON string to be used as the request body
    return jsonString;
  }
}
