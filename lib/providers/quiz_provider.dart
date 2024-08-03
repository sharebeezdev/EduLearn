import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../databaseutils/db_helper.dart';
import '../models/quiz.dart';
class QuizProvider with ChangeNotifier {
  List<Quiz> _quizzes = [];
  List<Quiz> get quizzes => _quizzes;

  QuizProvider() {
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    final db = await DBHelper().database;
    debugPrint('Fetching quizzes from database...');
    try {
      final List<Map<String, dynamic>> maps = await db.query('quizzes');
      _quizzes = List.generate(maps.length, (i) {
        return Quiz(
          id: maps[i]['id'],
          title: maps[i]['title'],
          description: maps[i]['description'],
          imageUrl: maps[i]['imageUrl'],
        );
      });
      debugPrint('Quizzes loaded: $_quizzes');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading quizzes: $e');
    }
  }
}