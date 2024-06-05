import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/user/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

final DitoSDK dito = DitoSDK();
const id = '22222222222';

Future<void> setUp() async {
  dynamic env = await testEnv();
  dito.initialize(apiKey: env["apiKey"], secretKey: env["secret"]);
}

void main() {
  group('Dito SDK: ', () {
    test('Send mobile token', () async {
      dito.identify(UserEntity(userID: id));

      final response = await dito.registryMobileToken(
          token:
              "eXb4Y_piSZS2RKv7WeqjW0:APA91bHJUQ6kL8ZrevvO8zAgYIEdtCWSa7RkmszRFdYz32jYblJvOkIiDcpDdqVqZvOm8CSiEHTzljHajvMO66FFxiqteB6od2sMe01UIOwvKrpUOFXz-L4Slif9jSY9pUaMxyqCtoxR");

      expect(response.statusCode, 200);
    });

    test('Send open notification', () async {
      final response = await dito.openNotification(
          notificationId: '723422', identifier: '1713466024', reference: id);

      expect(response.statusCode, 200);
    });
  });
}
