library dito_sdk;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'data/dito_api.dart';
import 'database.dart';
import 'entity/event.dart';
import 'services/notification_service.dart';
import 'user/user_interface.dart';
import 'user/user_entity.dart';

/// DitoSDK is a singleton class that provides various methods to interact with Dito API
/// and manage user data, events, and push notifications.
class DitoSDK {
  final UserInterface _userInterface = UserInterface();
  final DitoApi ditoApi = DitoApi();
  late NotificationService _notificationService;

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  /// This get method provides an interface for communication with a User entity.
  /// Returns an instance of UserInterface class.
  UserInterface get user => _userInterface;

  NotificationService notificationService() {
    return _notificationService;
  }

  /// This method initializes the SDK with the provided API key and secret key.
  /// It also initializes the NotificationService and assigns API key and SHA1 signature.
  ///
  /// [apiKey] - The API key for the Dito platform.
  /// [secretKey] - The secret key for the Dito platform.
  void initialize({required String apiKey, required String secretKey}) async {
    _notificationService = NotificationService(_instance);
    ditoApi.setKeys(apiKey, secretKey);
  }

  /// This method initializes the push notification service using Firebase.
  Future<void> initializePushNotificationService() async {
    await Firebase.initializeApp();
    await _notificationService.initialize();

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _notificationService.handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp
        .listen(_notificationService.handleMessage);
  }

  Future<void> _verifyPendingEvents() async {
    final database = LocalDatabase.instance;
    final events = await database.getEvents();

    if (events.isNotEmpty) {
      for (final event in events) {
        await ditoApi.trackEvent(event, user.data);
      }
      database.deleteEvents();
    }
  }

  /// This method enables saving and sending user data to the Dito API.
  ///
  /// [user] - UserEntity object.
  /// Returns a boolean indicating success.
  Future<bool> identify(UserEntity user) async {
    final result = await _userInterface.identify(user);
    await _verifyPendingEvents();
    return result;
  }

  /// This method tracks an event with optional revenue and custom data.
  ///
  /// [eventName] - The name of the event.
  /// [revenue] - Optional revenue associated with the event.
  /// [customData] - Optional custom data associated with the event.
  /// Returns an http.Response.
  Future<http.Response> trackEvent({
    required String eventName,
    double? revenue,
    Map<String, String>? customData,
  }) async {
    DateTime localDateTime = DateTime.now();
    DateTime utcDateTime = localDateTime.toUtc();
    String eventMoment = utcDateTime.toIso8601String();

    final event = Event(
        eventName: eventName,
        eventMoment: eventMoment,
        customData: customData,
        revenue: revenue);

    if (_userInterface.data.isNotValid) {
      final database = LocalDatabase.instance;
      await database.createEvent(event);
      return http.Response("", 200);
    }

    return await ditoApi.trackEvent(event, _userInterface.data);
  }

  /// This method registers a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be registered.
  /// Returns an http.Response.
  Future<http.Response> registryMobileToken({required String token}) async {
    return await ditoApi.registryMobileToken(token, _userInterface.data);
  }

  /// This method removes a mobile token from the push notification service.
  ///
  /// [token] - The mobile token to be removed.
  /// Returns an http.Response.
  Future<http.Response> removeMobileToken({required String token}) async {
    return await ditoApi.removeMobileToken(token, _userInterface.data);
  }

  /// This method opens a notification and sends its data to the Dito API.
  ///
  /// [notificationId] - The ID of the notification.
  /// [identifier] - The identifier for the notification.
  /// [reference] - The reference for the notification.
  /// Returns an http.Response.
  Future<http.Response> openNotification(
      {required String notificationId,
      required String identifier,
      required String reference}) async {
    return await ditoApi.openNotification(
        notificationId, identifier, reference);
  }
}
