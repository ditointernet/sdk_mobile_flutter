import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../user/user_interface.dart';
import 'notification_controller.dart';
import 'notification_entity.dart';
import 'notification_events.dart';
import 'notification_repository.dart';

/// NotificationInterface is an interface for communication with the notification repository and notification controller
class NotificationInterface {
  late void Function(RemoteMessage message) onMessageClick;
  final NotificationRepository _repository = NotificationRepository();
  final NotificationController _controller = NotificationController();
  final NotificationEvents _notificationEvents = NotificationEvents();
  final UserInterface _userInterface = UserInterface();
  bool initialized = false;

  /// Gets the current FCM token for the device.
  ///
  /// Returns the token as a String or null if not available.
  get token => FirebaseMessaging.instance.getToken();

  /// This method initializes notification controller and notification repository.
  /// Start listening to notifications
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      throw 'Firebase not initialized';
    }

    if (initialized) return;

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              badge: true, sound: true, alert: true);
    }

    FirebaseMessaging.onMessage.listen(onMessage);

    _handleToken();

    await _controller.initialize(onSelectNotification);
    _listenStream();
    initialized = true;
  }

  void _handleToken() async {
    _userInterface.data.token = await token;
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _userInterface.data.token = token;
      _userInterface.token.pingToken(token);
    }).onError((err) {
      if (kDebugMode) {
        print('Error getting token: $err');
      }
    });
  }

  // This method turns off the streams when this class is unmounted
  void dispose() {
    _repository.didReceiveLocalNotificationStream.close();
    _repository.selectNotificationStream.close();
  }

  // This method initializes the listeners on streams
  _listenStream() {
    _repository.didReceiveLocalNotificationStream.stream
        .listen((NotificationEntity receivedNotification) async {
      _controller.showNotification(receivedNotification);
      await _repository.received(NotificationEntity(
          reference: receivedNotification.reference,
          identifier: receivedNotification.identifier,
          notification: receivedNotification.notification));
    });

    _repository.selectNotificationStream.stream
        .listen((RemoteMessage message) async {
      _notificationEvents.stream.fire(MessageClickedEvent(message));

      final data = message.data;
      final notification = NotificationEntity(
          notification: data["notification"],
          identifier: data["identifier"]!,
          reference: data["reference"]);

      await _repository.click(notification);
      onMessageClick(message);
    });
  }

  /// This method is a handler for new remote messages.
  /// Check permissions and add notification to the stream.
  ///
  /// [message] - RemoteMessage object.
  Future<void> onMessage(RemoteMessage message) async {
    if (message.data.isEmpty) {
      if (kDebugMode) {
        print("Data is not defined: $message");
      }
    }

    final notification = NotificationEntity.fromMap(message.toMap());
    final messagingAllowed = await _checkPermissions();

    if (messagingAllowed && notification.details?.message != null) {
      _repository.received(notification);
      _repository.didReceiveLocalNotificationStream.add(notification);
    }
  }

  /// This method send a notify received push event to Dito
  ///
  /// [notificationId] - DataPayload object.
  Future<void> received(
          String notification, String identifier, String reference) =>
      _repository.received(NotificationEntity(
          reference: reference,
          identifier: identifier,
          notification: notification));

  /// This method send a notify received push event to Dito
  ///
  /// [notificationId] - DataPayload object.
  Future<void> click(
          String notification, String identifier, String reference) =>
      _repository.click(NotificationEntity(
          reference: reference,
          identifier: identifier,
          notification: notification));

  /// Requests permission to show notifications.
  ///
  /// Returns a boolean indicating if permission was granted.
  Future<bool> _checkPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission();

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// This method adds a selected notification to stream
  ///
  /// [message] - DataPayload object.
  void onSelectNotification(RemoteMessage message) {
    _repository.selectNotificationStream.add(message);
  }
}
