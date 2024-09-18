import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// EventDatabaseService is a singleton class that provides methods to interact with a SQLite database
/// for storing and managing events.
class LocalDatabase {
  static const String _dbName = 'dito-offline.db';
  static Database? _database;
  final tables = {"notification": "notification", "events": "events", "user": "user"};

  static final LocalDatabase _instance = LocalDatabase._internal();

  /// Factory constructor to return the singleton instance of EventDatabaseService.
  factory LocalDatabase() {
    return _instance;
  }

  /// Private named constructor for internal initialization of singleton instance.
  LocalDatabase._internal();

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
        version: 2,
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
  FutureOr<void> _createTable(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          event TEXT,
          createdAt TEXT
        );
      ''');
      await db.execute('''
        CREATE TABLE user (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          user TEXT,
          createdAt TEXT
        );
      ''');
    } catch (e) {
      if (kDebugMode) {
        print('Error creating table: $e');
      }
      rethrow;
    }
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> delete(
      String table, String where, List<dynamic> whereArgs) async {
    try {
      final db = await database;
      return await db.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting event: $e');
      }
      rethrow;
    }
  }

  /// Method to retrieve all events from the events table.
  /// Returns a Future that completes with a list of Map objects.
  Future<List<Map<String, Object?>>> fetchAll(String tableName) async {
    final db = await database;
    return db.query(tableName);
  }

  /// Method to clear all events from the events table.
  /// Returns a Future that completes with the number of rows deleted.
  Future<void> clearDatabase(String tableName) async {
    try {
      final db = await database;
      await db.delete(tableName);
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
