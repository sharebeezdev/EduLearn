import 'package:flutter/material.dart';
import '../databaseutils/db_helper.dart';
import '../models/topic.dart';

class TopicProvider with ChangeNotifier {
  List<Topic> _topics = [];

  List<Topic> get topics => _topics;

  Future<void> fetchTopics() async {
    final db = await DBHelper().database;
    debugPrint('Fetching topics from database...');
    try {
      final topicsData = await db.query('topics');
      _topics = topicsData
          .map((e) => Topic(
                id: e['id'] as int,
                title: e['title'] as String,
                description: e['description'] as String,
              ))
          .toList();
      debugPrint('Topics loaded: $_topics');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading topics: $e');
    }
  }
}
