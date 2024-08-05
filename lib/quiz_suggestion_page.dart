import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../databaseutils/db_helper.dart';
import '../models/quiz.dart';
import '../models/quiz_overview.dart'; // Import the new class
import '../widgets/quiz_card.dart';

class QuizSuggestionsWidget extends StatefulWidget {
  @override
  _QuizSuggestionsWidgetState createState() => _QuizSuggestionsWidgetState();
}

class _QuizSuggestionsWidgetState extends State<QuizSuggestionsWidget> {
  List<Quiz> topicQuizzes = [];
  List<Quiz> subjectQuizzes = [];
  List<Quiz> historicalDataQuizzes = [];

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    final db = await DBHelper().database;

    // Fetch quizzes from QuizOverviews table based on type
    final List<Map<String, dynamic>> topics = await db
        .query('QuizOverviews', where: 'quizType = ?', whereArgs: ['topics']);
    print('topics quizes are ' + topics.length.toString());
    final List<Map<String, dynamic>> subjects = await db
        .query('QuizOverviews', where: 'quizType = ?', whereArgs: ['subjects']);
    print('subjects quizes are ' + topics.length.toString());
    final List<Map<String, dynamic>> historicalData = await db.query(
        'QuizOverviews',
        where: 'quizType = ?',
        whereArgs: ['trending_topics']);

    // Print the raw data fetched from the database
    print('Fetched topics quizzes: $topics');
    print('Fetched subjects quizzes: $subjects');
    print('Fetched historical data quizzes: $historicalData');

    // Convert maps to QuizOverview objects
    List<QuizOverview> topicQuizOverviews =
        topics.map((map) => QuizOverview.fromMap(map)).toList();
    List<QuizOverview> subjectQuizOverviews =
        subjects.map((map) => QuizOverview.fromMap(map)).toList();
    List<QuizOverview> historicalDataQuizOverviews =
        historicalData.map((map) => QuizOverview.fromMap(map)).toList();

    // Print the converted QuizOverview objects
    print('Topic QuizOverviews: $topicQuizOverviews');
    print('Subject QuizOverviews: $subjectQuizOverviews');
    print('Historical Data QuizOverviews: $historicalDataQuizOverviews');

    // Convert QuizOverview objects to Quiz objects
    topicQuizzes = topicQuizOverviews
        .map((overview) => Quiz(
            id: overview.quizId,
            title: overview.quizTitle,
            description: overview.quizDescription,
            imageUrl: overview.imageUrl,
            type: overview.quizType
            // Add other necessary fields here
            ))
        .toList();

    subjectQuizzes = subjectQuizOverviews
        .map((overview) => Quiz(
            id: overview.quizId,
            title: overview.quizTitle,
            description: overview.quizDescription,
            imageUrl: overview.imageUrl,
            type: overview.quizType
            // Add other necessary fields here
            ))
        .toList();

    historicalDataQuizzes = historicalDataQuizOverviews
        .map((overview) => Quiz(
            id: overview.quizId,
            title: overview.quizTitle,
            description: overview.quizDescription,
            imageUrl: overview.imageUrl,
            type: overview.quizType
            // Add other necessary fields here
            ))
        .toList();

    // Print the converted Quiz objects
    print('Topic Quizzes: $topicQuizzes');
    print('Subject Quizzes: $subjectQuizzes');
    print('Historical Data Quizzes: $historicalDataQuizzes');

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topicQuizzes.isNotEmpty) ...[
          Text('Quizzes: Topics of Interest',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topicQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = topicQuizzes[index];
                return QuizCard(quiz: quiz);
              },
            ),
          ),
          SizedBox(height: 16),
        ],
        if (subjectQuizzes.isNotEmpty) ...[
          Text('Quizzes: Favorite Subjects',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subjectQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = subjectQuizzes[index];
                return QuizCard(quiz: quiz);
              },
            ),
          ),
          SizedBox(height: 16),
        ],
        if (historicalDataQuizzes.isNotEmpty) ...[
          Text('Quizzes: Based on Historical Data',
              style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: historicalDataQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = historicalDataQuizzes[index];
                return QuizCard(quiz: quiz);
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ],
    );
  }
}
