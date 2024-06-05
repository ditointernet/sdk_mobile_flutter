import 'dart:async';
import 'dart:convert';

import '../constants.dart';
import '../entity/domain.dart';
import '../utils/http.dart';
import 'user_entity.dart';

final class UserData extends UserEntity {
  UserData._internal();

  static final userData = UserData._internal();

  factory UserData() => userData;
}

class UserRepository {
  final _userData = UserData();

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
    if (user.location != null) _userData.location = user.location;
    if (user.customData != null) _userData.customData = user.customData;
  }

  /// This method enable user data save and send to DitoAPI
  /// Return bool with true when the identify was successes
  FutureOr<bool> identify(UserEntity? user) async {
    if (user != null) _set(user);

    if (_userData.isNotValid) {
      throw Exception('User registration id (userID) is required');
    }

    final queryParameters = {
      'user_data': jsonEncode(_userData.toJson()),
    };

    final url = Domain(Endpoint.identify.replace(_userData.id!)).spited;
    final uri = Uri.https(url[0], url[1], queryParameters);

    return await Api().post(url: uri).then((response) {
      if (response.statusCode == 200) {
        // TODO: Notify event class to send pending events of database

        return true;
      }

      return false;
    }).catchError((e) {
      return false;
    });
  }
}
