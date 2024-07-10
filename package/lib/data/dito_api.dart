import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../event/event_entity.dart';
import '../user/user_entity.dart';
import '../utils/sha1.dart';

class DitoApi {
  final String _platform = Platform.isIOS ? 'iPhone' : 'Android';
  String? _apiKey;
  String? _secretKey;
  late Map<String, String> _assign;

  static final DitoApi _instance = DitoApi._internal();

  factory DitoApi() {
    return _instance;
  }

  DitoApi._internal();

  void setKeys(String apiKey, String secretKey) {
    _instance._apiKey = apiKey;
    _instance._secretKey = secretKey;
    _instance._assign = {
      'platform_api_key': apiKey,
      'sha1_signature': convertToSHA1(secretKey),
    };
  }

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }
  }

  Future<http.Response> _post(String url, String path,
      {Map<String, Object?>? queryParameters, Map<String, Object?>? body}) {
    _checkConfiguration();

    final uri = Uri.https(url, path, queryParameters);

    return http.post(
      uri,
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': _platform,
      },
    );
  }

  Future<http.Response> _put(String url, String path,
      {Map<String, Object?>? queryParameters, Map<String, Object?>? body}) {
    _checkConfiguration();

    final uri = Uri.https(url, path, queryParameters);

    return http.put(
      uri,
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': _platform,
      },
    );
  }

  Future<http.Response> identify(UserEntity user) async {
    final queryParameters = {
      'user_data': jsonEncode(user.toJson()),
    };

    queryParameters.addAll(_assign);

    const url = 'login.plataformasocial.com.br';
    final path = 'users/portal/${user.id}/signup';

    return await _post(url, path, queryParameters: queryParameters);
  }

  Future<http.Response> updateUserData(UserEntity user) async {
    final queryParameters = {
      'user_data': jsonEncode(user.toJson()),
    };

    queryParameters.addAll(_assign);

    const url = 'login.plataformasocial.com.br';
    final path = 'users/${user.id}';

    return await _put(url, path,
        queryParameters: queryParameters,
        body: {'user_data': jsonEncode(user.toJson())});
  }

  Future<http.Response> trackEvent(EventEntity event, UserEntity user) async {
    final body = {
      'id_type': 'id',
      'network_name': 'pt',
      'event': jsonEncode(event.toJson())
    };

    const url = 'events.plataformasocial.com.br';
    final path = 'users/${user.id}';

    body.addAll(_assign);

    return await _post(url, path, body: body);
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

    const url = 'notification.plataformasocial.com.br';
    final path = 'notifications/$notificationId/open';

    return await _post(url, path, queryParameters: queryParameters, body: body);
  }

  Future<http.Response> registryToken(String token, UserEntity user) async {
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

    const url = 'notification.plataformasocial.com.br';
    final path = 'users/${user.id}/mobile-tokens/';

    return await _post(url, path, queryParameters: queryParameters);
  }

  Future<http.Response> removeToken(String token, UserEntity user) async {
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

    const url = 'notification.plataformasocial.com.br';
    final path = 'users/${user.id}/mobile-tokens/disable';

    return await _post(url, path, queryParameters: queryParameters);
  }
}
