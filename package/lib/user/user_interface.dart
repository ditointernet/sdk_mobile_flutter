import 'dart:async';

import 'package:flutter/foundation.dart';

import '../event/event_repository.dart';
import '../utils/custom_data.dart';
import 'user_entity.dart';
import 'user_repository.dart';

/// UserInterface is an interface for communication with the user repository
interface class UserInterface {
  final UserRepository _repository = UserRepository();
  final EventRepository _eventRepository = EventRepository();

  /// Identifies the user by saving their data and sending it to DitoAPI.
  ///
  /// [user] - The UserEntity object containing user data.
  /// Returns a Future that completes with true if the identification was successful.
  Future<bool> identify(UserEntity user) async {
    try {
      final version = await customDataVersion;
      if (user.customData == null) {
        user.customData = version;
      } else {
        user.customData?.addAll(version);
      }

      final result = _repository.identify(user);

      _eventRepository.verifyPendingEvents();

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error identifying user: $e');
      }
      return false;
    }
  }

  /// Gets the user data from the repository.
  ///
  /// Returns the UserEntity object containing user data.
  UserEntity get data => _repository.data;
}
