import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/dito_api.dart';
import '../user/user_interface.dart';
import 'notification_controller.dart';
import 'notification_entity.dart';
import 'notification_events.dart';
import 'notification_repository.dart';

/// NotificationInterface is an interface for communication with the notification repository and notification controller
class NotificationInterface {
  late void Function(DataPayload payload) onMessageClick;
  final NotificationRepository _repository = NotificationRepository();
  final NotificationController _controller = NotificationController();
  final NotificationEvents _notificationEvents = NotificationEvents();
  final DitoApi _api = DitoApi();
  final UserInterface _userInterface = UserInterface();

  /// This method initializes notification controller and notification repository.
  /// Start listening to notifications
  Future<void> initialize(bool background) async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              badge: true, sound: true, alert: true);
    }

    if (!background) FirebaseMessaging.onMessage.listen(onMessage);

    _handleToken();

    await _controller.initialize(onSelectNotification);
    _listenStream();
  }

  void _handleToken() async {
    _userInterface.data.token = await getFirebaseToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final lastToken = _userInterface.data.token;
      if (lastToken != token) {
        if (lastToken != null && lastToken.isNotEmpty) {
          removeToken(lastToken);
        }
        registryToken(token);
        _userInterface.data.token = token;
      }
    }).onError((err) {
      if (kDebugMode) {
        print('Error getting token: $err');
      }
    });
  }

  /// Gets the current FCM token for the device.
  ///
  /// Returns the token as a String or null if not available.
  Future<String?> getFirebaseToken() => FirebaseMessaging.instance.getToken();

  // This method turns off the streams when this class is unmounted
  void dispose() {
    _repository.didReceiveLocalNotificationStream.close();
    _repository.selectNotificationStream.close();
  }

  // This method initializes the listeners on streams
  _listenStream() {
    _repository.didReceiveLocalNotificationStream.stream
        .listen((NotificationEntity receivedNotification) async {
      _controller.showNotification(receivedNotification);
      await notifyReceivedNotification(receivedNotification.notificationId!);
    });
    _repository.selectNotificationStream.stream
        .listen((DataPayload data) async {
      _notificationEvents.stream.fire(MessageClickedEvent(data));

      // Only sends the event if the message is linked to a notification
      if (data.notification != null &&
          data.identifier != null &&
          data.reference != null) {
        await _api.openNotification(
            data.notification!, data.identifier!, data.reference!);

        onMessageClick(data);
      }
    });
  }

  /// This method is a handler for new remote messages.
  /// Check permissions and add notification to the stream.
  ///
  /// [message] - RemoteMessage object.
  Future<void> onMessage(RemoteMessage message) async {
    if (message.data.isEmpty) {
      if (kDebugMode) {
        print("Data is not defined: $message");
      }
    }

    final notification = DataPayload.fromMap(message.toMap());
    final messagingAllowed = await _checkPermissions();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;

    if (messagingAllowed && notification.details.message.isNotEmpty) {
      _repository.didReceiveLocalNotificationStream.add((NotificationEntity(
          id: message.hashCode,
          notificationId: notification.notification,
          title: notification.details.title ?? appName,
          body: notification.details.message,
          image: notification.details.image,
          payload: notification)));
    }
  }

  /// This method send a notify received push event to Dito
  ///
  /// [notificationId] - DataPayload object.
  Future<void> notifyReceivedNotification(String notificationId) =>
      _repository.notifyReceivedNotification(notificationId);

  /// This method send a open unsubscribe from notification event to Dito
  Future<void> unsubscribeFromNotifications() =>
      _repository.unsubscribeFromNotifications();

  /// This method send a open deeplink event to Dito
  Future<void> notifyOpenDeepLink(String notificationId) =>
      _repository.notifyOpenDeepLink(notificationId);

  /// Requests permission to show notifications.
  ///
  /// Returns a boolean indicating if permission was granted.
  Future<bool> _checkPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// This method adds a selected notification to stream
  ///
  /// [data] - DataPayload object.
  Future<void> onSelectNotification(DataPayload? data) async {
    if (data != null) {
      _repository.selectNotificationStream.add(data);
    }
  }

  /// This method registers a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be registered.
  /// Returns an http.Response.
  registryToken(String? token) async {
    String? newToken = token ?? await getFirebaseToken();
    if (newToken != null) _repository.registryToken(newToken);
  }

  /// This method removes a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be removed.
  /// Returns an http.Response.
  removeToken(String? token) async {
    String? newToken = token ?? await getFirebaseToken();
    if (newToken != null) _repository.removeToken(newToken);
  }
}
