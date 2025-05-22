import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../dito_sdk.dart';
import '../entity/data_payload.dart';

class NotificationService {
  bool _messagingAllowed = false;
  late DitoSDK _dito;
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  Function(String)? onClick;

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

  NotificationService(DitoSDK dito) {
    _dito = dito;
  }

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    localNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    await checkPermissions();
    await _initializeNotifications();
    await _setupAndroidChannel();
    await _initializeMessages();
  }

  Future<String?> getDeviceFirebaseToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _initializeMessages() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleOnNotificationClick);
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _handleOnNotificationClick(RemoteMessage message) async {
    final data = DataPayload.fromJson(message.data);
    await _handleClick(data);
  }

  Future<void> _handleClick(DataPayload data) async {
    if (data.notification.isNotEmpty) {
      await _dito.openNotification(
          notificationId: data.notification,
          identifier: data.user_id,
          reference: data.reference);
    }

    if (onClick != null) {
      onClick!(data.link);
    }
  }

  void _handleMessage(RemoteMessage message) async {
    if (_dito.user.isNotValid) {
      _dito.identify(userID: message.data["reference"]);
      await _dito.identifyUser();
    }

    await _dito.trackEvent(
        eventName:
            "receive-${Platform.isIOS ? "ios" : "android"}-notification");

    await _showLocalNotification(message);
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

  _setupNotifications() async {}

  _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: android, iOS: ios);

    await localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (message) async {
      final data = DataPayload.fromJson(jsonDecode(message.payload!));

      await _handleClick(data);
    });
  }

  setAndroidDetails(AndroidNotificationDetails details) {
    androidDetails = details;
  }

  setIosDetails(DarwinNotificationDetails details) {
    iosDetails = details;
  }

  _showLocalNotification(RemoteMessage message) async {
    await localNotificationsPlugin.show(
      message.hashCode % 2147483647,
      message.notification?.title ?? "",
      message.notification?.body ?? "",
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> checkPermissions() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.requestPermission();
      _messagingAllowed =
          (settings.authorizationStatus == AuthorizationStatus.authorized);
    }
  }
}
