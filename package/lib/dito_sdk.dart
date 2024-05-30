library dito_sdk;

import 'dart:convert';

import 'package:dito_sdk/entity/domain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'database.dart';
import 'entity/event.dart';
import 'entity/user.dart';
import 'services/notification_service.dart';
import 'utils/http.dart';
import 'utils/sha1.dart';

class DitoSDK {
  String? _apiKey;
  String? _secretKey;
  late Map<String, String> _assign;
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

    final queryParameters = {
      'user_data': jsonEncode(_user.toJson()),
    };

    queryParameters.addAll(_assign);
    final url = Domain(Endpoint.identify.replace(_user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await Api().post(
      url: uri,
    );
  }

  Future<http.Response> _postEvent(Event event) async {
    _checkConfiguration();

    final body = {
      'id_type': 'id',
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    final url = Domain(Endpoint.events.replace(_user.id!)).spited;
    final uri = Uri.https(url[0], url[1], _assign);

    body.addAll(_assign);
    return await Api().post(url: uri, body: body);
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

    final queryParameters = {
      'id_type': 'id',
      'token': token,
      'platform': constants.platform,
    };

    queryParameters.addAll(_assign);
    final url = Domain(Endpoint.registryMobileTokens.replace(_user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await Api().post(
      url: uri,
    );
  }

  Future<http.Response> removeMobileToken({required String token}) async {
    _checkConfiguration();

    if (_user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    final queryParameters = {
      'id_type': 'id',
      'token': token,
      'platform': constants.platform,
    };

    queryParameters.addAll(_assign);
    final url = Domain(Endpoint.removeMobileTokens.replace(_user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await Api().post(
      url: uri,
    );
  }

  Future<http.Response> openNotification(
      {required String notificationId,
      required String identifier,
      required String reference}) async {
    _checkConfiguration();

    final queryParameters = {
      'channel_type': 'mobile',
    };

    final body = {
      'identifier': identifier,
      'reference': reference,
    };

    queryParameters.addAll(_assign);

    final url = Domain(Endpoint.openNotification.replace(_user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await Api().post(url: uri, body: body);
  }
}
