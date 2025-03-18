import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../dito_sdk.dart';
import '../entity/custom_notification.dart';
import '../entity/data_payload.dart';

class NotificationService {
  bool _messagingAllowed = false;
  late DitoSDK _dito;
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  final StreamController<CustomNotification> didReceiveLocalNotificationStream =
      StreamController<CustomNotification>.broadcast();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  Function(Map<String, dynamic>)? _onTap;

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

  Future<void> initialize(Function(Map<String, dynamic>)? onTap) async {
    if (onTap != null) {
      _onTap = onTap;
    }

    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupNotifications();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            badge: true, sound: true, alert: true);

    await checkPermissions();
    _onMessage();
  }

  Future<String?> getDeviceFirebaseToken() async {
    if (Platform.isIOS) {
      return FirebaseMessaging.instance.getAPNSToken();
    } else {
      return FirebaseMessaging.instance.getToken();
    }
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
      didReceiveLocalNotificationStream.add(CustomNotification(
          id: message.hashCode,
          title: notification.details.title,
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

        if (data.notification.isNotEmpty) {
          await _dito.openNotification(
              notificationId: data.notification,
              identifier: data.identifier,
              reference: data.reference);
        }
      }
    });
  }

  setAndroidDetails(AndroidNotificationDetails details) {
    androidDetails = details;
  }

  setIosDetails(DarwinNotificationDetails details) {
    iosDetails = details;
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

      _onTap!(jsonDecode(response!.payload!)["details"]);
    }
  }
}
