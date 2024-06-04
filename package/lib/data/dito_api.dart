import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import '../database.dart';
import '../entity/user.dart';
import '../entity/event.dart';
import '../entity/domain.dart';
import '../utils/sha1.dart';

enum Endpoint {
  identify,
  registryMobileTokens,
  removeMobileTokens,
  events,
  openNotification;

  replace(String id) {
    String? value;

    switch (toString()) {
      case "Endpoint.registryMobileTokens":
        value = "notification.plataformasocial.com.br/users/{}/mobile-tokens/"
            .replaceFirst("{}", id);
        break;
      case "Endpoint.removeMobileTokens":
        value =
            "notification.plataformasocial.com.br/users/{}/mobile-tokens/disable/"
                .replaceFirst("{}", id);
        break;
      case "Endpoint.events":
        value =
            "events.plataformasocial.com.br/users/{}".replaceFirst("{}", id);
        break;
      case "Endpoint.openNotification":
        value = "notification.plataformasocial.com.br/notifications/{}/open"
            .replaceFirst("{}", id);
        break;
      default:
        value = "login.plataformasocial.com.br/users/portal/{}/signup"
            .replaceFirst("{}", id);
        break;
    }

    return value;
  }
}

class DitoApi {
  String _platform = Platform.isIOS ? 'iPhone' : 'Android';
  String? _apiKey;
  String? _secretKey;
  late Map<String, String> _assign;

  static final DitoApi _instance = DitoApi._internal();

  factory DitoApi() {
    return _instance;
  }

  DitoApi._internal();

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<http.Response> _post({required url, Map<String, Object?>? body}) {
    _checkConfiguration();

    return http.post(
      url,
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': _platform,
      },
    );
  }

  Future<void> initialize(String apiKey, String secretKey) async {
    _apiKey = apiKey;
    _secretKey = secretKey;
    _assign = {
      'platform_api_key': apiKey,
      'sha1_signature': convertToSHA1(secretKey),
    };
  }

  Future<http.Response> identify(User user) async {
    final queryParameters = {
      'user_data': jsonEncode(user.toJson()),
    };

    queryParameters.addAll(_assign);
    final url = Domain(Endpoint.identify.replace(user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await _post(
      url: uri,
    );
  }

  Future<http.Response> trackEvent(Event event, User user) async {
    if (user.isNotValid) {
      final database = LocalDatabase.instance;
      await database.createEvent(event);
      return http.Response("", 200);
    }

    final body = {
      'id_type': 'id',
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    final url = Domain(Endpoint.events.replace(user.id!)).spited;
    final uri = Uri.https(url[0], url[1], _assign);

    body.addAll(_assign);
    return await _post(url: uri, body: body);
  }

  Future<http.Response> openNotification(
      String notificationId, String identifier, String reference) async {
    final queryParameters = {
      'channel_type': 'mobile',
    };

    final body = {
      'identifier': identifier,
      'reference': reference,
    };

    queryParameters.addAll(_assign);

    final url =
        Domain(Endpoint.openNotification.replace(notificationId)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await _post(url: uri, body: body);
  }

  Future<http.Response> registryMobileToken(String token, User user) async {
    if (user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    final queryParameters = {
      'id_type': 'id',
      'token': token,
      'platform': _platform,
    };

    queryParameters.addAll(_assign);
    final url = Domain(Endpoint.registryMobileTokens.replace(user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await _post(
      url: uri,
    );
  }

  Future<http.Response> removeMobileToken(String token, User user) async {
    if (user.isNotValid) {
      throw Exception(
          'User registration is required. Please call the identify() method first.');
    }

    final queryParameters = {
      'id_type': 'id',
      'token': token,
      'platform': _platform,
    };

    queryParameters.addAll(_assign);
    final url = Domain(Endpoint.removeMobileTokens.replace(user.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await _post(
      url: uri,
    );
  }
}
