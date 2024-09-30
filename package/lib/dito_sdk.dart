library dito_sdk;

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'api/dito_api_interface.dart';
import 'event/event_interface.dart';
import 'notification/notification_interface.dart';
import 'user/user_interface.dart';

/// DitoSDK is a singleton class that provides various methods to interact with Dito API
/// and manage user data, events, and push notifications.
class DitoSDK {
  final ApiInterface _api = ApiInterface();
  final UserInterface _userInterface = UserInterface();
  final EventInterface _eventInterface = EventInterface();
  final NotificationInterface _notificationInterface = NotificationInterface();
  final AppInfo _appInfo = AppInfo();

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  /// This get method provides an interface for communication with a User entity.
  /// Returns an instance of UserInterface class.
  UserInterface get user => _userInterface;

  /// This get method provides an interface for communication with a Notifications.
  /// Returns an instance of NotificationInterface class.
  NotificationInterface get notification => _notificationInterface;

  /// This get method provides an interface for communication with a Event.
  /// Returns an instance of EventInterface class.
  EventInterface get event => _eventInterface;

  /// This method initializes the SDK with the provided API key and secret key.
  /// It also initializes the NotificationService and assigns API key and SHA1 signature.
  ///
  /// [apiKey] - The API key for the Dito platform.
  /// [secretKey] - The secret key for the Dito platform.
  void initialize({required String apiKey, required String secretKey}) async {
    final packageInfo = !Platform.environment.containsKey('FLUTTER_TEST') ? await PackageInfo.fromPlatform(): null;
    _api.setKeys(apiKey, secretKey);
    _appInfo.platform = Platform.isAndroid ? 'Android' : 'Apple iPhone';
    _appInfo.sdkLang = "Flutter";
    _appInfo.sdkVersion = '2.0.0';
    _appInfo.sdkBuild = '1';
    _appInfo.build = packageInfo?.buildNumber ?? '1';
    _appInfo.version = packageInfo?.version ?? '1.0.0';
    _appInfo.id = packageInfo?.packageName ?? '';
  }

  /// This method initializes the push notification service using Firebase.
  Future<void> initializePushNotificationService() async {
    await _notificationInterface.initialize();
  }

  /// This method is a handler for manage messages in the background.
  /// It initializes Firebase and Dito, then push the message.
  void onBackgroundPushNotificationHandler(
      {required RemoteMessage message}) async {
    await initializePushNotificationService();
    await _notificationInterface.onMessage(message);
  }
}
