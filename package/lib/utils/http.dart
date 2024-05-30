import 'package:http/http.dart' as http;

import '../constants.dart';

class Api {
  Constants constants = Constants();

  static final Api _instance = Api._internal();

  factory Api() {
    return _instance;
  }

  Api._internal();

  Future<http.Response> post({required url, Map<String, Object?>? body}) async {
    return await http.post(
      url,
      body: body,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent': constants.platform,
      },
    );
  }
}
