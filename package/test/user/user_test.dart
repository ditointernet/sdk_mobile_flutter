import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/user/user.dart';
import 'package:dito_sdk/user/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

final DitoSDK dito = DitoSDK();
const id = '22222222222';

Future<void> setUp(dynamic Function() body) async {
  dynamic env = await testEnv();
  dito.initialize(apiKey: env["apiKey"], secretKey: env["secret"]);
}

void main() {
  group('User interface', () {
    test('User entity start null', () {
      expect(UserInterface().user.userID, null);
    });

    test('Set User on memory', () async {
      dito.user.set(UserEntity(userID: id, email: "teste@teste.com"));
      expect(dito.user.id, id);
      expect(dito.user.email, "teste@teste.com");
    });

    test('Send identify', () async {
      final result = await dito.user.identify(
          UserEntity(userID: "11111111111", email: "teste@teste.com"));
      expect(result, true);
      expect(dito.user.id, "11111111111");
    });
  });
}
