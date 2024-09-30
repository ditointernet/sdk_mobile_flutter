import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/utils/sha1.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

final DitoSDK dito = DitoSDK();
const id = '22222222222';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  dynamic env = await testEnv();


  setUpAll(() {
    dito.initialize(apiKey: env["apiKey"], secretKey: convertToSHA1(env["secret"]));
  });

  group('User interface', () {
    test('User entity start null', () {
      expect(dito.user.data.userID, null);
    });

    test('Set User on memory', () async {
      await dito.user.identify(userID: id, email: "teste@teste.com");
      expect(dito.user.data.id, id);
      expect(dito.user.data.email, "teste@teste.com");
    });

    test('Send identify', () async {
      final result = await dito.user
          .identify(userID: id, email: "teste@teste.com");
      expect(result, true);
      expect(dito.user.data.id, id);
    });

    test('Send login', () async {
      final result = await dito.user.login(userID: id);
      expect(result, true);
      expect(dito.user.data.id, id);
    });
  });
}
