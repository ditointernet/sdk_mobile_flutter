import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/event/services/event_database_service.dart';
import 'package:dito_sdk/user/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../utils.dart';

final DitoSDK dito = DitoSDK();
const id = '22222222222';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  dynamic env = await testEnv();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    dito.initialize(apiKey: env["apiKey"], secretKey: env["secret"]);
  });

  group('Events: ', () {
    late EventDatabaseService database;

    setUp(() async {
      database = EventDatabaseService();
      await database.database;
    });

    tearDown(() async {
      await database.clearDatabase();
      await database.closeDatabase();
    });

    test('Send event without identify', () async {
      await dito.trackEvent(eventName: 'event-test-sdk-flutter');
      final events = await database.fetchAll();
      expect(events.length, 1);
      expect(events.first.eventName, 'event-test-sdk-flutter');
    });

    test('Send event with identify', () async {
      dito.user.identify(UserEntity(userID: id, email: "teste@teste.com"));
      final result = await dito.trackEvent(eventName: 'event-test-sdk-flutter');
      final events = await database.fetchAll();

      expect(events.length, 0);
      expect(result, true);
    });

    test('Send event with custom data', () async {
      dito.user.identify(UserEntity(userID: id, email: "teste@teste.com"));
      final result = await dito.trackEvent(
          eventName: 'event-test-sdk-flutter',
          customData: {
            "data do ultimo teste": DateTime.now().toIso8601String()
          },
          revenue: 10);
      final events = await database.fetchAll();

      expect(events.length, 0);
      expect(result, true);
    });
  });
}
