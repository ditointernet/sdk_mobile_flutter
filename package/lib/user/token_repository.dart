import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:dito_sdk/user/user_repository.dart';
import 'package:flutter/foundation.dart';

import '../api/dito_api_interface.dart';
import '../notification/notification_interface.dart';
import '../proto/api.pb.dart';
import 'user_dao.dart';
import 'user_entity.dart';

class TokenRepository {
  final ApiInterface _api = ApiInterface();
  final UserRepository _userRepository = UserRepository();
  final UserDAO _userDAO = UserDAO();
  final NotificationInterface _notification = NotificationInterface();

  UserEntity get _userData => _userRepository.data;

  /// Registers the FCM token with the server.
  ///
  /// [token] - The FCM token to be registered.
  /// Returns an http.Response from the server.
  Future<bool> registryToken([String? token]) async {
    if (token == null || token.isEmpty) {
      token = await _notification.token;
    }

    if (token!.isEmpty && _userData.token != null && _userData.token!.isEmpty) {
      throw Exception('User registration token is required');
    }

    if (token.isNotEmpty) _userData.token = token;

    final uuid = Uuid().v4();

    if (_userData.isNotValid) {
      return await _userDAO.create(UserEventsNames.registryToken, _userData, uuid);
    }

    final activities = [ApiActivities().registryToken(_userData.token!, uuid: uuid)];

    try {
      return await _api.createRequest(activities).call();
    } catch (e) {
      return await _userDAO.create(UserEventsNames.registryToken, _userData, uuid);
    }
  }

  /// Registers the FCM token with the server.
  ///
  /// [token] - The FCM token to be registered.
  /// Returns an http.Response from the server.
  Future<bool> pingToken([String? token]) async {
    if (token == null || token.isEmpty) {
      token = await _notification.token;
    }

    if (token!.isEmpty && _userData.token != null && _userData.token!.isEmpty) {
      throw Exception('User registration token is required');
    }

    if (token.isNotEmpty) _userData.token = token;

    final uuid = Uuid().v4();

    if (_userData.isNotValid) {
      return await _userDAO.create(UserEventsNames.pingToken, _userData, uuid);
    }

    final activities = [ApiActivities().pingToken(_userData.token!, uuid: uuid)];
    
    try {
      return await _api.createRequest(activities).call();
    } catch (e) {
      return await _userDAO.create(UserEventsNames.pingToken, _userData, uuid);
    }
  }

  /// Removes the FCM token from the server.
  ///
  /// [token] - The FCM token to be removed.
  /// Returns an http.Response from the server.
  Future<bool> removeToken([String? token]) async {
    if (token == null || token.isEmpty) {
      token = await _notification.token;
    }
    
    if (token!.isEmpty && _userData.token != null && _userData.token!.isEmpty) {
      throw Exception('User registration token is required');
    }

    if (_userData.isNotValid) {
      throw Exception('User is required');
    }

    if (token.isNotEmpty) _userData.token = token;

    final activities = [ApiActivities().removeToken(_userData.token!)];
    final result = await _api.createRequest(activities).call();

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
        final eventName = event["name"] as String;
        final user = UserEntity.fromMap(jsonDecode(event["user"] as String));
        final uuid = event["uuid"] as String? ?? null;
        final time = event["createdAt"] as String? ?? null;

        switch (eventName) {
          case 'registryToken':
            activities.add(ApiActivities().registryToken(user.token!, uuid: uuid, time: time));
            break;
          case 'pingToken':
            activities.add(ApiActivities().pingToken(user.token!, uuid: uuid, time: time));
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
