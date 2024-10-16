import 'dart:async';
import 'dart:convert';

import '../api/dito_api_interface.dart';
import '../notification/notification_entity.dart';
import '../proto/sdkapi/v1/api.pb.dart';
import '../user/user_repository.dart';
import '../utils/logger.dart';
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

    if (_userRepository.data.isNotValid) {
      return await _database.create(EventsNames.track, activity.id,
          event: event);
    }

    final result = await _api.createRequest([activity]).call();

    print(result);

    if (result >= 400 && result < 500) {
      await _database.create(EventsNames.track, activity.id, event: event);
      return false;
    }

    return true;
  }

  /// Tracks an event by saving it to the local database if the user is not registered,
  /// or by sending it to the Dito API if the user is registered.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked,
  /// or false if an error occurred.
  Future<bool> navigate(NavigationEntity navigation) async {
    final activity = ApiActivities().trackNavigation(navigation);

    if (_userRepository.data.isNotValid) {
      return await _database.create(EventsNames.navigate, activity.id,
          navigation: navigation);
    }

    final result = await _api.createRequest([activity]).call();

    if (result >= 400 && result < 500) {
      await _database.create(EventsNames.navigate, activity.id,
          navigation: navigation);
      return false;
    }

    return true;
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
            activities
                .add(ApiActivities().trackEvent(event, uuid: uuid, time: time));
            break;
          case 'received':
            final event =
                NotificationEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(ApiActivities()
                .notificationReceived(event, uuid: uuid, time: time));
            break;
          case 'click':
            final event =
                NotificationEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(ApiActivities()
                .notificationClick(event, uuid: uuid, time: time));
            break;
          case 'navigate':
            final event =
                NavigationEntity.fromMap(jsonDecode(row["event"] as String));
            activities.add(
                ApiActivities().trackNavigation(event, uuid: uuid, time: time));
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
      loggerError('Error verifying pending events on notification: $e');

      rethrow;
    }
  }
}
