import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import '../data/dito_api.dart';
import '../user/user_interface.dart';

class NotificationRepository {
  final DitoApi _ditoApi = DitoApi();
  final UserInterface _userInterface = UserInterface();

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

// alterar só para iOS? https://firebase.flutter.dev/docs/messaging/notifications/#ios-configuration
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            badge: true, sound: true, alert: true);

    FirebaseMessaging.onMessage.listen(onMessage);
  }

  Future<bool> checkPermissions() async {
    var settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getFirebaseToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Future<http.Response> registryMobileToken(String token) async {
    return await _ditoApi.registryMobileToken(token, _userInterface.data);
  }

  Future<http.Response> removeMobileToken(String token) async {
    return await _ditoApi.removeMobileToken(token, _userInterface.data);
  }
}
