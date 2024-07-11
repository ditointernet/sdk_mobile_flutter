import 'package:flutter/foundation.dart';

import '../event/event_entity.dart';
import 'database.dart';

/// EventDatabaseService is a singleton class that provides methods to interact with a SQLite database
/// for storing and managing events.
class EventDatabase {
  static final LocalDatabase _database = LocalDatabase();
  static final EventDatabase _instance = EventDatabase._internal();

  /// Factory constructor to return the singleton instance of EventDatabaseService.
  factory EventDatabase() {
    return _instance;
  }

  /// Private named constructor for internal initialization of singleton instance.
  EventDatabase._internal();

  /// Method to insert a new event into the events table.
  ///
  /// [event] - The EventEntity object to be inserted.
  /// Returns a Future that completes with the row id of the inserted event.
  Future<bool> create(EventEntity event) async {
    try {
      return await _database.insert(
              _database.tables["events"]!, event.toMap()) >
          0;
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
      return await _database.delete(
            _database.tables["events"]!,
            'eventName = ? AND eventMoment = ?',
            [event],
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
  /// Returns a Future that completes with a list of Map objects.
  Future<Iterable<EventEntity>> fetchAll() async {
    try {
      final maps = await _database.fetchAll(_database.tables["events"]!);
      return maps.map((map) => EventEntity.fromMap(map));
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
      return _database.clearDatabase(_database.tables["events"]!);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing database: $e');
      }
      rethrow;
    }
  }

  /// Method to close the database.
  /// Should be called when the database is no longer needed.
  Future<void> closeDatabase() => _database.closeDatabase();
}
