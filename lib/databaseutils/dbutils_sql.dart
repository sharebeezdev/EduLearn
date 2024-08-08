import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBUtilsSQL {
  static final DBUtilsSQL _instance = DBUtilsSQL._internal();
  Database? _database;

  DBUtilsSQL._internal();

  factory DBUtilsSQL() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'edu_learn.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS metadata (
        key TEXT PRIMARY KEY,
        value TEXT
      );
    ''');
  }

  Future<bool> isSurveyCompleted() async {
    final db = await database;
    final result = await db
        .query('metadata', where: 'key = ?', whereArgs: ['survey_completed']);
    return result.isNotEmpty && result.first['value'] == 'true';
  }

  Future<bool> isDataLoaded() async {
    final db = await database;
    final result = await db
        .query('metadata', where: 'key = ?', whereArgs: ['data_loaded']);
    return result.isNotEmpty && result.first['value'] == 'true';
  }

  Future<void> executeScript(String script) async {
    final db = await database;
    List<String> statements = script.split(';');
    for (String statement in statements) {
      if (statement.trim().isNotEmpty) {
        print('Executing SQL: $statement'); // Add this line to debug
        await db.execute(statement);
      }
    }
    // Mark the data as loaded
    await db.insert('metadata', {'key': 'data_loaded', 'value': 'true'},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
