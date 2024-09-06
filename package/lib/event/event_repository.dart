import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../api/dito_api_interface.dart';
import '../proto/api.pb.dart';
import '../user/user_repository.dart';
import 'event_dao.dart';
import 'event_entity.dart';
import 'navigation_entity.dart';

/// EventRepository is responsible for managing events by interacting with
/// the local database and the Dito API.
class EventRepository {
  final ApiInterface _api = ApiInterface();
  final UserRepository _userRepository = UserRepository();
  final _database = EventDAO();

  /// Tracks an event by saving it to the local database if the user is not registered,
  /// or by sending it to the Dito API if the user is registered.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked,
  /// or false if an error occurred.
  Future<bool> track(EventEntity event) async {
    // If the user is not registered, save the event to the local database
    if (_userRepository.data.isNotValid) {
      return await _database.create(event: event);
    }

    // Otherwise, send the event to the Dito API
    final activities = [ApiActivities().trackEvent(event)];

    return await _api.createRequest(activities).call();
  }

  /// Tracks an event by saving it to the local database if the user is not registered,
  /// or by sending it to the Dito API if the user is registered.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked,
  /// or false if an error occurred.
  Future<bool> navigate(NavigationEntity navigation) async {
    // If the user is not registered, save the event to the local database
    if (_userRepository.data.isNotValid) {
      return await _database.create(navigation: navigation);
    }

    // Otherwise, send the event to the Dito API
    final activities = [ApiActivities().trackNavigation(navigation)];

    return await _api.createRequest(activities).call();
  }

  /// Verifies and processes any pending events.
  ///
  /// Throws an exception if the user is not valid.
  Future<void> verifyPendingEvents() async {
    try {
      final rows = await _database.fetchAll();
      List<Activity> activities = [];

      for (var row in rows) {
        if (row["type"] == 1) {
          final event = EventEntity.fromMap(jsonDecode(row["event"] as String));
          activities.add(ApiActivities().trackEvent(event));
        } else {
          final navigation =
              NavigationEntity.fromMap(jsonDecode(row["event"] as String));
          activities.add(ApiActivities().trackNavigation(navigation));
        }
      }

      await _api.createRequest(activities).call;

      await _database.clearDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events: $e');
      }
      rethrow;
    }
  }
}
