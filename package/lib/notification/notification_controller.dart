import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_entity.dart';

class NotificationController {
  final Function(DataPayload) onSelectNotification;
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;

  NotificationController({required this.onSelectNotification});

  AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
    'dito_notifications',
    'Notifications sended by Dito',
    channelDescription: 'Notifications sended by Dito',
    importance: Importance.max,
    priority: Priority.max,
    enableVibration: true,
  );

  DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true);

  /// This method initializes localNotificationsPlugin
  initialize() async {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: android, iOS: ios);

    await localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onTapNotification);

// Precisa completar a config no app? https://firebase.flutter.dev/docs/messaging/notifications/#notification-channels
    await _setupAndroidChannel();
  }

  _setupAndroidChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'dito_notifications',
      'Notifications sended by Dito',
      importance: Importance.max,
    );

    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// This method uses local notifications plugin to show messages on the screen
  ///
  /// [notification] - NotificationEntity object
  showNotification(NotificationEntity notification) {
    localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(notification.payload?.toJson()),
    );
  }

  /// This method is called when user clicks on the notification
  ///
  /// [response] - NotificationResponse object
  Future<void> onTapNotification(NotificationResponse? response) async {
    final payload = response?.payload;

    if (payload != null && payload.isNotEmpty) {
      final data = DataPayload.fromJson(jsonDecode(payload));

      onSelectNotification(data);
    }
  }
}
