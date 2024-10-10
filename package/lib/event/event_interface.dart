import '../utils/logger.dart';
import 'event_entity.dart';
import 'event_repository.dart';
import 'navigation_entity.dart';

/// `EventInterface` provides an interface for tracking user events and navigation actions.
/// It interacts with the `EventRepository` to save these events in the backend.
interface class EventInterface {
  /// Repository that handles the communication for event tracking.
  final EventRepository _repository = EventRepository();

  /// Tracks a user event.
  ///
  /// [action] - The action name (e.g., a button click or form submission).
  /// [createdAt] - The event creation time, defaults to the current UTC time if not provided.
  /// [revenue] - The revenue amount associated with the event, optional.
  /// [currency] - The currency for the revenue, optional.
  /// [customData] - A map of additional custom data related to the event, optional.
  ///
  /// Returns a `Future<bool>` that completes with `true` if the event was tracked successfully,
  /// or `false` if there was an error.
  Future<bool> track(
      {required String action,
      String? createdAt,
      double? revenue,
      String? currency,
      Map<String, dynamic>? customData}) async {
    try {
      // Get the current local time and convert it to UTC for accurate event logging.
      DateTime localDateTime = DateTime.now();
      DateTime utcDateTime = localDateTime.toUtc();

      // Create an event entity using the provided data.
      final event = EventEntity(
          action: action,
          createdAt: createdAt ??
              utcDateTime
                  .toIso8601String(), // Default to current UTC time if not provided.
          revenue: revenue,
          currency: currency,
          customData: customData);

      // Track the event using the repository and return the result.
      return _repository.track(event);
    } catch (e) {
      loggerError('Error tracking event: $e'); // Log the error in debug mode.

      return false; // Return false if there was an error.
    }
  }

  /// Tracks a navigation event when the user navigates to a new page or screen.
  ///
  /// [name] - The name of the page the user navigated to.
  /// [createdAt] - The navigation event creation time, defaults to the current UTC time if not provided.
  /// [customData] - A map of additional custom data related to the navigation event, optional.
  ///
  /// Returns a `Future<bool>` that completes with `true` if the navigation event was tracked successfully,
  /// or `false` if there was an error.
  Future<bool> navigate(
      {required String name,
      String? createdAt,
      Map<String, dynamic>? customData}) async {
    try {
      // Get the current local time and convert it to UTC for accurate navigation logging.
      DateTime localDateTime = DateTime.now();
      DateTime utcDateTime = localDateTime.toUtc();

      // Create a navigation entity with the provided data.
      final navigation = NavigationEntity(
          pageName: name,
          createdAt: createdAt ??
              utcDateTime
                  .toIso8601String(), // Default to current UTC time if not provided.
          customData: customData);

      // Track the navigation event using the repository and return the result.
      return _repository.navigate(navigation);
    } catch (e) {
      loggerError(
          'Error tracking navigation event: $e'); // Log the error in debug mode.

      return false; // Return false if there was an error.
    }
  }
}
