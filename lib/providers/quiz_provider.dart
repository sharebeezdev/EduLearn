import 'package:flutter/material.dart';
import '../models/quiz.dart';
import 'package:edu_learn/databaseutils/dbutils_sql.dart';

class QuizProvider with ChangeNotifier {
  List<Quiz> _quizzes = [];
  String _currentQuizType = '';

  List<Quiz> get quizzes => _quizzes;

  Future<void> fetchQuizzes({String quizType = ''}) async {
    if (_currentQuizType == quizType) {
      // Prevent fetching the same type again
      return;
    }

    final db = await DBUtilsSQL().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'QuizOverviews',
      where: quizType.isNotEmpty ? 'quizType = ? AND status = ?' : 'status = ?',
      whereArgs:
          quizType.isNotEmpty ? [quizType, 'Not Attempted'] : ['Not Attempted'],
      orderBy: 'creationDate',
      limit: 5, // Fetch all if fetchAll is true
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

    _currentQuizType = quizType; // Update the current quiz type
    notifyListeners();
  }
}
