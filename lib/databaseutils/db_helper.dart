import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/quiz_question.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'edu_learn.db');
    debugPrint('Initializing database at path: $path');
    return await openDatabase(
      path,
      version: 8, // Increment the version number for schema changes
      onCreate: (db, version) async {
        await _createDB(db);
        await _loadInitialDataIfNotExists(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await _upgradeDB(db, oldVersion, newVersion);
        }
      },
    );
  }

  Future<void> _createDB(Database db) async {
    debugPrint('Creating database tables...');

    final tables = [
      'quizzes',
      'ideas',
      'topics',
      'subjects',
      'topics_of_interest',
      'historical_exams',
      'QuizOverviews',
      'MyTopicsQuizzes',
      'MySubjectQuizzes',
      'MyHistoricalDataQuizzes',
      'FeaturedQuizzes',
      'QuizScores',
      'metadata',
      'trending_topics',
      'ScoreDetails',
      'SurveyData',
    ];

    for (var table in tables) {
      final count = Sqflite.firstIntValue(await db.rawQuery(
              'SELECT COUNT(*) FROM sqlite_master WHERE type = "table" AND name = ?',
              [table])) ??
          0;

      if (count == 0) {
        switch (table) {
          case 'quizzes':
            await db.execute('''CREATE TABLE quizzes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              imageUrl TEXT
            )''');
            break;
          case 'ideas':
            await db.execute('''CREATE TABLE ideas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT
            )''');
            break;
          case 'topics':
            await db.execute('''CREATE TABLE topics (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT
            )''');
            break;
          case 'subjects':
            await db.execute('''CREATE TABLE subjects (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )''');
            break;
          case 'topics_of_interest':
            await db.execute('''CREATE TABLE topics_of_interest (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
            )''');
            break;
          case 'historical_exams':
            await db.execute('''CREATE TABLE historical_exams (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              examName TEXT,
              examDate TEXT,
              subject TEXT,
              marks INTEGER,
              totalMarks INTEGER
            )''');
            break;
          case 'QuizOverviews':
            await db.execute('''CREATE TABLE QuizOverviews (
              quizId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizTitle TEXT,
              quizDescription TEXT,
              quizType TEXT,
              imageUrl TEXT,
              status TEXT DEFAULT 'Not Attempted',
              creationDate TEXT,
              attemptedDate TEXT,
              quizScore REAL
            )''');
            break;
          case 'MyTopicsQuizzes':
            await db.execute('''CREATE TABLE MyTopicsQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'MySubjectQuizzes':
            await db.execute('''CREATE TABLE MySubjectQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'MyHistoricalDataQuizzes':
            await db.execute('''CREATE TABLE MyHistoricalDataQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'FeaturedQuizzes':
            await db.execute('''CREATE TABLE FeaturedQuizzes (
              questionId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              questionNumber INTEGER,
              questionText TEXT,
              choices TEXT,
              correctChoice TEXT,
              reason TEXT,
              links TEXT,
              FOREIGN KEY (quizId) REFERENCES QuizOverviews (quizId)
            )''');
            break;
          case 'QuizScores':
            await db.execute('''CREATE TABLE QuizScores (
              scoreId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              attemptedDate TEXT,
              percentageScored REAL
            )''');
            break;
          case 'ScoreDetails': // Create the new table
            await db.execute('''CREATE TABLE ScoreDetails (
              scoreId INTEGER PRIMARY KEY AUTOINCREMENT,
              quizId INTEGER,
              attemptedDate TEXT,
              percentageScored REAL
            )''');
            break;
          case 'metadata':
            await db.execute('''CREATE TABLE metadata (
              key TEXT PRIMARY KEY,
              value TEXT
            )''');
            break;
          case 'trending_topics':
            await db.execute('''CREATE TABLE trending_topics (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              topic TEXT
            )''');
            break;
          case 'SurveyData':
            await db.execute('''CREATE TABLE SurveyData (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              areaOfDifficulty TEXT,
              preferredLearningStyle TEXT
            )''');
            break;
        }
      }
    }

    debugPrint('Database tables created successfully.');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('Upgrading database from version $oldVersion to $newVersion...');

    if (oldVersion < 8) {
      debugPrint('Adding ScoreDetails table...');
      await db.execute('''CREATE TABLE IF NOT EXISTS ScoreDetails (
        scoreId INTEGER PRIMARY KEY AUTOINCREMENT,
        quizId INTEGER,
        attemptedDate TEXT,
        percentageScored REAL
      )''');
    }

    debugPrint('Database upgraded successfully.');
  }

  Future<void> _loadInitialDataIfNotExists(Database db) async {
    debugPrint('Checking if initial data is loaded...');
    final result = await db.query('metadata',
        where: 'key = ?', whereArgs: ['initial_data_loaded']);
    if (result.isEmpty) {
      debugPrint('Loading initial data from JSON');
      final String data =
          await rootBundle.loadString('assets/initial_data.json');
      final Map<String, dynamic> jsonData = json.decode(data);

      for (var quiz in jsonData['quizzes']) {
        await db.insert('quizzes', quiz);
      }
      for (var idea in jsonData['ideas']) {
        await db.insert('ideas', idea);
      }
      for (var topic in jsonData['topics']) {
        await db.insert('topics', topic);
      }

      await db
          .insert('metadata', {'key': 'initial_data_loaded', 'value': 'true'});
      debugPrint('Initial data loaded successfully');
    } else {
      debugPrint('Initial data already loaded');
    }
  }

  Future<void> addTrendingTopic(String topic) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM trending_topics')) ??
        0;
    if (count >= 10) {
      await db.delete('trending_topics',
          where: 'id = (SELECT MIN(id) FROM trending_topics)');
    }
    await db.insert('trending_topics', {'topic': topic});
  }

  Future<List<String>> getTrendingTopics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('trending_topics', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return maps[i]['topic'];
    });
  }

  Future<void> clearTrendingTopics() async {
    final db = await database;
    await db.delete('trending_topics');
  }

  Future<void> addMyTopicsQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('MyTopicsQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getMyTopicsQuizzes() async {
    final db = await database;
    return await db.query('MyTopicsQuizzes');
  }

  Future<void> addMySubjectQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('MySubjectQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getMySubjectQuizzes() async {
    final db = await database;
    return await db.query('MySubjectQuizzes');
  }

  Future<void> addMyHistoricalDataQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('MyHistoricalDataQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getMyHistoricalDataQuizzes() async {
    final db = await database;
    return await db.query('MyHistoricalDataQuizzes');
  }

  Future addFeaturedQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    await db.insert('FeaturedQuizzes', quiz);
  }

  Future<List<Map<String, dynamic>>> getFeaturedQuizzes() async {
    final db = await database;
    return await db.query('FeaturedQuizzes');
  }

// Additional methods for ScoreDetails
  Future addScoreDetail(Map<String, dynamic> scoreDetail) async {
    final db = await database;
    await db.insert('ScoreDetails', scoreDetail);
  }

  Future<List<Map<String, dynamic>>> getScoreDetails() async {
    final db = await database;
    return await db.query('ScoreDetails');
  }

  Future insertQuizScore(Map<String, dynamic> score) async {
    final db = await database;
    await db.insert('QuizScores', score);
  }

  Future<List<Map<String, dynamic>>> getQuizScores() async {
    final db = await database;
    return await db.query('QuizScores');
  }

  Future addQuizScore(Map<String, dynamic> score) async {
    final db = await database;
    await db.insert('QuizScores', score);
  }

  Future<void> insertSurveyData(Map<String, dynamic> surveyData) async {
    final db = await database;
    await db.insert('SurveyData', surveyData);
  }
}
