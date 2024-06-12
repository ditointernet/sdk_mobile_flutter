import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../data/dito_api.dart';
import '../user/user_interface.dart';

class NotificationRepository {
  final DitoApi _api = DitoApi();
  final UserInterface _userInterface = UserInterface();

  /// This method initializes FirebaseMessaging
  Future<void> initializeFirebaseMessaging(
      Function(RemoteMessage) onMessage) async {
    await Firebase.initializeApp();

// por que só para android?
    if (Platform.isAndroid) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }

// parece não ter utilidade https://firebase.flutter.dev/docs/messaging/notifications/#handling-interaction
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      onMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(onMessage);

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              badge: true, sound: true, alert: true);
    }

    /// Shows the message when FCM payload is received
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  /// This method asks for permission to show the notifications.
  ///
  /// Returns a bool.
  Future<bool> checkPermissions() async {
    var settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// This method get the mobile token for push notifications.
  ///
  /// Returns a String or null.
  Future<String?> getFirebaseToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  /// This method registers a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be registered.
  /// Returns an http.Response.
  Future<http.Response> registryMobileToken(String token) async {
    return await _api.registryMobileToken(token, _userInterface.data);
  }

  /// This method removes a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be removed.
  /// Returns an http.Response.
  Future<http.Response> removeMobileToken(String token) async {
    return await _api.removeMobileToken(token, _userInterface.data);
  }
}
