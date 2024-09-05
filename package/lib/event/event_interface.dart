import 'package:flutter/foundation.dart';

import 'event_entity.dart';
import 'event_repository.dart';
import 'navigation_entity.dart';

/// EventInterface is an interface for managing events and communicating with the event repository
interface class EventInterface {
  final EventRepository _repository = EventRepository();

  /// Tracks an event by saving and sending it to the event repository.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked.
  Future<bool> track(
      {required String action,
      String? createdAt,
      double? revenue,
      String? currency,
      Map<String, dynamic>? customData}) async {
    try {
      DateTime localDateTime = DateTime.now();
      DateTime utcDateTime = localDateTime.toUtc();

      final event = EventEntity(
          action: action,
          createdAt: createdAt ?? utcDateTime.toIso8601String(),
          revenue: revenue,
          currency: currency,
          customData: customData);

      return await _repository.track(event);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking event: $e');
      }
      return false;
    }
  }

  /// Tracks an event by saving and sending it to the event repository.
  ///
  /// [event] - The EventEntity object containing event data.
  /// Returns a Future that completes with true if the event was successfully tracked.
  Future<bool> navigate(
      {required String name,
      String? createdAt,
      Map<String, dynamic>? customData}) async {
    try {
      DateTime localDateTime = DateTime.now();
      DateTime utcDateTime = localDateTime.toUtc();

      final navigation = NavigationEntity(
          pageName: name,
          createdAt: createdAt ?? utcDateTime.toIso8601String(),
          customData: customData);

      return await _repository.navigate(navigation);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking event: $e');
      }
      return false;
    }
  }
}
