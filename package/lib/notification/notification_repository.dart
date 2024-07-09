import 'dart:async';

import 'package:http/http.dart' as http;

import '../data/dito_api.dart';
import '../event/event_entity.dart';
import '../event/event_interface.dart';
import '../user/user_interface.dart';
import 'notification_entity.dart';

class NotificationRepository {
  final DitoApi _api = DitoApi();
  final UserInterface _userInterface = UserInterface();
  final EventInterface _eventInterface = EventInterface();

  /// The broadcast stream for received notifications
  final StreamController<NotificationEntity> didReceiveLocalNotificationStream =
      StreamController<NotificationEntity>.broadcast();

  /// The broadcast stream for selected notifications
  final StreamController<DataPayload> selectNotificationStream =
      StreamController<DataPayload>.broadcast();

  /// Registers the FCM token with the server.
  ///
  /// [token] - The FCM token to be registered.
  /// Returns an http.Response from the server.
  Future<http.Response> registryToken(String token) async {
    return await _api.registryToken(token, _userInterface.data);
  }

  /// Removes the FCM token from the server.
  ///
  /// [token] - The FCM token to be removed.
  /// Returns an http.Response from the server.
  Future<http.Response> removeToken(String token) async {
    return await _api.removeToken(token, _userInterface.data);
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
