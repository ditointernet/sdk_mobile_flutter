import 'dart:async';
import 'dart:convert';

import 'package:dito_sdk/notification/notification_entity.dart';
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
    final activity = ApiActivities().trackEvent(event);

    // If the user is not registered, save the event to the local database
    if (_userRepository.data.isNotValid) {
      return await _database.create(EventsNames.track, activity.id, event: event);
    }

    // Otherwise, send the event to the Dito API
    return await _api.createRequest([activity]).call();
  }

  /// Tracks an event by saving it to the local database if the user is not registered,
  /// or by sending it to the Dito API if the user is registered.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked,
  /// or false if an error occurred.
  Future<bool> navigate(NavigationEntity navigation) async {
    final activity = ApiActivities().trackNavigation(navigation);

    // If the user is not registered, save the event to the local database
    if (_userRepository.data.isNotValid) {
      return await _database.create(EventsNames.navigate, activity.id,
          navigation: navigation);
    }

    // Otherwise, send the event to the Dito API
    return await _api.createRequest([activity]).call();
  }

  /// Verifies and processes any pending events.
  ///
  /// Throws an exception if the user is not valid.
  Future<void> verifyPendingEvents() async {
    try {
      final rows = await _database.fetchAll();
      List<Activity> activities = [];

      for (final row in rows) {
        final eventName = row["name"];
        final uuid = row["uuid"] as String? ?? null;
        final time = row["createdAt"] as String? ?? null;

        switch (eventName) {
          case 'track':
            final event =
                EventEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(ApiActivities().trackEvent(event, uuid: uuid, time: time));
            break;
          case 'received':
            final event =
                NotificationEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(ApiActivities().notificationReceived(event, uuid: uuid, time: time));
            break;
          case 'click':
            final event =
                NotificationEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(ApiActivities().notificationClick(event, uuid: uuid, time: time));
            break;
          case 'navigate':
            final event =
                NavigationEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(ApiActivities().trackNavigation(event, uuid: uuid, time: time));
            break;
          default:
            break;
        }
      }

      if (activities.isNotEmpty) {
        await _api.createRequest(activities).call();
      }

      return await _database.clearDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events on notification: $e');
      }
      rethrow;
    }
  }
}
