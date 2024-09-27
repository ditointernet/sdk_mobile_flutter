import 'dart:async';

import 'package:flutter/foundation.dart';
import '../api/dito_api_interface.dart';
import '../proto/api.pb.dart';
import 'user_entity.dart';
import 'user_dao.dart';

final class UserData extends UserEntity {
  UserData._internal();

  static final userData = UserData._internal();

  factory UserData() => userData;
}

class UserRepository {
  final _userData = UserData();
  final ApiInterface _api = ApiInterface();
  final UserDAO _userDAO = UserDAO();

  /// This method get a user data on Static Data Object UserData
  /// Return a UserEntity Class
  UserEntity get data {
    return _userData;
  }

  /// This method set a user data on Static Data Object UserData
  void _set(UserEntity user) {
    _userData.userID = user.userID;
    if (user.phone != null) _userData.phone = user.phone;
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

    final activity = ApiActivities().identify();

    try {
      return await _api.createRequest([activity]).call();
    } catch (e) {
      return await _userDAO.create(UserEventsNames.identify, _userData, activity.id);
    }
  }

  /// This method enable user data save and send to Dito
  /// Return bool with true when the identify was successes
  Future<bool> login(UserEntity? user) async {
    if (user != null) _set(user);

    if (_userData.isNotValid) {
      throw Exception('User id (userID) is required');
    }

    final activity = ApiActivities().login();

    try {
      return await _api.createRequest([activity]).call();
    } catch (e) {
      return await _userDAO.create(UserEventsNames.login, _userData, activity.id);
    }
  }

  Future<void> verifyPendingEvents() async {
    try {
      final events = await _userDAO.fetchAll();
      List<Activity> activities = [];

      for (final event in events) {
        final eventName = event["name"] as String;        
        final uuid = event["uuid"] as String? ?? null;
        final time = event["createdAt"] as String? ?? null;

        switch (eventName) {
          case 'identify':
            activities.add(ApiActivities().identify(uuid: uuid, time: time));
            break;
          case 'login':
            activities.add(ApiActivities().login(uuid: uuid, time: time));
            break;
          default:
            break;
        }
      }

      if (activities.isNotEmpty) {
        await _api.createRequest(activities).call();
      }
      
      return await _userDAO.clearDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events on notification: $e');
      }
      rethrow;
    }
  }
}
