import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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
      version: 1,
      onCreate: (db, version) async {
        await _createDB(db);
      },
      onOpen: (db) async {
        await _loadInitialDataIfNotExists(db);
      },
    );
  }

  Future<void> _createDB(Database db) async {
    debugPrint('Creating database tables...');
    await db.execute('''CREATE TABLE quizzes (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT,
      imageUrl TEXT
    )''');

    await db.execute('''CREATE TABLE ideas (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT
    )''');

    await db.execute('''CREATE TABLE topics (
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT
    )''');

    // Add a table to track if initial data is loaded
    await db.execute('''CREATE TABLE metadata (
      key TEXT PRIMARY KEY,
      value TEXT
    )''');

    debugPrint('Database tables created successfully.');
  }

  Future<void> _loadInitialDataIfNotExists(Database db) async {
    debugPrint('Checking if initial data is loaded...');
    final result = await db.query('metadata',
        where: 'key = ?', whereArgs: ['initial_data_loaded']);
    if (result.isEmpty) {
      debugPrint('Loading initial data from JSON');
      // Load initial data from JSON file
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

      // Mark initial data as loaded
      await db
          .insert('metadata', {'key': 'initial_data_loaded', 'value': 'true'});
      debugPrint('Initial data loaded successfully');
    } else {
      debugPrint('Initial data already loaded');
    }
  }
}
