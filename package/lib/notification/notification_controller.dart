import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'notification_entity.dart';

class NotificationController {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  Function(NotificationEntity)? _selectNotification;

  /// Android-specific notification details.
  AndroidNotificationDetails androidNotificationDetails =
      const AndroidNotificationDetails(
    'dito_notifications', // Notification channel ID.
    'Notifications sent by Dito', // Notification channel name.
    channelDescription:
        'Notifications sent by Dito', // Notification channel description.
    importance: Importance.max, // Maximum importance level.
    priority: Priority.max, // Maximum priority level.
    enableVibration: true, // Enable vibration.
  );

  /// iOS-specific notification details.
  DarwinNotificationDetails darwinNotificationDetails =
      const DarwinNotificationDetails(
    presentAlert: true, // Display alert.
    presentBadge: true, // Display badge.
    presentSound: true, // Play sound.
    presentBanner: true, // Display banner.
  );

  NotificationController._internal();

  static final NotificationController _instance =
      NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  /// Initializes the local notifications plugin.
  ///
  /// [onSelectNotification] - Callback function to handle notification selection.
  Future<void> initialize(
      Function(NotificationEntity) selectNotification) async {
    _selectNotification = selectNotification;
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: android, iOS: ios);

    await localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onTapNotification);

    await _setupAndroidChannel();
  }

  /// Sets up the Android notification channel.
  Future<void> _setupAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dito_notifications', // Channel ID.
      'Notifications sent by Dito', // Channel name.
      importance: Importance.max, // Maximum importance level.
    );

    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Displays a notification.
  ///
  /// [notification] - NotificationEntity object containing notification details.
  void showNotification(NotificationEntity notification) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;

    final displayInfo = NotificationDisplayEntity(
        id: notification.hashCode,
        notificationId: notification.notification,
        title: notification.details?.title ?? appName,
        body: notification.details?.message ?? "",
        image: notification.details?.image,
        data: notification.details?.toJson());

    localNotificationsPlugin.show(
      displayInfo.id, // Notification ID.
      displayInfo.title, // Notification title.
      displayInfo.body, // Notification body.

      NotificationDetails(
          android: androidNotificationDetails, iOS: darwinNotificationDetails),
      payload:
          jsonEncode(notification.toJson()), // Notification payload.
    );
  }

  /// Handles notification selection by the user.
  ///
  /// [response] - NotificationResponse object containing response details.
  Future<void> onTapNotification(NotificationResponse? response) async {
    final payload = response?.payload;

    if (payload != null && payload.isNotEmpty) {
      if (_selectNotification != null) _selectNotification!(NotificationEntity.fromPayload(jsonDecode(payload)));
    }
  }
}
