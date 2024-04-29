library dito_sdk;

import 'dart:convert';
import 'package:dito_sdk/constants.dart';
import 'package:dito_sdk/entity/user.dart';
import 'package:dito_sdk/entity/event.dart';
import 'package:dito_sdk/database.dart';
import 'package:dito_sdk/services/firebase_messaging_service.dart';
import 'package:dito_sdk/utils/http.dart';
import 'package:dito_sdk/utils/sha1.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class DitoSDK {
  String? _apiKey;
  String? _secretKey;
  String? _userID;
  String? _signature;
  User? _user;
  late FirebaseMessagingService _notificationService;

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  Future<FirebaseMessagingService> get notificationService async {
    return _notificationService;
  }


  void initialize({required String apiKey, required String secretKey}) async {
    _apiKey = apiKey;
    _secretKey = secretKey;
    _signature = convertToSHA1(_secretKey!);
  }

  Future<void> initializePushService() async {
    await Firebase.initializeApp();
    _notificationService = FirebaseMessagingService(this);
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
      'platform_api_key': _apiKey,
      'sha1_signature': _signature,
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    final url =
        Uri.parse(Constants.endpoints
        .replace(value: _userID!, endpoint: Endpoint.events));


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

  Future<void> setUserId(String userId) async {
    _userID = userId;
    _verifyPendingEvents();
  }

  User? get user {
    return _user;
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
    if (name != null) {
      _user?.name = name;
    }

    if (email != null) {
      _user?.email = email;
    }

    if (gender != null) {
      _user?.gender = gender;
    }

    if (birthday != null) {
      _user?.birthday = birthday;
    }

    if (location != null) {
      _user?.location = location;
    }

    if (customData != null) {
      _user?.customData = customData;
    }

    setUserId(userID);
  }

  Future<void> setUser(User user) async {
    _user = user;

    if (!user.validate()) {
      throw Exception(
          'User registration is required. Please call the setUserId() method first.');
    } else {
      await setUserId(user.getUserID());
    }
  }

  Future<http.Response> identifyUser() async {
    _checkConfiguration();

    if (_user?.validate()) {
      throw Exception(
          'User registration is required. Please call the setUserId() method first.');
    }

    final params = {
      'platform_api_key': _apiKey,
      'sha1_signature': _signature,
      'user_data': jsonEncode(_user!.toJson()),
    };

    final url = Uri.parse(
      Constants.endpoints
        .replace(value: _userID!, endpoint: Endpoint.identify));

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

    if (_userID == null) {
      final database = LocalDatabase.instance;
      await database.createEvent(event);
      return http.Response("", 200);
    }

    return await _postEvent(event);
  }

  Future<http.Response> registryMobileToken({required String token}) async {
    _checkConfiguration();

    if (_userID == null) {
      throw Exception(
          'User registration is required. Please call the setUserId() method first.');
    }

    final params = {
      'id_type': 'id',
      'platform_api_key': _apiKey,
      'sha1_signature': _signature,
      'token': token,
      'platform': Constants.platform,
    };

    final url = Uri.parse(
        Constants.endpoints
        .replace(value: _userID!, endpoint: Endpoint.registryMobileTokens));

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
      'platform_api_key': _apiKey,
      'sha1_signature': _signature,
      'channel_type': 'mobile',
      'data': jsonEncode({
        'identifier': identifier,
        'reference': reference,
      })
    };

    final url = Uri.parse(Constants.endpoints
        .replace(value: _userID!, endpoint: Endpoint.openNotification));

    return await Api().post(
      url,
      params,
    );
  }
}
