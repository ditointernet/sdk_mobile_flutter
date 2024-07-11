import 'package:flutter/foundation.dart';

import 'database.dart';

/// EventDatabaseService is a singleton class that provides methods to interact with a SQLite database
/// for storing and managing notification.
class NotificationEvent {
  static final LocalDatabase _database = LocalDatabase();
  static final NotificationEvent _instance = NotificationEvent._internal();

  /// Factory constructor to return the singleton instance of EventDatabaseService.
  factory NotificationEvent() {
    return _instance;
  }

  /// Private named constructor for internal initialization of singleton instance.
  NotificationEvent._internal();

  /// Method to insert a new event into the notification table.
  ///
  /// [event] - The event name to be inserted.
  /// Returns a Future that completes with the row id of the inserted event.
  Future<bool> create(String event, String token) async {
    try {
      return await _database.insert(_database.tables["notification"]!,
              {'event': event, 'token': token}) >
          0;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting event: $e');
      }
      rethrow;
    }
  }

  /// Method to delete an event from the notification table.
  ///
  /// [event] - The event name to be deleted.
  /// Returns a Future that completes with the number of rows deleted.
  Future<bool> delete(String event) async {
    try {
      return await _database.delete(
            _database.tables["notification"]!,
            'event = ?',
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

  /// Method to retrieve all notification from the notification table.
  /// Returns a Future that completes with a list of Map objects.
  Future<List<Map<String, Object?>>> fetchAll() async {
    try {
      return await _database.fetchAll(_database.tables["notification"]!);
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving notification: $e');
      }
      rethrow;
    }
  }

  /// Method to clear all notification from the notification table.
  /// Returns a Future that completes with the number of rows deleted.
  Future<void> clearDatabase() async {
    try {
      return _database.clearDatabase(_database.tables["notification"]!);
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
