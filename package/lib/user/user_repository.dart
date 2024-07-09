import 'dart:async';

import '../data/dito_api.dart';
import '../utils/custom_data.dart';
import 'user_entity.dart';

final class UserData extends UserEntity {
  UserData._internal();

  static final userData = UserData._internal();

  factory UserData() => userData;
}

class UserRepository {
  final _userData = UserData();
  final DitoApi api = DitoApi();

  /// This method get a user data on Static Data Object UserData
  /// Return a UserEntity Class
  UserEntity get data {
    return _userData;
  }

  /// This method set a user data on Static Data Object UserData
  Future<void> _set(UserEntity user) async {
    _userData.userID = user.userID;
    if (user.cpf != null) _userData.cpf = user.cpf;
    if (user.name != null) _userData.name = user.name;
    if (user.email != null) _userData.email = user.email;
    if (user.gender != null) _userData.gender = user.gender;
    if (user.birthday != null) _userData.birthday = user.birthday;
    if (user.location != null) _userData.location = user.location;

    final version = await customDataVersion;
    if (user.customData != null) {
      _userData.customData = user.customData;
      _userData.customData!.addAll(version);
    } else {
      _userData.customData = version;
    }
  }

  /// This method enable user data save and send to DitoAPI
  /// Return bool with true when the identify was successes
  Future<bool> identify(UserEntity? user) async {
    bool result = false;
    if (user != null) await _set(user);

    if (_userData.isNotValid) {
      throw Exception('User registration id (userID) is required');
    }

    result = await api
        .identify(user!)
        .then((response) => true)
        .catchError((error) => false);

    if (result) {
      result = await api
          .updateUserData(user)
          .then((response) => true)
          .catchError((error) => false);
    }

    return result;
  }
}
