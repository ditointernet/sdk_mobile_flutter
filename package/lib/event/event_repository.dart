import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/dito_api.dart';
import '../data/event_database.dart';
import '../user/user_repository.dart';
import 'event_entity.dart';

/// EventRepository is responsible for managing events by interacting with
/// the local database and the Dito API.
class EventRepository {
  final DitoApi _api = DitoApi();
  final UserRepository _userRepository = UserRepository();
  final _database = EventDatabase();

  /// Tracks an event by saving it to the local database if the user is not registered,
  /// or by sending it to the Dito API if the user is registered.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked,
  /// or false if an error occurred.
  Future<bool> trackEvent(EventEntity event) async {
    try {
      // If the user is not registered, save the event to the local database
      if (_userRepository.data.isNotValid) {
        return await _database.create(event);
      }

      // If the user don't have internet connection
      final result = await InternetAddress.lookup('dito.com.br');
      if (result.isEmpty && result[0].rawAddress.isEmpty) {
        return await _database.create(event);
      }

      // Otherwise, send the event to the Dito API
      return await _api
          .trackEvent(event, _userRepository.data)
          .then((response) => true)
          .catchError((e) => false);
    } on SocketException catch (_) {
      return await _database.create(event);
    }
  }

  /// Verifies and processes any pending events.
  ///
  /// Throws an exception if the user is not valid.
  Future<void> verifyPendingEvents() async {
    try {
      final events = await _database.fetchAll();

      for (final event in events) {
        await trackEvent(event);
      }

      await _database.clearDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events: $e');
      }
      rethrow;
    }
  }
}
