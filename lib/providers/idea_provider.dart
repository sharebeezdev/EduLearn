import 'package:flutter/material.dart';
import '../databaseutils/db_helper.dart';
import '../models/idea.dart';

class IdeaProvider with ChangeNotifier {
  List<Idea> _ideas = [];

  List<Idea> get ideas => _ideas;

  Future<void> fetchIdeas() async {
    final db = await DBHelper().database;
    debugPrint('Fetching ideas from database...');
    try {
      final ideasData = await db.query('ideas');
      _ideas = ideasData
          .map((e) => Idea(
                id: e['id'] as int,
                title: e['title'] as String,
                description: e['description'] as String,
              ))
          .toList();
      debugPrint('Ideas loaded: $_ideas');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading ideas: $e');
    }
  }
}
