library dito_sdk;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'data/dito_api.dart';
import 'event/event_entity.dart';
import 'event/event_interface.dart';
import 'notification/notification_interface.dart';
import 'user/user_entity.dart';
import 'user/user_interface.dart';

/// DitoSDK is a singleton class that provides various methods to interact with Dito API
/// and manage user data, events, and push notifications.
class DitoSDK {
  final DitoApi _api = DitoApi();
  final UserInterface _userInterface = UserInterface();
  final EventInterface _eventInterface = EventInterface();
  final NotificationInterface _notificationInterface = NotificationInterface();

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  /// This get method provides an interface for communication with a User entity.
  /// Returns an instance of UserInterface class.
  UserInterface get user => _userInterface;

  /// This method initializes the SDK with the provided API key and secret key.
  /// It also initializes the NotificationService and assigns API key and SHA1 signature.
  ///
  /// [apiKey] - The API key for the Dito platform.
  /// [secretKey] - The secret key for the Dito platform.
  void initialize({required String apiKey, required String secretKey}) async {
    _api.setKeys(apiKey, secretKey);
  }

  /// This method initializes the push notification service using Firebase.
  Future<void> initializePushNotificationService() async {
    await _notificationInterface.initialize();
  }

  /// This method enables saving and sending user data to the Dito API.
  ///
  /// [user] - UserEntity object.
  /// Returns a boolean indicating success.
  Future<bool> identify(UserEntity user) async {
    final result = await _userInterface.identify(user);
    return result;
  }

  /// This method tracks an event with optional revenue and custom data.
  ///
  /// [eventName] - The name of the event.
  /// [revenue] - Optional revenue associated with the event.
  /// [customData] - Optional custom data associated with the event.
  /// Returns a bool.
  Future<bool> trackEvent({
    required String eventName,
    double? revenue,
    Map<String, dynamic>? customData,
  }) async {
    final event = EventEntity(
        eventName: eventName, customData: customData, revenue: revenue);

    return await _eventInterface.trackEvent(event);
  }

  /// This method is a handler for manage messages in the background.
  /// It initializes Firebase and Dito, then push the message.
  Future<void> onBackgroundMessageHandler(RemoteMessage message,
      {required String apiKey, required String secretKey}) async {
    _api.setKeys(apiKey, secretKey);
    await Firebase.initializeApp();
    await _notificationInterface.initialize();
    return await _notificationInterface.onMessage(message);
  }
}
