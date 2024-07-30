import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/dito_api.dart';
import '../data/notification_database.dart';
import '../event/event_entity.dart';
import '../event/event_interface.dart';
import '../user/user_repository.dart';
import 'notification_entity.dart';

class NotificationRepository {
  final DitoApi _api = DitoApi();
  final _database = NotificationEvent();
  final UserRepository _userRepository = UserRepository();
  final EventInterface _eventInterface = EventInterface();

  /// The broadcast stream for received notifications
  final StreamController<NotificationEntity> didReceiveLocalNotificationStream =
      StreamController<NotificationEntity>.broadcast();

  /// The broadcast stream for selected notifications
  final StreamController<DataPayload> selectNotificationStream =
      StreamController<DataPayload>.broadcast();

  /// Verifies and processes any pending events.
  ///
  /// Throws an exception if the user is not valid.
  Future<void> verifyPendingEvents() async {
    try {
      final events = await _database.fetchAll();

      for (final event in events) {
        final eventName = event["event"] as String;
        final token = event["token"] as String;
        switch (eventName) {
          case "register-token":
            registryToken(token);
            break;
          case "remove-token":
            removeToken(token);
            break;
          default:
            break;
        }
      }

      await _database.clearDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events on notification: $e');
      }
      rethrow;
    }
  }

  /// Registers the FCM token with the server.
  ///
  /// [token] - The FCM token to be registered.
  /// Returns an http.Response from the server.
  Future<bool> registryToken(String token) async {
    if (_userRepository.data.isNotValid) {
      return await _database.create('register-token', token);
    }

    return await _api
        .registryToken(token, _userRepository.data)
        .then((result) => true)
        .catchError((e) => false);
  }

  /// Removes the FCM token from the server.
  ///
  /// [token] - The FCM token to be removed.
  /// Returns an http.Response from the server.
  Future<bool> removeToken(String token) async {
    if (_userRepository.data.isNotValid) {
      return await _database.create('remove-token', token);
    }

    return await _api
        .removeToken(token, _userRepository.data)
        .then((result) => true)
        .catchError((e) => false);
  }

  /// This method send a notify received push event to Dito
  ///
  /// [notification] - DataPayload object.
  Future<void> notifyReceivedNotification(String notificationId) async {
    await _eventInterface.trackEvent(EventEntity(
        eventName: 'received-mobile-push-notification',
        customData: {'notification_id': notificationId}));
  }

  /// This method send a open unsubscribe from notification event to Dito
  Future<void> unsubscribeFromNotifications() async {
    await _eventInterface.trackEvent(
        EventEntity(eventName: 'unsubscribed-mobile-push-notification'));
  }

  /// This method send a open deeplink event to Dito
  Future<void> notifyOpenDeepLink(String? notificationId) async {
    await _eventInterface.trackEvent(EventEntity(
        eventName: 'open-deeplink-mobile-push-notification',
        customData: {'notification_id': notificationId}));
  }
}
