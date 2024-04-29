import 'dart:io';

import 'package:dito_sdk/entity/event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._privateConstructor();
  static Database? _database;

  LocalDatabase._privateConstructor();

  Future<Database> get database async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventName TEXT,
        eventMoment TEXT,
        revenue REAL,
        customData TEXT
      )
    ''');
  }

  Future<void> createEvent(Event event) async {
    final db = await database;
    await db.insert('events', event.toMap());
  }

  Future<int> deleteEvent(Event event) async {
    final db = await database;
    return await db.delete(
      'events',
      where: 'eventName = ? AND eventMoment = ?',
      whereArgs: [event.eventName, event.eventMoment],
    );
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');

    return List.generate(maps.length, (index) {
      return Event.fromMap(maps[index]);
    });
  }

  Future<int> deleteEvents() async {
    final db = await database;
    return await db.delete('events');
  }
}
