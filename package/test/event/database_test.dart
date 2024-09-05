import 'package:dito_sdk/event/event_dao.dart';
import 'package:dito_sdk/event/event_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EventDatabaseService Tests', () {
    final EventDAO eventDAO = EventDAO();

    tearDown(() async {
      await eventDAO.clearDatabase();
      await eventDAO.closeDatabase();
    });

    test('should insert an event', () async {
      final event = EventEntity(
        action: 'Test Event',
        createdAt: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value'},
      );

      final success = await eventDAO.create(event: event);

      expect(success, true);

      final events = await eventDAO.fetchAll();
      expect(events.length, 1);
      expect(events.first["action"], 'Test Event');
    });

    test('should delete an event', () async {
      final event = EventEntity(
        action: 'Test Event',
        createdAt: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value'},
      );

      await eventDAO.create(event: event);
      await eventDAO.clearDatabase();

      final events = await eventDAO.fetchAll();
      expect(events.isEmpty, true);
    });

    test('should fetch all events', () async {
      final event1 = EventEntity(
        action: 'Test Event 1',
        createdAt: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value1'},
      );

      final event2 = EventEntity(
        action: 'Test Event 2',
        createdAt: '2024-06-02T12:34:56Z',
        revenue: 200.0,
        customData: {'key': 'value2'},
      );

      await eventDAO.create(event: event1);
      await eventDAO.create(event: event2);

      final events = await eventDAO.fetchAll();

      expect(events.length, 2);
      expect(events.first["action"], 'Test Event 1');
      expect(events.last["action"], 'Test Event 2');
    });
  });
}
