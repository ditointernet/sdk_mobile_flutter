import 'dart:async';

import 'package:dito_sdk/user/user_repository.dart';

import '../data/dito_api.dart';
import './services/event_database_service.dart';
import 'event_entity.dart';

/// EventRepository is responsible for managing events by interacting with
/// the local database and the Dito API.
class EventRepository {
  final DitoApi _api = DitoApi();
  final UserRepository _userRepository = UserRepository();
  final _database = EventDatabaseService();

  /// Tracks an event by saving it to the local database if the user is not registered,
  /// or by sending it to the Dito API if the user is registered.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked,
  /// or false if an error occurred.
  Future<bool> trackEvent(EventEntity event) async {
    // If the user is not registered, save the event to the local database
    if (_userRepository.data.userID == null) {
      return await _database.create(event);
    }

    // Otherwise, send the event to the Dito API
    return await _api
        .trackEvent(event, _userRepository.data)
        .then((response) => true)
        .catchError((e) => false);
  }

  /// Fetches all pending events from the local database.
  ///
  /// Returns a Future that completes with a list of EventEntity objects.
  Future<List<EventEntity>> fetchPendingEvents() async {
    return await _database.fetchAll();
  }

  /// Clears all events from the local database.
  ///
  /// Returns a Future that completes when the database has been cleared.
  Future<void> clearEvents() async {
    return await _database.clearDatabase();
  }
}
