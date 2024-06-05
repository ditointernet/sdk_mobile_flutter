library dito_sdk;

import 'package:dito_sdk/user/user_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'database.dart';
import 'entity/event.dart';
import 'entity/user.dart';
import 'services/notification_service.dart';
import 'data/dito_api.dart';

/// DitoSDK is a singleton class that provides various methods to interact with Dito API
/// and manage user data, events, and push notifications.
class DitoSDK {
  final _userInterface = UserInterface();
  User _user = User();
  late NotificationService _notificationService;
  Constants constants = Constants();

  late DitoApi ditoApi;

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
    _apiKey = apiKey;
    _secretKey = secretKey;
    _notificationService = NotificationService(_instance);
    _assign = {
      'platform_api_key': apiKey,
      'sha1_signature': convertToSHA1(_secretKey!),
    };
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

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<void> _verifyPendingEvents() async {
    final database = LocalDatabase.instance;
    final events = await database.getEvents();

    if (events.isNotEmpty) {
      for (final event in events) {
        await _postEvent(event);
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

  Future<http.Response> _postEvent(Event event) async {
    _checkConfiguration();

    final body = {
      'id_type': 'id',
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    final url = Domain(Endpoint.events.replace(_userInterface.id!)).spited;
    final uri = Uri.https(url[0], url[1], _assign);

    body.addAll(_assign);
    return await Api().post(url: uri, body: body);
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

    if (_userInterface.isNotValid) {
      final database = LocalDatabase.instance;
      await database.createEvent(event);
      return http.Response("", 200);
    }

    return await _postEvent(event);
  }

  /// This method registers a mobile token for push notifications.
  ///
  /// [token] - The mobile token to be registered.
  /// Returns an http.Response.
  Future<http.Response> registryMobileToken({required String token}) async {
    return await ditoApi.registryMobileToken(token, _user);
  }

  /// This method removes a mobile token from the push notification service.
  ///
  /// [token] - The mobile token to be removed.
  /// Returns an http.Response.
  Future<http.Response> removeMobileToken({required String token}) async {
    return await ditoApi.removeMobileToken(token, _user);
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
