import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'databaseutils/db_helper.dart';
import 'providers/quiz_provider.dart';
import 'providers/idea_provider.dart';
import 'providers/topic_provider.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DBHelper();
  // Ensure database is initialized, which now includes loading initial data
  await dbHelper.database;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => IdeaProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
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
        home: HomePage(),
      ),
    );
  }
}
