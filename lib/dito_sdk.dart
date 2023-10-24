library dito_sdk;

import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dito_sdk/event.dart';
import 'package:dito_sdk/database.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DitoSDK {
  String? _userAgent;
  String? _apiKey;
  String? _secretKey;
  String? _userID;
  String? _name;
  String? _email;
  String? _gender;
  String? _birthday;
  String? _location;
  Map<String, String>? _customData;

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  void initialize({required String apiKey, required String secretKey}) {
    _apiKey = apiKey;
    _secretKey = secretKey;
  }

  String _convertToSHA1(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  void identify({
    String? cpf,
    String? name,
    String? email,
    String? gender,
    String? birthday,
    String? location,
    Map<String, String>? customData,
  }) {
    if (name != null) {
      _name = name;
    }
    if (email != null) {
      _email = email;
    }
    if (gender != null) {
      _gender = gender;
    }
    if (birthday != null) {
      _birthday = birthday;
    }
    if (location != null) {
      _location = location;
    }
    if (customData != null) {
      _customData = customData;
    }
  }

  void setUserId(String userId) async {
    _userID = userId;

    final dbHelper = DatabaseHelper.instance;
    final events = await dbHelper.getEvents();

    if (events.isNotEmpty) {
      for (var event in events) {
        trackEvent(
          eventName: event.eventName,
          eventMoment: event.eventMoment,
          revenue: event.revenue,
          customData: event.customData,
        );
      }
      await dbHelper.deleteAllEvents();
    }
  }

  void setUserAgent(String userAgent) {
    _userAgent = userAgent;
  }

  Future<String> _getUserAgent() async {
    final deviceInfo = DeviceInfoPlugin();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    final String appName = packageInfo.appName;
    String system;
    String model;

    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      system = 'iOS ${ios.systemVersion}';
      model = ios.model;
    } else {
      final android = await deviceInfo.androidInfo;
      system = 'Android ${android.version}';
      model = android.model;
    }

    return '$appName/$version ($system; $model)';
  }

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<void> identifyUser() async {
    _checkConfiguration();

    if (_userID == null) {
      throw Exception(
          'User registration is required. Please call the setUserId() method first.');
    }

    final signature = _convertToSHA1(_secretKey!);

    final params = {
      'platform_api_key': _apiKey,
      'sha1_signature': signature,
      'user_data': jsonEncode({
        'name': _name,
        'email': _email,
        'gender': _gender,
        'location': _location,
        'birthday': _birthday,
        'data': json.encode(_customData)
      }),
    };

    final url = Uri.parse(
        "https://login.plataformasocial.com.br/users/portal/$_userID/signup");

    final defaultUserAgent = await _getUserAgent();

    try {
      await http.post(
        url,
        body: params,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': _userAgent ?? defaultUserAgent,
        },
      );
    } catch (event) {
      throw Exception('Requisition failed: $event');
    }
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  Future<void> trackEvent({
    required String eventName,
    double? revenue,
    Map<String, String>? customData,
    String? eventMoment,
  }) async {
    _checkConfiguration();

    final threeHoursLater = DateTime.now().add(const Duration(hours: 3));

    final formattedDateTime =
        '${threeHoursLater.year}-${_twoDigits(threeHoursLater.month)}-${_twoDigits(threeHoursLater.day)} ${_twoDigits(threeHoursLater.hour)}:${_twoDigits(threeHoursLater.minute)}:${_twoDigits(threeHoursLater.second)}';

    if (_userID == null) {
      final dbHelper = DatabaseHelper.instance;
      final untrackedEvent = Event(
        eventName: eventName,
        eventMoment: formattedDateTime,
        revenue: revenue,
        customData: customData,
      );
      await dbHelper.insertEvent(untrackedEvent);
      return;
    }

    final signature = _convertToSHA1(_secretKey!);

    final params = {
      'id_type': 'id',
      'platform_api_key': _apiKey,
      'sha1_signature': signature,
      'encoding': 'base64',
      'network_name': 'pt',
      'event': jsonEncode({
        'action': eventName,
        'revenue': revenue,
        'data': customData,
        'created_at': eventMoment ?? formattedDateTime
      })
    };

    final url =
        Uri.parse("http://events.plataformasocial.com.br/users/$_userID");

    final defaultUserAgent = await _getUserAgent();

    try {
      await http.post(
        url,
        body: params,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': _userAgent ?? defaultUserAgent,
        },
      );
    } catch (event) {
      throw Exception('Requisition failed: $event');
    }
  }
}
