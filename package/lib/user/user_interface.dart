import 'dart:async';

import 'package:dito_sdk/user/user_entity.dart';
import 'package:dito_sdk/user/user_repository.dart';

/// This is a interface from user to communicate with user repository
interface class UserInterface {
  /// This method enable user data save and send to DitoAPI
  /// Return bool with true when the identify was successes
  FutureOr<bool> identify(UserEntity? user) => UserRepository().identify(user);

  /// This get method enable to access user data from repository
  /// Returns UserEntity Class
  UserEntity get data => UserRepository().data;
}
