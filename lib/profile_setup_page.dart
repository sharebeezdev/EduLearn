import 'package:edu_learn/databaseutils/db_utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseutils/db_helper.dart';
import 'databaseutils/service_helper.dart';
import 'update_profile_page.dart'; // Import the update profile page
import 'subjects_widget.dart';
import 'topics_widget.dart';
import 'trending_topics_widget.dart';

class ProfileSetupPage extends StatefulWidget {
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  List<String> _savedSubjects = [];
  List<String> _savedTopics = [];
  List<String> _trendingTopics = [];
  List<String> _selectedTrendingTopics = [];
  List<String> _selectedSavedTopics = [];
  List<String> _selectedSavedSubjects = [];
  bool _isLoadingSubjects = true;
  bool _isLoadingTopics = true;
  bool _isLoadingTrending = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final db = await DBHelper().database;

    // Load subjects
    final subjectResult = await db.query('subjects');
    print('Loaded subjects: $subjectResult');
    setState(() {
      _savedSubjects = subjectResult.map((e) => e['name'] as String).toList();
      _isLoadingSubjects = false;
    });

    // Load topics
    final topicResult = await db.query('topics');
    print('topics of interest ' + topicResult.toString());
    print('Loaded topics: $topicResult');
    setState(() {
      _savedTopics = topicResult.map((e) => e['title'] as String).toList();
      print('topics of interest ' + topicResult.toString());
      _isLoadingTopics = false;
    });

    // Load trending topics from database
    await _loadTrendingTopicsFromDB();
  }

  Future<void> _loadTrendingTopicsFromDB() async {
    try {
      final db = await DBHelper().database;

      final trendingResult = await db.query('topics_of_interest');
      print('Loaded trending topics from DB: $trendingResult');

      setState(() {
        _trendingTopics =
            trendingResult.map((e) => e['name'] as String).toList();
        _isLoadingTrending = false;
      });
    } catch (error) {
      print('Error loading trending topics from DB: $error');
      setState(() {
        _isLoadingTrending = false;
      });
    }
  }

  Future<void> _loadTrendingTopics() async {
    try {
      final topicsString = _savedTopics.join(', ');
      final subjectsString = _savedSubjects.join(', ');

      print('Fetching trending topics with: $topicsString and $subjectsString');

      final topics = await MyService.fetchTrendingTopics(
        topics: topicsString,
        subjects: subjectsString,
      );

      print('Fetched trending topics: $topics');

      final dbHelper = DBHelper();
      final db = await dbHelper.database;

      // Clear existing trending topics
      await dbHelper.clearTrendingTopics();

      // Insert new trending topics
      for (final topic in topics) {
        await dbHelper.addTrendingTopic(topic);
      }

      // Reload trending topics from database
      await _loadTrendingTopicsFromDB();
    } catch (error) {
      print('Error fetching or saving trending topics: $error');
      setState(() {
        _isLoadingTrending = false;
      });
    }
  }

  void _toggleTrendingTopic(String topic) {
    setState(() {
      if (_selectedTrendingTopics.contains(topic)) {
        _selectedTrendingTopics.remove(topic);
      } else {
        _selectedTrendingTopics.add(topic);
      }
    });
  }

  void _toggleSavedTopic(String topic) {
    setState(() {
      if (_selectedSavedTopics.contains(topic)) {
        _selectedSavedTopics.remove(topic);
      } else {
        _selectedSavedTopics.add(topic);
      }
    });
  }

  void _toggleSavedSubject(String subject) {
    setState(() {
      if (_selectedSavedSubjects.contains(subject)) {
        _selectedSavedSubjects.remove(subject);
      } else {
        _selectedSavedSubjects.add(subject);
      }
    });
  }

  Future<void> _followSelectedTopics() async {
    if (_selectedTrendingTopics.isEmpty) return;

    final db = await DBHelper().database;

    for (var topic in _selectedTrendingTopics) {
      await db.insert('topics_of_interest', {'name': topic},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await _loadSavedData();
    await _loadTrendingTopics();
    setState(() {
      _selectedTrendingTopics.clear();
    });

    await DBUtils().fetchAndSaveQuizzes();
  }

  Future<void> _unfollowSelectedTopics() async {
    if (_selectedSavedTopics.isEmpty) return;

    final db = await DBHelper().database;

    for (var topic in _selectedSavedTopics) {
      await db
          .delete('topics_of_interest', where: 'name = ?', whereArgs: [topic]);
    }

    await _loadSavedData();
    await _loadTrendingTopics();
    setState(() {
      _selectedSavedTopics.clear();
    });
  }

  Future<void> _unfollowSelectedSubjects() async {
    if (_selectedSavedSubjects.isEmpty) return;

    final db = await DBHelper().database;

    for (var subject in _selectedSavedSubjects) {
      await db.delete('subjects', where: 'name = ?', whereArgs: [subject]);
    }

    await _loadSavedData();
    await _loadTrendingTopics();
    setState(() {
      _selectedSavedSubjects.clear();
    });

    await DBUtils().fetchAndSaveQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubjectsWidget(
              savedSubjects: _savedSubjects,
              isLoading: _isLoadingSubjects,
              selectedSubjects: _selectedSavedSubjects,
              onToggle: _toggleSavedSubject,
              onUnfollow: _unfollowSelectedSubjects,
            ),
            TopicsWidget(
              savedTopics: _savedTopics,
              isLoading: _isLoadingTopics,
              selectedTopics: _selectedSavedTopics,
              onToggle: _toggleSavedTopic,
              onUnfollow: _unfollowSelectedTopics,
            ),
            TrendingTopicsWidget(
              trendingTopics: _trendingTopics,
              isLoading: _isLoadingTrending,
              selectedTopics: _selectedTrendingTopics,
              onToggle: _toggleTrendingTopic,
              onFollow: _followSelectedTopics,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: 5,
              min: 1,
              max: 10,
              divisions: 9,
              label: '5',
              onChanged: (value) {},
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Explore'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
