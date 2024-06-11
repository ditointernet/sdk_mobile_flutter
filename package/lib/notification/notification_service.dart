import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/dito_api.dart';
import 'notification_entity.dart';
import 'notification_repository.dart';
import 'notification_controller.dart';

class NotificationService {
  final NotificationRepository _repository = NotificationRepository();
  late NotificationController _controller;
  final DitoApi _ditoApi = DitoApi();

  final StreamController<NotificationEntity>
      _didReceiveLocalNotificationStream =
      StreamController<NotificationEntity>.broadcast();
  final StreamController<DataPayload> _selectNotificationStream =
      StreamController<DataPayload>.broadcast();

  Future<void> initialize() async {
    _controller =
        NotificationController(onSelectNotification: onSelectNotification);
    await _repository.initializeFirebaseMessaging(onMessage);
    await _controller.initialize();
    _listenStream();
  }

// continua exportando esse metodo?
  addNotificationToStream(NotificationEntity notification) {
    _didReceiveLocalNotificationStream.add(notification);
  }

  void dispose() {
    _didReceiveLocalNotificationStream.close();
    _selectNotificationStream.close();
  }

  _listenStream() {
    _didReceiveLocalNotificationStream.stream
        .listen((NotificationEntity receivedNotification) {
      _controller.showNotification(receivedNotification);
    });
    _selectNotificationStream.stream.listen((DataPayload data) async {
      final notificationId = data.notification;

      if (notificationId != null && notificationId.isNotEmpty) {
        await _ditoApi.openNotification(
            notificationId, data.identifier, data.reference);
      }
    });
  }

  Future<void> onMessage(RemoteMessage message) async {
    if (message.data["data"] == null) {
      if (kDebugMode) {
        print("Data is not defined: ${message.data}");
      }
    }

    final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

    final messagingAllowed = await _repository.checkPermissions();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;

    if (messagingAllowed && notification.details.message.isNotEmpty) {
      addNotificationToStream(NotificationEntity(
          id: message.hashCode,
          title: notification.details.title ?? appName,
          body: notification.details.message,
          payload: notification));
    }
  }

  Future<void> onSelectNotification(DataPayload? data) async {
    if (data != null) {
      _selectNotificationStream.add(data);
    }
  }

  Future<String?> getDeviceFirebaseToken() async {
    return _repository.getFirebaseToken();
  }

  registryMobileToken(String token) async {
    return await _repository.registryMobileToken(token);
  }

  removeMobileToken(String token) async {
    return await _repository.removeMobileToken(token);
  }
}
