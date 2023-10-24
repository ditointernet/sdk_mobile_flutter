import 'package:dito_sdk/event.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final String path = '$databasePath/ditoSDK.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY,
        eventName TEXT,
        eventMoment TEXT,
        revenue REAL,
        customData TEXT
      )
    ''');
  }

  Future<void> insertEvent(Event event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');

    return List.generate(maps.length, (index) {
      return Event.fromMap(maps[index]);
    });
  }

  Future<void> deleteAllEvents() async {
    final db = await database;
    await db.delete('events');
  }
}
