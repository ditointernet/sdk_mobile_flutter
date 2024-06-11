import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../event/event_entity.dart';

/// EventDatabaseService is a singleton class that provides methods to interact with a SQLite database
/// for storing and managing events.
class EventDatabase {
  static const String _dbName = 'ditoSDK.db';
  static const String _tableName = 'events';
  static Database? _database;

  static final EventDatabase _instance = EventDatabase._internal();

  /// Factory constructor to return the singleton instance of EventDatabaseService.
  factory EventDatabase() {
    return _instance;
  }

  /// Private named constructor for internal initialization of singleton instance.
  EventDatabase._internal();

  /// Getter for the database instance.
  /// Initializes the database if it is not already initialized.
  /// Returns a Future that completes with the database instance.
  Future<Database> get database async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databaseFactoryOrNull = null;
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  /// Private method to initialize the database.
  /// Sets up the path and opens the database, creating it if it does not exist.
  /// Returns a Future that completes with the database instance.
  Future<Database> _initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final String path = '$databasePath/$_dbName';

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createTable,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      rethrow;
    }
  }

  /// Callback method to create the events table when the database is first created.
  ///
  /// [db] - The database instance.
  /// [version] - The version of the database.
  Future<void> _createTable(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          eventName TEXT,
          eventMoment TEXT,
          revenue REAL,
          customData TEXT
        )
      ''');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating table: $e');
      }
      rethrow;
    }
  }

  /// Method to insert a new event into the events table.
  ///
  /// [event] - The EventEntity object to be inserted.
  /// Returns a Future that completes with the row id of the inserted event.
  Future<bool> create(EventEntity event) async {
    try {
      final db = await database;
      return await db.insert(_tableName, event.toMap()) > 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting event: $e');
      }
      rethrow;
    }
  }

  /// Method to delete an event from the events table.
  ///
  /// [event] - The EventEntity object to be deleted.
  /// Returns a Future that completes with the number of rows deleted.
  Future<bool> delete(EventEntity event) async {
    try {
      final db = await database;
      return await db.delete(
            _tableName,
            where: 'eventName = ? AND eventMoment = ?',
            whereArgs: [event.eventName, event.eventMoment],
          ) >
          0;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting event: $e');
      }
      rethrow;
    }
  }

  /// Method to retrieve all events from the events table.
  /// Returns a Future that completes with a list of EventEntity objects.
  Future<List<EventEntity>> fetchAll() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_tableName);

      return maps.map((map) => EventEntity.fromMap(map)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving events: $e');
      }
      rethrow;
    }
  }

  /// Method to clear all events from the events table.
  /// Returns a Future that completes with the number of rows deleted.
  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing database: $e');
      }
      rethrow;
    }
  }

  /// Method to close the database.
  /// Should be called when the database is no longer needed.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
