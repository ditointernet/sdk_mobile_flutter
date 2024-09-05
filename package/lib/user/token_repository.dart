import 'dart:async';
import 'dart:convert';

import 'package:dito_sdk/user/user_repository.dart';
import 'package:flutter/foundation.dart';

import '../api/dito_api_interface.dart';
import '../proto/api.pb.dart';
import 'user_dao.dart';
import 'user_entity.dart';

class TokenRepository {
  final ApiInterface _api = ApiInterface();
  final UserDAO _userDAO = UserDAO();
  final UserRepository _userRepository = UserRepository();

  UserEntity get _userData => _userRepository.data;

  /// Registers the FCM token with the server.
  ///
  /// [token] - The FCM token to be registered.
  /// Returns an http.Response from the server.
  Future<bool> registryToken(String? token) async {
    if (token!.isEmpty && _userData.token != null && _userData.token!.isEmpty) {
      throw Exception('User registration token is required');
    }

    if (token.isNotEmpty) _userData.token = token;

    if (_userData.isNotValid) {
      return await _userDAO.create(UserEventsNames.registerToken, _userData);
    }

    final activities = [ApiActivities().registryToken(_userData.token!)];
    final result = await _api.createRequest(activities).call;

    if (!result) {
      return await _userDAO.create(UserEventsNames.registerToken, _userData);
    }

    return result;
  }

  /// Registers the FCM token with the server.
  ///
  /// [token] - The FCM token to be registered.
  /// Returns an http.Response from the server.
  Future<bool> pingToken(String? token) async {
    if (token!.isEmpty && _userData.token != null && _userData.token!.isEmpty) {
      throw Exception('User registration token is required');
    }

    if (token.isNotEmpty) _userData.token = token;

    if (_userData.isNotValid) {
      return await _userDAO.create(UserEventsNames.pingToken, _userData);
    }

    final activities = [ApiActivities().pingToken(_userData.token!)];
    final result = await _api.createRequest(activities).call;

    if (!result) {
      return await _userDAO.create(UserEventsNames.pingToken, _userData);
    }

    return result;
  }

  /// Removes the FCM token from the server.
  ///
  /// [token] - The FCM token to be removed.
  /// Returns an http.Response from the server.
  Future<bool> removeToken(String? token) async {
    if (token!.isEmpty && _userData.token != null && _userData.token!.isEmpty) {
      throw Exception('User registration token is required');
    }

    if (token.isNotEmpty) _userData.token = token;

    if (_userData.isNotValid) {
      return await _userDAO.create(UserEventsNames.removeToken, _userData);
    }

    final activities = [ApiActivities().removeToken(_userData.token!)];
    final result = await _api.createRequest(activities).call;

    if (!result) {
      return await _userDAO.create(UserEventsNames.removeToken, _userData);
    }

    return result;
  }

  /// Verifies and processes any pending events.
  ///
  /// Throws an exception if the user is not valid.
  Future<void> verifyPendingEvents() async {
    try {
      final events = await _userDAO.fetchAll();
      List<Activity> activities = [];

      for (final event in events) {
        final eventName = event["eventName"] as UserEventsNames;
        final user = UserEntity.fromMap(jsonDecode(event["user"] as String));

        switch (eventName) {
          case UserEventsNames.registerToken:
            activities.add(ApiActivities().registryToken(user.token!));
            break;
          case UserEventsNames.removeToken:
            activities.add(ApiActivities().removeToken(user.token!));
            break;
          case UserEventsNames.pingToken:
            activities.add(ApiActivities().pingToken(user.token!));
            break;
          default:
            break;
        }
      }

      await _api.createRequest(activities).call;
      await _userDAO.clearDatabase();
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying pending events on notification: $e');
      }
      rethrow;
    }
  }
}
