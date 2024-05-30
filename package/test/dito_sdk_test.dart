import 'dart:convert';
import 'dart:io';

import 'package:dito_sdk/dito_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

Future<dynamic> testEnv() async {
  final file = File('test/.env-test.json');
  final json = jsonDecode(await file.readAsString());
  return json;
}

void main() {
  final DitoSDK dito = DitoSDK();
  const id = '22222222222';

  setUp() async {
    dynamic env = await testEnv();
    dito.initialize(apiKey: env["apiKey"], secretKey: env["secret"]);
  }

  group('Dito SDK: ', () {
    test('Send identify', () async {
      await setUp();

      dito.identify(userID: id, email: "teste@teste.com");
      expect(dito.user.id, id);
      expect(dito.user.email, "teste@teste.com");

      final response = await dito.identifyUser();
      expect(response.statusCode, 201);
    });

    test('Send event', () async {
      await setUp();
      dito.identify(userID: id);

      final response = await dito.trackEvent(eventName: 'sdk-test-flutter');

      expect(response.statusCode, 201);
    });

    test('Send mobile token', () async {
      await setUp();
      dito.identify(userID: id);

      final response = await dito.registryMobileToken(
          token:
              "eXb4Y_piSZS2RKv7WeqjW0:APA91bHJUQ6kL8ZrevvO8zAgYIEdtCWSa7RkmszRFdYz32jYblJvOkIiDcpDdqVqZvOm8CSiEHTzljHajvMO66FFxiqteB6od2sMe01UIOwvKrpUOFXz-L4Slif9jSY9pUaMxyqCtoxR");

      expect(response.statusCode, 200);
    });

    test('Send open notification', () async {
      await setUp();

      dito.identify(userID: id);
      expect(dito.user.id, id);

      final response = await dito.openNotification(
          notificationId: '723422', identifier: '1713466024', reference: id);

      expect(response.statusCode, 422);
    });
  });
}
