import 'dart:async';

import '../data/dito_api_interface.dart';
import 'user_entity.dart';

final class UserData extends UserEntity {
  UserData._internal();

  static final userData = UserData._internal();

  factory UserData() => userData;
}

class UserRepository {
  final _userData = UserData();
  final DitoApiInterface api = DitoApiInterface();

  /// This method get a user data on Static Data Object UserData
  /// Return a UserEntity Class
  UserEntity get data {
    return _userData;
  }

  /// This method set a user data on Static Data Object UserData
  void _set(UserEntity user) {
    _userData.userID = user.userID;
    if (user.cpf != null) _userData.cpf = user.cpf;
    if (user.name != null) _userData.name = user.name;
    if (user.email != null) _userData.email = user.email;
    if (user.gender != null) _userData.gender = user.gender;
    if (user.birthday != null) _userData.birthday = user.birthday;
    if (user.address != null) _userData.address = user.address;
    if (user.customData != null) _userData.customData = user.customData;
  }

  /// This method enable user data save and send to DitoAPI
  /// Return bool with true when the identify was successes
  Future<bool> identify(UserEntity? user) async {
    if (user != null) _set(user);

    if (_userData.isNotValid) {
      throw Exception('User registration id (userID) is required');
    }

    return await api
        .identify(user!)
        .then((response) => true)
        .catchError((error) => false);
  }
}
