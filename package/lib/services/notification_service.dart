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
      final dynamic reference = message.data["reference"];
      if (reference is String && reference.isNotEmpty) {
        _dito.identify(userID: reference);
        await _dito.identifyUser();
      }
    }

    final data = DataPayload.fromJson(message.data);

    final token = await _dito.notificationService().getDeviceFirebaseToken();

    await _dito.trackEvent(
        eventName:
            "receive-${Platform.isIOS ? "ios" : "android"}-notification",
        customData: {
          "canal": "mobile",
          "token": token ?? "",
          "id-disparo": data.log_id,
          "id-notificacao": data.notification,
          "nome_notificacao": data.notification_name,
          "provedor": "firebase",
          "sistema_operacional": Platform.isIOS ? "Apple iPhone" : "Android",
        });
  }

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

  Future<void> checkPermissions() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.requestPermission();
      _messagingAllowed =
          (settings.authorizationStatus == AuthorizationStatus.authorized);
    }
  }
}
