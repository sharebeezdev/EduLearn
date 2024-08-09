import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:math';

import 'databaseutils/dbutils_sql.dart';
import 'learning_path_details.dart';

class LearningPathSuggestions extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchLearningPaths() async {
    final db = await DBUtilsSQL().database;
    return await db.query(
      'learningPathOverviews',
      where: 'status != ?',
      whereArgs: ['Completed'],
      orderBy: 'creationDate DESC',
      limit: 3,
    );
  }

  Color _getRandomLightColor() {
    final lightColors = [
      Colors.lightBlue[100]!,
      Colors.lightGreen[100]!,
      Colors.amber[100]!,
      Colors.pink[100]!,
      Colors.orange[100]!,
      Colors.teal[100]!,
      Colors.yellow[100]!,
      Colors.cyan[100]!,
      Colors.lime[100]!,
      Colors.indigo[100]!,
    ];

    final random = Random();
    return lightColors[random.nextInt(lightColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLearningPaths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error loading learning paths: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No learning paths available'));
        }

        final learningPaths = snapshot.data!;

        // Debug print statements
        print('Number of learning paths retrieved: ${learningPaths.length}');
        for (var path in learningPaths) {
          print('Learning Path: ${path}');
        }

        return ListView.builder(
          itemCount: learningPaths.length,
          itemBuilder: (context, index) {
            final learningPath = learningPaths[index];

            // Debug print statements for each learningPath
            print('Index: $index, Learning Path: $learningPath');
            final title = learningPath['title'] as String?;
            final description = learningPath['description'] as String?;
            final lpId = learningPath['lpId'] as int?;

            // Check for null values
            if (title == null || description == null || lpId == null) {
              print(
                  'Error: One or more fields are null. Title: $title, Description: $description, lpId: $lpId');
              return const SizedBox
                  .shrink(); // Skip rendering if there is an error
            }

            final bgColor = _getRandomLightColor();
            final textColor =
                bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

            return Card(
              color: bgColor,
              child: ListTile(
                title: Text(
                  title,
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  description,
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningPathDetailPage(
                        lpId: lpId,
                        title: title,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
