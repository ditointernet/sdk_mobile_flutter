import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../api/dito_api_interface.dart';
import 'notification_entity.dart';

class NotificationRepository {
  final ApiInterface _api = ApiInterface();

  /// The broadcast stream for received notifications
  final StreamController<NotificationEntity> didReceiveLocalNotificationStream =
      StreamController<NotificationEntity>.broadcast();

  /// The broadcast stream for selected notifications
  final StreamController<RemoteMessage> selectNotificationStream =
      StreamController<RemoteMessage>.broadcast();

  /// This method send a notify click on push event to Dito
  ///
  /// [notification] - Notification object.
  Future<bool> click(NotificationEntity notification) async {
    // Otherwise, send the event to the Dito API
    final activities = [ApiActivities().notificationClick(notification)];

    return await _api.createRequest(activities).call();
  }

  /// This method send a notify received push event to Dito
  ///
  /// [notification] - Notification object.
  Future<bool> received(NotificationEntity notification) async {
    // Otherwise, send the event to the Dito API
    final activities = [ApiActivities().notificationReceived(notification)];

    return await _api.createRequest(activities).call();
  }
}
