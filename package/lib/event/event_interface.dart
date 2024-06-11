import 'package:flutter/foundation.dart';

import '../utils/custom_data.dart';
import 'event_entity.dart';
import 'event_repository.dart';

/// EventInterface is an interface for managing events and communicating with the event repository
interface class EventInterface {
  final EventRepository _repository = EventRepository();

  /// Tracks an event by saving and sending it to the event repository.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked.
  Future<bool> trackEvent(EventEntity event) async {
    try {
      DateTime localDateTime = DateTime.now();
      DateTime utcDateTime = localDateTime.toUtc();
      String eventMoment = utcDateTime.toIso8601String();

      event.eventMoment = eventMoment;

      final version = await customDataVersion;
      if (event.customData == null) {
        event.customData = version;
      } else {
        event.customData?.addAll(version);
      }

      return await _repository.trackEvent(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking event: $e');
      }
      return false;
    }
  }

  /// Verifies and processes any pending events.
  ///
  /// Throws an exception if the user is not valid.
  Future<void> verifyPendingEvents() async {
    try {
      final events = await _repository.fetchPendingEvents();

      if (events.isNotEmpty) {
        for (final event in events) {
          await trackEvent(event);
        }
        await _repository.clearEvents();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events: $e');
      }
      rethrow;
    }
  }
}
