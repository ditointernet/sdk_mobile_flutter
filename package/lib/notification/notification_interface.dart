import 'dart:async';
import 'dart:convert';

import 'package:dito_sdk/notification/notification_events.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/dito_api.dart';
import 'notification_entity.dart';
import 'notification_repository.dart';
import 'notification_controller.dart';

/// NotificationInterface is an interface for communication with the notification repository and notification controller
class NotificationInterface {
  final NotificationRepository _repository = NotificationRepository();
  final NotificationController _controller = NotificationController();
  final NotificationEvents _notificationEvents = NotificationEvents();
  final DitoApi _api = DitoApi();

  /// The broadcast stream for received notifications
  final StreamController<NotificationEntity>
      _didReceiveLocalNotificationStream =
      StreamController<NotificationEntity>.broadcast();

  /// The broadcast stream for selected notifications
  final StreamController<DataPayload> _selectNotificationStream =
      StreamController<DataPayload>.broadcast();

  /// This method initializes notification controller and notification repository.
  /// Start listening to notifications
  Future<void> initialize() async {
    await _repository.initializeFirebaseMessaging(onMessage);
    await _controller.initialize(onSelectNotification);
    _listenStream();
  }

  // This method turns off the streams when this class is unmounted
  void dispose() {
    _didReceiveLocalNotificationStream.close();
    _selectNotificationStream.close();
  }

  // This method initializes the listeners on streams
  _listenStream() {
    _didReceiveLocalNotificationStream.stream
        .listen((NotificationEntity receivedNotification) {
      _controller.showNotification(receivedNotification);
    });
    _selectNotificationStream.stream.listen((DataPayload data) async {
      _notificationEvents.stream.fire(MessageClickedEvent(data));

      final notificationId = data.notification;

      // Only sends the event if the message is linked to a notification
      if (notificationId != null && notificationId.isNotEmpty) {
        await _api.openNotification(
            notificationId, data.identifier, data.reference);
      }
    });
  }

  /// This method is a handler for new remote messages.
  /// Check permissions and add notification to the stream.
  ///
  /// [message] - RemoteMessage object.
  Future<void> onMessage(RemoteMessage message) async {
    if (message.data["data"] == null) {
      if (kDebugMode) {
        print("Data is not defined: ${message.data}");
      }
    }

    final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

    final messagingAllowed = await _repository.checkPermissions();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;

    if (messagingAllowed && notification.details.message.isNotEmpty) {
      _didReceiveLocalNotificationStream.add((NotificationEntity(
          id: message.hashCode,
          title: notification.details.title ?? appName,
          body: notification.details.message,
          payload: notification)));
    }
  }

  /// This method adds a selected notification to stream
  ///
  /// [data] - DataPayload object.
  Future<void> onSelectNotification(DataPayload? data) async {
    if (data != null) {
      _selectNotificationStream.add(data);
    }
  }

  /// This method registers a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be registered.
  /// Returns an http.Response.
  registryToken(String? token) async {
    String? newToken = token;
    newToken ??= await _repository.getFirebaseToken();
    if (newToken != null) _repository.registryToken(newToken);
  }

  /// This method removes a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be removed.
  /// Returns an http.Response.
  removeToken(String? token) async {
    String? newToken = token;
    newToken ??= await _repository.getFirebaseToken();
    if (newToken != null) _repository.removeToken(newToken);
  }
}
