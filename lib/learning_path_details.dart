import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart'; // For formatting date

import 'databaseutils/dbutils_sql.dart';
import 'learning_path_step.dart';

class LearningPathDetailPage extends StatelessWidget {
  final int lpId;
  final String title;

  LearningPathDetailPage({required this.lpId, required this.title});

  Future<List<Map<String, dynamic>>> _fetchLearningPathSteps() async {
    final db = await DBUtilsSQL().database;
    return await db.query(
      'learningPathSteps',
      where: 'lpId = ?',
      whereArgs: [lpId],
      orderBy: 'seqNumber ASC',
    );
  }

  Future<void> _markAsCompleted(BuildContext context) async {
    final db = await DBUtilsSQL().database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await db.update(
        'learningPathOverviews',
        {
          'status': 'Completed',
          'attemptedDate': today,
        },
        where: 'lpId = ?',
        whereArgs: [lpId],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Learning Path marked as completed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking as completed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        isBackButtonVisible: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLearningPathSteps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading learning path steps'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No steps available'));
          }

          final steps = snapshot.data!;
          return ListView.builder(
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(step['seqNumber'].toString()),
                  ),
                  title: Text(step['topicTitle']),
                  subtitle: Text(
                    step['topicBrief'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LearningPathStepPage(url: step['links']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _markAsCompleted(context),
        child: Icon(Icons.check),
        tooltip: 'Mark As Completed',
      ),
    );
  }
}
