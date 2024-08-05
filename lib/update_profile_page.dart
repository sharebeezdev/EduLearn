import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for loading assets
import 'package:sqflite/sqflite.dart';
import 'databaseutils/db_helper.dart';
import 'databaseutils/db_utils.dart';
import 'models/exam_data.dart';
import 'databaseutils/service_helper.dart';
import 'widgets/exam_data_chart.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  List<String> _subjects = [];
  List<String> _topics = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadHistoricalData(); // Load historical data on initialization
  }

  Future<void> _loadInitialData() async {
    final db = await DBHelper().database;
    final subjectResult = await db.query('subjects');
    final topicResult = await db.query('topics_of_interest');

    setState(() {
      _subjects = subjectResult.map((e) => e['name'] as String).toList();
      _topics = topicResult.map((e) => e['name'] as String).toList();
    });
  }

  Future<void> _loadHistoricalData() async {
    // Commenting out file picker code and adding asset loading code
    // final result = await FilePicker.platform
    //     .pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    // if (result == null) return;

    // final file = File(result.files.single.path!);
    // final jsonString = await file.readAsString();

    // Load JSON data from assets
    final jsonString = await rootBundle.loadString('assets/exams_data.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);

    final examDataList =
        jsonData.map((data) => ExamData.fromJson(data)).toList();

    final db = await DBHelper().database;
    await db.delete('historical_exams'); // Clear existing data
    for (var examData in examDataList) {
      await db.insert('historical_exams', examData.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    setState(() {});
  }

  Future<void> _addSubject() async {
    final db = await DBHelper().database;
    await db.insert('subjects', {'name': _subjectController.text});
    setState(() {
      _subjects.add(_subjectController.text);
      _subjectController.clear();
    });
  }

  Future<void> _addTopic() async {
    final db = await DBHelper().database;
    await db.insert('topics_of_interest', {'name': _topicController.text});
    setState(() {
      _topics.add(_topicController.text);
      _topicController.clear();
    });
  }

  Future<void> _saveData() async {
    final db = await DBHelper().database;

    await db.delete('subjects');
    await db.delete('topics_of_interest');

    for (var subject in _subjects) {
      await db.insert('subjects', {'name': subject});
    }
    for (var topic in _topics) {
      await db.insert('topics_of_interest', {'name': topic});
    }

    final topicsString = _topics.join(', ');
    final subjectsString = _subjects.join(', ');

    final topics = await MyService.fetchTrendingTopics(
      topics: topicsString,
      subjects: subjectsString,
    );

    // Clear existing trending topics
    await DBHelper().clearTrendingTopics();

    // Insert new trending topics
    for (final topic in topics) {
      await DBHelper().addTrendingTopic(topic);
    }

    await DBUtils().fetchAndSaveQuizzes();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );

    Navigator.pop(context);
  }

  Future<List<ExamData>> _fetchHistoricalData() async {
    final db = await DBHelper().database;
    final examDataList = await db.query('historical_exams');
    return examDataList.map((data) => ExamData.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Interested Subjects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: _subjects
                  .map((subject) => Chip(label: Text(subject)))
                  .toList(),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Add new subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addSubject,
              child: const Text('Add Subject'),
            ),
            const SizedBox(height: 32.0),
            const Text('Topics Of Interest',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children:
                  _topics.map((topic) => Chip(label: Text(topic))).toList(),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Add new topic',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addTopic,
              child: const Text('Add Topic'),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: _saveData,
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 32.0),
            const Text('Historical Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0),
            FutureBuilder<List<ExamData>>(
              future: _fetchHistoricalData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No historical data available.'));
                }
                final examDataList = snapshot.data!;
                return ExamDataChart(examDataList: examDataList);
              },
            ),
          ],
        ),
      ),
    );
  }
}
