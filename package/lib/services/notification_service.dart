import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../dito_sdk.dart';
import '../entity/data_payload.dart';

class NotificationService {
  late DitoSDK _dito;
  Function(String)? onClick;

  NotificationService(DitoSDK dito) {
    _dito = dito;
  }

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    await checkPermissions();
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
    await _dito.trackEvent(
        eventName:
            "receive-${Platform.isIOS ? "ios" : "android"}-notification");
  }

  Future<void> checkPermissions() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.requestPermission();
    }
  }
}
