import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'databaseutils/db_utils.dart';
import 'databaseutils/dbutils_sql.dart';
import 'initial_profile.dart';
import 'initial_survey.dart';
import 'providers/quiz_provider.dart';
import 'providers/idea_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/topic_provider.dart';
import 'home_page.dart';
import 'providers/trending_topicprovider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure tables are created and data is loaded if needed
  await loadDemoDataIfNeeded();

  bool isSurveyCompleted =
      await DBUtilsSQL().isSurveyCompleted(); // Check if survey is completed

  runApp(MyApp(isSurveyCompleted: isSurveyCompleted));
}

Future<void> loadDemoDataIfNeeded() async {
  final dbUtils = DBUtilsSQL();
  // Check if metadata table exists and data_loaded is false
  bool isDataLoaded = await dbUtils.isDataLoaded();

  if (!isDataLoaded) {
    print('Data is not loaded and reading script file');
    // Read the script file
    String script = await rootBundle.loadString('assets/scripts/DemoData.txt');
    print('Data is not loaded and reading script file and scirpt is ' + script);
    // Execute the script
    await dbUtils.executeScript(script);
    await loadLearningPathData();
  } else {
    print('Data is loaded');
  }
}

Future<void> loadLearningPathData() async {
  final db = await DBUtilsSQL().database;

  // Load JSON data from file
  final jsonString =
      await rootBundle.loadString('assets/scripts/learning_path_data.json');
  final jsonData = jsonDecode(jsonString);

  // Extract learning paths
  final learningPaths = jsonData['learningPaths'] as List<dynamic>;
  // print('Reading learning paths');

  for (var path in learningPaths) {
    final title = path['title'];
    final description = path['briefDescription'];
    // print('Inserting title: $title');

    // Get today's date in YYYY-MM-DD format
    final creationDate = DateTime.now().toIso8601String().split('T')[0];

    // Insert into learningPathOverviews with creationDate
    final lpId = await db.insert('learningPathOverviews', {
      'title': title,
      'description': description,
      'creationDate': creationDate,
    });
    // print('Inserted lpId: $lpId');

    // Insert steps with seqNumber starting from 1
    final steps = path['learningPath'] as List<dynamic>;
    int seqNumber = 1; // Initialize sequence number

    for (var step in steps) {
      await db.insert('learningPathSteps', {
        'lpId': lpId,
        'seqNumber': seqNumber,
        'topicTitle': step['topicTitle'],
        'topicBrief': step['topicBrief'],
        'links': step['link'],
      });
      // print('Inserted step with seqNumber: $seqNumber');
      seqNumber++; // Increment sequence number for next step
    }
  }
}

class MyApp extends StatelessWidget {
  final bool isSurveyCompleted;

  MyApp({required this.isSurveyCompleted});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        //  ChangeNotifierProvider(create: (_) => IdeaProvider()),
        ChangeNotifierProvider(create: (_) => TopicsProvider()),
        ChangeNotifierProvider(create: (_) => SubjectsProvider()),
        ChangeNotifierProvider(create: (_) => TrendingTopicProvider()),
      ],
      child: MaterialApp(
        title: 'EduLearn',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
            onPrimary: Colors.white,
            secondary: Colors.deepPurpleAccent,
            onSecondary: Colors.white,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            color: Colors.deepPurple,
            elevation: 0,
            toolbarHeight: 80, // Adjust height to fit content
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.deepPurple,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
        ),
        home: isSurveyCompleted ? HomePage() : ProfileCreationPage(),
        //home: HomePage(),
        debugShowCheckedModeBanner: false, // Remove debug banner
      ),
    );
  }
}
