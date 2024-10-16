import 'dart:convert';

import '../data/database.dart';
import '../utils/logger.dart';
import 'user_entity.dart';

enum UserEventsNames { login, identify, registryToken, pingToken, removeToken }

/// EventDatabaseService is a singleton class that provides methods to interact with a SQLite database
/// for storing and managing notification.
class UserDAO {
  static final LocalDatabase _database = LocalDatabase();
  static final UserDAO _instance = UserDAO._internal();
  get _dataTable => _database.tables["user"];

  /// Factory constructor to return the singleton instance of EventDatabaseService.
  factory UserDAO() {
    return _instance;
  }

  /// Private named constructor for internal initialization of singleton instance.
  UserDAO._internal();

  /// Method to insert a new event into the notification table.
  ///
  /// [event] - The event name to be inserted.
  /// [user] - The User entity to be inserted.
  /// [uuid] - Event Identifier.
  /// Returns a Future that completes with the row id of the inserted event.
  Future<bool> create(
      UserEventsNames event, UserEntity user, String uuid) async {
    try {
      return await _database.insert(_dataTable!, {
            "name": event.name,
            "user": jsonEncode(user.toJson()),
            "uuid": uuid,
            "createdAt": DateTime.now().toIso8601String()
          }) >
          0;
    } catch (e) {
      loggerError('Error inserting event: $e');

      rethrow;
    }
  }

  /// Method to delete an event from the notification table.
  ///
  /// [event] - The event name to be deleted.
  /// Returns a Future that completes with the number of rows deleted.
  Future<bool> delete(String userID) async {
    try {
      return await _database.delete(
            _dataTable!,
            'userID = ?',
            [userID],
          ) >
          0;
    } catch (e) {
      loggerError('Error deleting event: $e');

      rethrow;
    }
  }

  /// Method to retrieve all notification from the notification table.
  /// Returns a Future that completes with a list of Map objects.
  Future<List<Map<String, Object?>>> fetchAll() async {
    try {
      return await _database.fetchAll(_dataTable!);
    } catch (e) {
      loggerError('Error retrieving notification: $e');

      rethrow;
    }
  }

  /// Method to clear all notification from the notification table.
  /// Returns a Future that completes with the number of rows deleted.
  Future<void> clearDatabase() async {
    try {
      return _database.clearDatabase(_dataTable!);
    } catch (e) {
      loggerError('Error clearing database: $e');

      rethrow;
    }
  }

  /// Method to close the database.
  /// Should be called when the database is no longer needed.
  Future<void> closeDatabase() => _database.closeDatabase();
}
