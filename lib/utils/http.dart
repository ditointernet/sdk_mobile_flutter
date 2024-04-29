import 'package:dito_sdk/constants.dart';
import 'package:http/http.dart' as http;

class Api {
  final Map<String, String> _headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'User-Agent': Constants.platform
  };

  static final Api _instance = Api._internal();

  factory Api() {
    return _instance;
  }

  Api._internal();

  Future<http.Response> post(Uri url, Map<String, String?>? params) async {
    return await http.post(
      url,
      body: params,
      headers: _headers,
    );
  }
}
