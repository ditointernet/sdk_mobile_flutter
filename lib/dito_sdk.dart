library dito_sdk;

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import './constants.dart';
import './utils/http.dart';
import './utils/sha1.dart';
import './services/notification_service.dart';
import './database.dart';
import './entity/event.dart';
import './entity/user.dart';

class DitoSDK {
  String? _apiKey;
  String? _secretKey;
  late Map<String, String> _assign;
  late NotificationService _notificationService;
  User _user = User();

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
    _apiKey = apiKey;
    _secretKey = secretKey;
    _notificationService = NotificationService(_instance);
    _assign = {
      'platform_api_key': apiKey,
      'sha1_signature': convertToSHA1(_secretKey!),
    };
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

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<http.Response> _postEvent(Event event) async {
    _checkConfiguration();

    final params = {
      'id_type': 'id',
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    params.addAll(_assign);

    final url = Uri.parse(Constants.endpoints
        .replace(value: _user.id!, endpoint: Endpoint.events));

    return await Api().post(url, params);
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
    _checkConfiguration();

    if (_user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    final params = {
      'user_data': jsonEncode(_user.toJson()),
    };

    params.addAll(_assign);

    final url = Uri.parse(Constants.endpoints
        .replace(value: _user.id!, endpoint: Endpoint.identify));

    return await Api().post(
      url,
      params,
    );
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
      revenue: revenue,
      customData: customData,
    );

    if (_user.isNotValid) {
      final database = LocalDatabase.instance;
      await database.createEvent(event);
      return http.Response("", 200);
    }

    return await _postEvent(event);
  }

  Future<http.Response> registryMobileToken({required String token}) async {
    _checkConfiguration();

    if (_user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    final params = {
      'id_type': 'id',
      'token': token,
      'platform': Constants.platform,
    };

    params.addAll(_assign);

    final url = Uri.parse(Constants.endpoints
        .replace(value: _user.id!, endpoint: Endpoint.registryMobileTokens));

    return await Api().post(
      url,
      params,
    );
  }

  Future<http.Response> removeMobileToken({required String token}) async {
    _checkConfiguration();

    if (_user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    final params = {
      'id_type': 'id',
      'token': token,
      'platform': Constants.platform,
    };

    params.addAll(_assign);

    final url = Uri.parse(Constants.endpoints
        .replace(value: _user.id!, endpoint: Endpoint.removeMobileTokens));

    return await Api().post(
      url,
      params,
    );
  }

  Future<http.Response> openNotification(
      {required String notificationId,
      required String identifier,
      required String reference}) async {
    _checkConfiguration();

    final params = {
      'channel_type': 'mobile',
      'data': jsonEncode({
        'identifier': identifier,
        'reference': reference,
      })
    };

    params.addAll(_assign);

    final url = Uri.parse(Constants.endpoints
        .replace(value: _user.id!, endpoint: Endpoint.openNotification));

    return await Api().post(
      url,
      params,
    );
  }
}
