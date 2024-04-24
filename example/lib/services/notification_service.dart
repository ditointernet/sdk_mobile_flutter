import 'dart:async';
import 'dart:convert';

import 'package:dito_sdk/dito_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sdk_test/services/custom_notification.dart';
import 'package:flutter_sdk_test/services/data_payload.dart';



class NotificationService {
  final DitoSDK _dito;
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  final StreamController<CustomNotification> didReceiveLocalNotificationStream =
      StreamController<CustomNotification>.broadcast();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

    final AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'dito_notifications',
      'Notifications sended by Dito',
      channelDescription: 'Notifications sended by Dito',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
    );

  final DarwinNotificationDetails iosDetails =  const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true);

  NotificationService(this._dito) {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _setupNotifications();
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
        final data = DataPayload.fromJson( jsonDecode(payload));
        await _dito.openNotification(
            notificationId: data.notification.toString(),
            identifier: data.reference.toString(),
            reference: data.reference.toString()
        );
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
    if (response?.payload != null){
      selectNotificationStream.add(response?.payload);
    }
  }

}
