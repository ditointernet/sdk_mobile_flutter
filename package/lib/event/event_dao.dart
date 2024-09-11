import 'dart:convert';

import 'package:dito_sdk/notification/notification_entity.dart';
import 'package:flutter/foundation.dart';

import '../data/database.dart';
import 'event_entity.dart';
import 'navigation_entity.dart';

/// EventDatabaseService is a singleton class that provides methods to interact with a SQLite database
/// for storing and managing events.
class EventDAO {
  static final LocalDatabase _database = LocalDatabase();
  static final EventDAO _instance = EventDAO._internal();

  get _table => _database.tables["events"];

  /// Factory constructor to return the singleton instance of EventDatabaseService.
  factory EventDAO() {
    return _instance;
  }

  /// Private named constructor for internal initialization of singleton instance.
  EventDAO._internal();

  /// Method to insert a new event into the events table.
  ///
  /// [event] - The EventEntity object to be inserted.
  /// [navigation] - The NavigationEntity object to be inserted.
  /// [notification] - The NotificationEntity object to be inserted.
  /// Returns a Future that completes with the row id of the inserted event.
  Future<bool> create(
      {EventEntity? event, NavigationEntity? navigation, NotificationEntity? notification}) async {
    try {
      if (event != null) {
        return await _database.insert(_table, {
              "name": event.action,
              "event": jsonEncode(event.toJson()),
              "type": "1",
              "createdAt": DateTime.now().toIso8601String()
            }) >
            0;
      }

      if (navigation != null) {
        return await _database.insert(_table, {
              "name": navigation.pageName,
              "event": jsonEncode(navigation.toJson()),
              "type": "2",
              "createdAt": DateTime.now().toIso8601String()
            }) >
            0;
      }

      if (notification != null) {
        return await _database.insert(_table, {
          "name": notification.notificationLogId,
          "event": jsonEncode(notification.toJson()),
          "type": "3",
          "createdAt": DateTime.now().toIso8601String()
        }) >
            0;
      }

      return false;
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
            _table,
            'name = ? AND createdAt = ?',
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
  Future<Iterable> fetchAll() async {
    try {
      return await _database.fetchAll(_table);
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
      return _database.clearDatabase(_table);
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
