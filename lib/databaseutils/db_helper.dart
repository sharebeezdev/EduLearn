import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quiz_question.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'edu_learn.db');
    debugPrint('Initializing database at path: $path');
    return await openDatabase(
      path,
      version: 8, // Increment the version number for schema changes
      onCreate: (db, version) async {
        await _createDB(db);
        await _loadInitialDataIfNotExists(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await _upgradeDB(db, oldVersion, newVersion);
        }
      },
    );
  }

  Future<void> _createDB(Database db) async {
    debugPrint('Creating database tables...');

    final tables = [
      'quizzes',
      'ideas',
      'topics',
      'subjects',
      'topics_of_interest',
      'historical_exams',
      'QuizOverviews',
      'MyTopicsQuizzes',
      'MySubjectQuizzes',
      'MyHistoricalDataQuizzes',
      'FeaturedQuizzes',
      'QuizScores',
      'metadata',
      'trending_topics',
      'ScoreDetails' // Add the new table to the list
    ];

    for (var table in tables) {
      final count = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT COUNT(*) FROM sqlite_master WHERE type = "table" AND name = ?',
              [table])) ??
          0;

      if (count == 0) {
        switch (table) {
          case 'quizzes':
            await db.execute('''CREATE TABLE quizzes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              imageUrl TEXT
            )''');
            break;
          case 'ideas':
            await db.execute('''CREATE TABLE ideas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT
            )''');
            break;
          case 'topics':
            await db.execute('''CREATE TABLE topics (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT
            )''');
            break;
          case 'subjects':
            await db.execute('''CREATE TABLE subjects (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )''');
            break;
          case 'topics_of_interest':
            await db.execute('''CREATE TABLE topics_of_interest (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )''');
            break;
          case 'historical_exams':
            await db.execute('''CREATE TABLE historical_exams (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              examName TEXT,
              examDate TEXT,
              subject TEXT,
              marks INTEGER,
              totalMarks INTEGER
            )''');
            break;
          case 'QuizOverviews':
            await db.execute('''CREATE TABLE QuizOverviews (
              quizId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizTitle TEXT,
              quizDescription TEXT,
              quizType TEXT,
              imageUrl TEXT,
              status TEXT DEFAULT 'Not Attempted',
              creationDate TEXT,
              attemptedDate TEXT,
              quizScore REAL
            )''');
            break;
          case 'MyTopicsQuizzes':
            await db.execute('''CREATE TABLE MyTopicsQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'MySubjectQuizzes':
            await db.execute('''CREATE TABLE MySubjectQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'MyHistoricalDataQuizzes':
            await db.execute('''CREATE TABLE MyHistoricalDataQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'FeaturedQuizzes':
            await db.execute('''CREATE TABLE FeaturedQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'QuizScores':
            await db.execute('''CREATE TABLE QuizScores (
              scoreId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              attemptedDate TEXT,
              percentageScored REAL
            )''');
            break;
          case 'ScoreDetails': // Create the new table
            await db.execute('''CREATE TABLE ScoreDetails (
              scoreId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              attemptedDate TEXT,
              percentageScored REAL
            )''');
            break;
          case 'metadata':
            await db.execute('''CREATE TABLE metadata (
              key TEXT PRIMARY KEY,
              value TEXT
            )''');
            break;
          case 'trending_topics':
            await db.execute('''CREATE TABLE trending_topics (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              topic TEXT
            )''');
            break;
        }
      }
    }

    debugPrint('Database tables created successfully.');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion...');

    if (oldVersion < 8) {
      debugPrint('Adding ScoreDetails table...');
      await db.execute('''CREATE TABLE IF NOT EXISTS ScoreDetails (
        scoreId INTEGER PRIMARY KEY AUTOINCREMENT,
        quizId INTEGER,
        attemptedDate TEXT,
        percentageScored REAL
      )''');
    }

    debugPrint('Database upgraded successfully.');
  }

  Future<void> _loadInitialDataIfNotExists(Database db) async {
    debugPrint('Checking if initial data is loaded...');
    final result = await db.query('metadata',
        where: 'key = ?', whereArgs: ['initial_data_loaded']);
    if (result.isEmpty) {
      debugPrint('Loading initial data from JSON');
      final String data =
          await rootBundle.loadString('assets/initial_data.json');
      final Map<String, dynamic> jsonData = json.decode(data);

      for (var quiz in jsonData['quizzes']) {
        await db.insert('quizzes', quiz);
      }
      for (var idea in jsonData['ideas']) {
        await db.insert('ideas', idea);
      }
      for (var topic in jsonData['topics']) {
        await db.insert('topics', topic);
      }

      await db
          .insert('metadata', {'key': 'initial_data_loaded', 'value': 'true'});
      debugPrint('Initial data loaded successfully');
    } else {
      debugPrint('Initial data already loaded');
    }
  }

  Future<void> addTrendingTopic(String topic) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM trending_topics')) ??
        0;
    if (count >= 10) {
      await db.delete('trending_topics',
          where: 'id = (SELECT MIN(id) FROM trending_topics)');
    }
    await db.insert('trending_topics', {'topic': topic});
  }

  Future<List<String>> getTrendingTopics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('trending_topics', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return maps[i]['topic'];
    });
  }

  Future<void> clearTrendingTopics() async {
    final db = await database;
    await db.delete('trending_topics');
  }

  Future<void> addMyTopicsQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('MyTopicsQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getMyTopicsQuizzes() async {
    final db = await database;
    return await db.query('MyTopicsQuizzes');
  }

  Future<void> addMySubjectQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('MySubjectQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getMySubjectQuizzes() async {
    final db = await database;
    return await db.query('MySubjectQuizzes');
  }

  Future<void> addMyHistoricalDataQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('MyHistoricalDataQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getMyHistoricalDataQuizzes() async {
    final db = await database;
    return await db.query('MyHistoricalDataQuizzes');
  }

  Future addFeaturedQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('FeaturedQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getFeaturedQuizzes() async {
    final db = await database;
    return await db.query('FeaturedQuizzes');
  }

// Additional methods for ScoreDetails
  Future addScoreDetail(Map<String, dynamic> scoreDetail) async {
    final db = await database;
    await db.insert('ScoreDetails', scoreDetail);
  }

  Future<List<Map<String, dynamic>>> getScoreDetails() async {
    final db = await database;
    return await db.query('ScoreDetails');
  }

  Future insertQuizScore(Map<String, dynamic> score) async {
    final db = await database;
    await db.insert('QuizScores', score);
  }

  Future<List<Map<String, dynamic>>> getQuizScores() async {
    final db = await database;
    return await db.query('QuizScores');
  }

  Future addQuizScore(Map<String, dynamic> score) async {
    final db = await database;
    await db.insert('QuizScores', score);
  }

  Future<void> fetchAndSaveQuizzes() async {
    final db = await database;

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

      List<String> instructions = [
        'Generate multiple choice quiz related to user interested $type and the $type are: ${names.join(', ')}',
        'Generate 5 different quizzes and each quiz contains a maximum of 10 questions.',
        'The response should contain quizTitle, quizDescription, imageURL (any image from web), questionText, multiple choices, correct choice, reason why correct choice, and any list of links to learn more.'
      ];

      // Construct the request payload
      final requestPayload = {
        "instructions": instructions,
      };
      final String requestPayloadJson = jsonEncode(requestPayload);
      // Log the request data
      print(
          'Generated Request Data for $type: ${json.encode(requestPayloadJson)}');

      final String apiUrl =
          'https://google-gemini-hackathon.onrender.com/gemini?promt=${Uri.encodeComponent(requestPayloadJson)}';
      print('API URL: $apiUrl');
      final response = await http.get(Uri.parse(apiUrl));

      // Log the response status code
      print('Response Status Code for $type: ${response.statusCode}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          final data = jsonDecode(response.body);
          print('Received JSON data: $data');
          parseQuizResponse(data);
        } else {
          // Handle plain text response
          String responseText = response.body;
          //  print('Received plain text response: $responseText');
          await parsePlainTextResponse(responseText, type);
        }
      }
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
    final db = await database;
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

      for (var question in questions) {
        question['quizId'] = quizId;
        await db.insert('MyTopicsQuizzes', question);
        print('Inserted Question: $question for Quiz ID $quizId');
      }
      print(
          'Total questions inserted for Quiz ID $quizId: ${questions.length}');
    }
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(
      String quizId, String quizType) async {
    final db = await database;
    String tableName;

    if (quizType == 'topics') {
      tableName = 'MyTopicsQuizzes';
    } else if (quizType == 'subjects') {
      tableName = 'MySubjectQuizzes';
    } else if (quizType == 'trending_topics') {
      tableName = 'FeaturedQuizzes';
    } else {
      throw Exception('Invalid quiz type');
    }

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
  ) async {
    final db = await database;
    await db.insert(
      'QuizScores',
      {
        'quizId': quizId,
        'attemptedDate': DateTime.now().toIso8601String(),
        'percentageScored': score,
      },
    );
    // Navigate to results page or show results
  }
}
