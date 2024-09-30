import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../user/user_interface.dart';
import '../utils/logger.dart';
import 'notification_controller.dart';
import 'notification_entity.dart';
import 'notification_events.dart';
import 'notification_repository.dart';

/// `NotificationInterface` manages notifications, handling initialization, token management,
/// and listening for notification events. It integrates with Firebase Messaging and custom notification flows.
class NotificationInterface {
  late void Function(RemoteMessage message) onMessageClick;
  final NotificationRepository _repository = NotificationRepository();
  final NotificationController _controller = NotificationController();
  final NotificationEvents _notificationEvents = NotificationEvents();
  final UserInterface _userInterface = UserInterface();
  bool initialized = false;
  Future<String?> get token async =>
      await FirebaseMessaging.instance.getToken();

  /// Initializes the notification interface, including Firebase Messaging,
  /// setting up token management, and listening for notification events.
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      throw 'Firebase not initialized';
    }

    if (initialized) return;
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // For iOS, set notification presentation options.
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
      loggerError(err);
    });
  }

  /// Disposes of notification streams, ensuring that all resources are released.
  void dispose() {
    _repository.didReceiveLocalNotificationStream.close();
    _repository.selectNotificationStream.close();
  }

  /// Listens for events in the notification streams and triggers appropriate actions.
  _listenStream() {
    _repository.didReceiveLocalNotificationStream.stream
        .listen((NotificationEntity receivedNotification) async {
      _controller.showNotification(receivedNotification);

      await _repository.received(NotificationEntity(
          notification: receivedNotification.notification,
          notificationLogId: receivedNotification.notificationLogId,
          contactId: receivedNotification.contactId,
          name: receivedNotification.name));
    });

    _repository.selectNotificationStream.stream
        .listen((RemoteMessage message) async {
      _notificationEvents.stream.fire(MessageClickedEvent(message));

      final data = message.data;
      final notification = NotificationEntity(
          notification: data["notification"],
          notificationLogId: data["notificationLogId"]!,
          contactId: data["contactId"],
          name: data["name"]);

      await _repository.click(notification);
      onMessageClick(message);
    });
  }

  /// Handles incoming messages from Firebase and triggers appropriate actions based on the content.
  ///
  /// [message] - The incoming [RemoteMessage] from Firebase.
  Future<void> onMessage(RemoteMessage message) async {
    if (message.data.isEmpty) {
      loggerError("Data is not defined: $message");
    }

    final notification = NotificationEntity.fromMap(message.toMap());

    _repository.received(notification);

    final messagingAllowed = await _checkPermissions();

    if (messagingAllowed && notification.details?.message != null) {
      _repository.didReceiveLocalNotificationStream.add(notification);
    }
  }

  /// Marks a notification as received in the repository.
  ///
  /// [notification] - The notification identifier.
  /// [notificationLogId] - The dispatch identifier.
  /// [contactId] - The contact identifier.
  /// [name] - The name of notification.
  /// Returns a `Future<bool>` that completes with `true` if the event was tracked successfully,
  /// or `false` if there was an error.
  Future<bool> received(
      {required String notification,
      String? notificationLogId,
      String? contactId,
      String? name}) async {
    try {
      return await _repository.received(NotificationEntity(
          notification: notification,
          notificationLogId: notificationLogId,
          contactId: contactId,
          name: name));
    } catch (e) {
      loggerError(
          'Error tracking click event: $e'); // Log the error in debug mode.

      return false; // Return false if there was an error.
    }
  }

  /// Marks a notification as clicked in the repository.
  ///
  /// [notification] - The notification identifier.
  /// [notificationLogId] - The dispatch identifier.
  /// [contactId] - The contact identifier.
  /// [name] - The name of notification.
  /// [createdAt] - The navigation event creation time, defaults to the current UTC time if not provided.
  /// Returns a `Future<bool>` that completes with `true` if the event was tracked successfully,
  /// or `false` if there was an error.
  Future<bool> click(
      {required String notification,
      String? notificationLogId,
      String? contactId,
      String? name,
      String? createdAt}) async {
    try {
      DateTime localDateTime = DateTime.now();
      DateTime utcDateTime = localDateTime.toUtc();

      return await _repository.click(NotificationEntity(
        notification: notification,
        notificationLogId: notificationLogId,
        contactId: contactId,
        name: name,
        createdAt: createdAt ??
            utcDateTime
                .toIso8601String(), // Default to current UTC time if not provided.
      ));
    } catch (e) {
      loggerError(
          'Error tracking click event: $e'); // Log the error in debug mode.

      return false; // Return false if there was an error.
    }
  }

  /// Checks if the user has granted permissions for receiving notifications.
  ///
  /// Returns `true` if notifications are authorized, `false` otherwise.
  Future<bool> _checkPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Handles notification selection events and triggers appropriate actions.
  ///
  /// [message] - The selected [RemoteMessage] from Firebase.
  void onSelectNotification(RemoteMessage message) {
    _repository.selectNotificationStream.add(message);
  }
}
