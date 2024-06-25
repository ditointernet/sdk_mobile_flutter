import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/user/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

final DitoSDK dito = DitoSDK();
const id = '22222222222';

void main() {
  group('Dito SDK: ', () {
    setUp(() async {
      dynamic env = await testEnv();
      dito.initialize(apiKey: env["apiKey"], secretKey: env["secret"]);
    });
  });
}
