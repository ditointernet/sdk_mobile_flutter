import 'dart:async';

import '../api/dito_api_interface.dart';
import 'user_entity.dart';

final class UserData extends UserEntity {
  UserData._internal();

  static final userData = UserData._internal();

  factory UserData() => userData;
}

class UserRepository {
  final _userData = UserData();
  final ApiInterface _api = ApiInterface();

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
    if (user.token != null) _userData.token = user.token;
  }

  /// This method enable user data save and send to Dito
  /// Return bool with true when the identify was successes
  Future<bool> identify(UserEntity? user) async {
    if (user != null) _set(user);

    if (_userData.isNotValid) {
      throw Exception('User registration id (userID) is required');
    }

    final activities = [ApiActivities().identify()];
    return await _api.createRequest(activities).call();
  }

  /// This method enable user data save and send to Dito
  /// Return bool with true when the identify was successes
  Future<bool> login(UserEntity? user) async {
    if (user != null) _set(user);

    if (_userData.isNotValid) {
      throw Exception('User id (userID) is required');
    }

    final activities = [ApiActivities().login()];
    return await _api.createRequest(activities).call();
  }
}
