import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dito_sdk/entity/custom_notification.dart';
import 'package:dito_sdk/entity/data_payload.dart';
import 'package:dito_sdk/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FirebaseMessagingService {
  final NotificationService _notificationService;
  bool _messagingAllowed = false;
  late String _appName;
  FirebaseMessagingService(this._notificationService);

  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            badge: true, sound: true, alert: true);

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;

    await checkPermissions();
    _onMessage();
  }

  Future<String?> getDeviceFirebaseToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void handleMessage(RemoteMessage message) {
    if (message.data["data"] == null) {
      print("Data is not defined: ${message.data}");
    }

    final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

    if (_messagingAllowed && notification.details.message.isNotEmpty) {
      _notificationService.didReceiveLocalNotificationStream.add(
          CustomNotification(
              id: message.hashCode,
              title: _appName,
              body: notification.details.message,
              payload: notification));
    }
  }

  addNotificationToStream(CustomNotification notification) {
    _notificationService.didReceiveLocalNotificationStream.add(notification);
  }

  Future<void> checkPermissions() async {
    var settings = await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      await FirebaseMessaging.instance.requestPermission();
      settings = await FirebaseMessaging.instance.getNotificationSettings();
      _messagingAllowed =
          (settings.authorizationStatus == AuthorizationStatus.authorized);
    } else {
      _messagingAllowed = true;
    }
  }
}
