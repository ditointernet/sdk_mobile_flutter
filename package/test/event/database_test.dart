import 'package:dito_sdk/event/event_entity.dart';
import 'package:dito_sdk/event/services/event_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('EventDatabaseService Tests', () {
    late EventDatabaseService eventDatabaseService;

    setUp(() async {
      eventDatabaseService = EventDatabaseService();
      await eventDatabaseService.database;
    });

    tearDown(() async {
      await eventDatabaseService.clearDatabase();
      await eventDatabaseService.closeDatabase();
    });

    test('should insert an event', () async {
      final event = EventEntity(
        eventName: 'Test Event',
        eventMoment: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value'},
      );

      final success = await eventDatabaseService.create(event);

      expect(success, true);

      final events = await eventDatabaseService.fetchAll();
      expect(events.length, 1);
      expect(events.first.eventName, 'Test Event');
    });

    test('should delete an event', () async {
      final event = EventEntity(
        eventName: 'Test Event',
        eventMoment: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value'},
      );

      await eventDatabaseService.create(event);
      final success = await eventDatabaseService.delete(event);

      expect(success, true);

      final events = await eventDatabaseService.fetchAll();
      expect(events.isEmpty, true);
    });

    test('should fetch all events', () async {
      final event1 = EventEntity(
        eventName: 'Test Event 1',
        eventMoment: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value1'},
      );

      final event2 = EventEntity(
        eventName: 'Test Event 2',
        eventMoment: '2024-06-02T12:34:56Z',
        revenue: 200.0,
        customData: {'key': 'value2'},
      );

      await eventDatabaseService.create(event1);
      await eventDatabaseService.create(event2);

      final events = await eventDatabaseService.fetchAll();

      expect(events.length, 2);
      expect(events[0].eventName, 'Test Event 1');
      expect(events[1].eventName, 'Test Event 2');
    });

    test('should clear the database', () async {
      final event = EventEntity(
        eventName: 'Test Event',
        eventMoment: '2024-06-01T12:34:56Z',
        revenue: 100.0,
        customData: {'key': 'value'},
      );

      await eventDatabaseService.create(event);
      await eventDatabaseService.clearDatabase();

      final events = await eventDatabaseService.fetchAll();
      expect(events.isEmpty, true);
    });
  });
}
