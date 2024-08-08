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
    print(
        'Fetching quizzes from database... quizType ' + quizType); // Debug log
    final db = await DBUtilsSQL().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'QuizOverviews',
      where: quizType.isNotEmpty ? 'quizType = ? AND status = ?' : 'status = ?',
      whereArgs:
          quizType.isNotEmpty ? [quizType, 'Not Attempted'] : ['Not Attempted'],
      orderBy: 'creationDate',
      limit: 5,
    );
    print(
        'maps.len quizType ' + maps.length.toString()); // Check length of maps
    _quizzes = List.generate(maps.length, (i) {
      print('Quiz $i: ${maps[i]}'); // Debug log for each quiz
      return Quiz(
        id: maps[i]['quizId'],
        title: maps[i]['quizTitle'],
        description: maps[i]['quizDescription'],
        imageUrl: maps[i]['imageUrl'],
        type: maps[i]['quizType'],
      );
    });

    _currentQuizType = quizType; // Update the current quiz type
    print(
        'Quizzes loaded for type $_currentQuizType: ${_quizzes.length}'); // Check loaded quizzes
    notifyListeners();
  }
}
