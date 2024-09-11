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

/// `NotificationInterface` manages notifications, handling initialization, token management,
/// and listening for notification events. It integrates with Firebase Messaging and custom notification flows.
class NotificationInterface {
  /// Callback to be invoked when a notification is clicked.
  late void Function(RemoteMessage message) onMessageClick;

  /// Notification repository to manage notification-related data.
  final NotificationRepository _repository = NotificationRepository();

  /// Controller to manage notification display and actions.
  final NotificationController _controller = NotificationController();

  /// Manages notification events, such as when a notification is clicked.
  final NotificationEvents _notificationEvents = NotificationEvents();

  /// Interface for accessing user-related data, like user tokens.
  final UserInterface _userInterface = UserInterface();

  /// A flag to ensure initialization is only performed once.
  bool initialized = false;

  /// Retrieves the current Firebase Messaging token.
  get token => FirebaseMessaging.instance.getToken();

  /// Initializes the notification interface, including Firebase Messaging,
  /// setting up token management, and listening for notification events.
  Future<void> initialize() async {
    // Ensure Firebase is initialized before proceeding.
    if (Firebase.apps.isEmpty) {
      throw 'Firebase not initialized';
    }

    // Return if already initialized to avoid redundant setup.
    if (initialized) return;

    // Enable automatic initialization of Firebase Messaging.
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // For iOS, set notification presentation options.
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              badge: true, sound: true, alert: true);
    }

    // Listen for incoming notifications when the app is in the foreground.
    FirebaseMessaging.onMessage.listen(onMessage);

    // Handle the Firebase Messaging token for the current user.
    _handleToken();

    // Initialize the notification controller and handle notification selection.
    await _controller.initialize(onSelectNotification);

    // Start listening for notification streams.
    _listenStream();

    // Mark as initialized to prevent reinitialization.
    initialized = true;
  }

  /// Handles retrieving and updating the Firebase Messaging token for the user.
  /// Listens for token refreshes and updates the user data and token repository.
  void _handleToken() async {
    // Assign the current token to the user's data.
    _userInterface.data.token = await token;

    // Listen for token refresh events and update the user data and token repository.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _userInterface.data.token = token;
      _userInterface.token.pingToken(token); // Send token to backend.
    }).onError((err) {
      if (kDebugMode) {
        print('Error getting token: $err');
      }
    });
  }

  /// Disposes of notification streams, ensuring that all resources are released.
  void dispose() {
    _repository.didReceiveLocalNotificationStream.close();
    _repository.selectNotificationStream.close();
  }

  /// Listens for events in the notification streams and triggers appropriate actions.
  _listenStream() {
    // Listen for locally received notifications and handle their display and storage.
    _repository.didReceiveLocalNotificationStream.stream
        .listen((NotificationEntity receivedNotification) async {
      // Show the notification through the controller.
      _controller.showNotification(receivedNotification);

      // Mark the notification as received in the repository.
      await _repository.received(NotificationEntity(
          reference: receivedNotification.reference,
          identifier: receivedNotification.identifier,
          notification: receivedNotification.notification));
    });

    // Listen for selected notifications (e.g., when a user taps on a notification).
    _repository.selectNotificationStream.stream
        .listen((RemoteMessage message) async {
      // Trigger a click event in the notification events system.
      _notificationEvents.stream.fire(MessageClickedEvent(message));

      final data = message.data;
      final notification = NotificationEntity(
          notification: data["notification"],
          identifier: data["identifier"]!,
          reference: data["reference"]);

      // Mark the notification as clicked in the repository.
      await _repository.click(notification);

      // Trigger the onMessageClick callback when the notification is selected.
      onMessageClick(message);
    });
  }

  /// Handles incoming messages from Firebase and triggers appropriate actions based on the content.
  ///
  /// [message] - The incoming [RemoteMessage] from Firebase.
  Future<void> onMessage(RemoteMessage message) async {
    // Log if no data is provided in the notification message.
    if (message.data.isEmpty) {
      if (kDebugMode) {
        print("Data is not defined: $message");
      }
    }

    // Parse the message into a notification entity.
    final notification = NotificationEntity.fromMap(message.toMap());

    // Mark the notification as received.
    _repository.received(notification);

    // Check if the user has granted permission for notifications.
    final messagingAllowed = await _checkPermissions();

    // If allowed and the message has valid details, process and display the notification.
    if (messagingAllowed && notification.details?.message != null) {
      _repository.didReceiveLocalNotificationStream
          .add(notification); // Add to the local stream.
    }
  }

  /// Marks a notification as received in the repository.
  ///
  /// [notification] - The notification content.
  /// [identifier] - A unique identifier for the notification.
  /// [reference] - A reference to the notification.
  Future<void> received(
          String notification, String identifier, String reference) =>
      _repository.received(NotificationEntity(
          reference: reference,
          identifier: identifier,
          notification: notification));

  /// Marks a notification as clicked in the repository.
  ///
  /// [notification] - The notification content.
  /// [identifier] - A unique identifier for the notification.
  /// [reference] - A reference to the notification.
  /// [notificationLogId] - notification trigger id.
  /// [details] - The DetailsEntity content.
  /// Returns a `Future<bool>` that completes with `true` if the event was tracked successfully,
  /// or `false` if there was an error.
  Future<bool> click(
      {required String notification,
        required String identifier,
        String? reference,
        String? notificationLogId,
        DetailsEntity? details}) async {
    try {
      return await _repository.click(NotificationEntity(
          identifier: identifier,
          notification: notification,
          reference: reference,
          notificationLogId: notificationLogId,
          details: details,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking click event: $e'); // Log the error in debug mode.
      }
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
