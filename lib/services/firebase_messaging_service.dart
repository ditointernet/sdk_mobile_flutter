import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dito_sdk/entity/custom_notification.dart';
import 'package:dito_sdk/entity/data_payload.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';


import 'package:dito_sdk/dito_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  bool _messagingAllowed = false;
  late String _appName;
  late DitoSDK _dito;
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  final StreamController<CustomNotification> didReceiveLocalNotificationStream =
      StreamController<CustomNotification>.broadcast();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  final AndroidNotificationDetails androidDetails =
      const AndroidNotificationDetails(
    'dito_notifications',
    'Notifications sended by Dito',
    channelDescription: 'Notifications sended by Dito',
    importance: Importance.max,
    priority: Priority.max,
    enableVibration: true,
  );

  final DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
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
    _setupNotifications();

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
      didReceiveLocalNotificationStream.add(
          CustomNotification(
              id: message.hashCode,
              title: _appName,
              body: notification.details.message,
              payload: notification));
    }
  }

  addNotificationToStream(CustomNotification notification) {
    didReceiveLocalNotificationStream.add(notification);
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

  _setupNotifications() async {
    await _initializeNotifications();
    await _setupAndroidChannel();
    _listenStream();
  }

  _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(android: android, iOS: ios);

    await localNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onTapNotification);
  }

  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
  }

  _listenStream() {
    didReceiveLocalNotificationStream.stream
        .listen((CustomNotification receivedNotification) {
      showLocalNotification(receivedNotification);
    });
    selectNotificationStream.stream.listen((String? payload) async {
      if (payload != null) {
        final data = DataPayload.fromJson(jsonDecode(payload));
        await _dito.openNotification(
            notificationId: data.notification.toString(),
            identifier: data.reference.toString(),
            reference: data.reference.toString());
      }
    });
  }

  showLocalNotification(CustomNotification notification) {
    localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(notification.payload?.toJson()),
    );
  }

  Future<void> onTapNotification(NotificationResponse? response) async {
    if (response?.payload != null) {
      selectNotificationStream.add(response?.payload);
    }
  }
}
