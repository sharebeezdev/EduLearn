import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../databaseutils/db_utils.dart';
import '../models/quiz.dart';
import '../databaseutils/dbutils_sql.dart';

class TrendingTopicProvider with ChangeNotifier {
  List<Quiz> _quizzes = [];

  List<Quiz> get quizzes => _quizzes;

  Future<void> fetchQuizzes() async {
    final db = await DBUtilsSQL().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'QuizOverviews',
      where: 'status = ?',
      whereArgs: ['Not Attempted'],
      orderBy: 'quizId ASC, creationDate ASC',
      limit: 5,
    );
    _quizzes = List.generate(maps.length, (i) {
      return Quiz(
        id: maps[i]['quizId'],
        title: maps[i]['quizTitle'],
        description: maps[i]['quizDescription'],
        imageUrl: maps[i]['imageUrl'],
        type: maps[i]['quizType'],
        topicName: maps[i]['topicName'],
      );
    });
    notifyListeners();
  }
}
