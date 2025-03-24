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
  Function(Map<String, dynamic>)? onClick;

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
    _setupNotifications();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions();

    await checkPermissions();
    await _initializeMessages();
  }

  Future<String?> getDeviceFirebaseToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _initializeMessages() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.didNotificationLaunchApp) {
      onClick!(notificationAppLaunchDetails.notificationResponse
          as Map<String, dynamic>);
    }

    FirebaseMessaging.onMessage.listen(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => selectNotificationStream.add(message.data["data"]),
    );
  }

  void handleMessage(RemoteMessage message) {
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
        onDidReceiveNotificationResponse: onClickNotification);
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

        if (onClick != null) {
          onClick!(data.details.toJson());
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

  Future<void> onClickNotification(NotificationResponse? response) async {
    if (response?.payload != null) {
      selectNotificationStream.add(response?.payload);

      if (onClick != null) {
        onClick!(jsonDecode(response!.payload!)["details"]);
      }
    }
  }
}
