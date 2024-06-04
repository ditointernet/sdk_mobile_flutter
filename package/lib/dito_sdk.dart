library dito_sdk;

import 'package:dito_sdk/data/dito_api.dart';
import 'package:dito_sdk/entity/domain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'database.dart';
import 'entity/event.dart';
import 'entity/user.dart';
import 'services/notification_service.dart';

class DitoSDK {
  late NotificationService _notificationService;
  User _user = User();
  Constants constants = Constants();

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  NotificationService notificationService() {
    return _notificationService;
  }

  User get user {
    return _user;
  }

  void initialize({required String apiKey, required String secretKey}) async {
    _notificationService = NotificationService(_instance);
    DitoApi().initialize(apiKey, secretKey);
  }

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
        await DitoApi().trackEvent(event, _user);
      }
      database.deleteEvents();
    }
  }

  @Deprecated('migration')
  Future<void> setUserId(String userId) async {
    _setUserId(userId);
  }

  Future<void> _setUserId(String userId) async {
    if (_user.isValid) {
      _verifyPendingEvents();
    }
  }

  void identify({
    required String userID,
    String? cpf,
    String? name,
    String? email,
    String? gender,
    String? birthday,
    String? location,
    Map<String, String>? customData,
  }) {
    _user.userID = userID;

    if (cpf != null) {
      _user.cpf = cpf;
    }

    if (name != null) {
      _user.name = name;
    }

    if (email != null) {
      _user.email = email;
    }

    if (gender != null) {
      _user.gender = gender;
    }

    if (birthday != null) {
      _user.birthday = birthday;
    }

    if (location != null) {
      _user.location = location;
    }

    if (customData != null) {
      _user.customData = customData;
    }

    _setUserId(userID);
  }

  Future<void> setUser(User user) async {
    _user = user;

    if (_user.isValid) {
      await _setUserId(_user.id!);
    } else {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }
  }

  Future<http.Response> identifyUser() async {
    if (_user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    return await DitoApi().identify(_user);
  }

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

    return await DitoApi().trackEvent(event, _user);
  }

  Future<http.Response> registryMobileToken({required String token}) async {
    return await DitoApi().registryMobileToken(token, _user);
  }

  Future<http.Response> removeMobileToken({required String token}) async {
    return await DitoApi().removeMobileToken(token, _user);
  }

  Future<http.Response> openNotification(
      {required String notificationId,
      required String identifier,
      required String reference}) async {
    return await DitoApi()
        .openNotification(notificationId, identifier, reference);
  }
}
