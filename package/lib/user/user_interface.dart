import 'dart:async';

import 'package:dito_sdk/event/event_interface.dart';
import 'package:dito_sdk/user/user_entity.dart';
import 'package:dito_sdk/user/user_repository.dart';
import 'package:flutter/foundation.dart';

import '../utils/custom_data.dart';

/// UserInterface is an interface for communication with the user repository
interface class UserInterface {
  final UserRepository _repository = UserRepository();
  final EventInterface _eventInterface = EventInterface();

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

      final result = await _repository.identify(user);
      await _eventInterface.verifyPendingEvents();

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
