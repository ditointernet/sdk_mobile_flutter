import 'dart:async';

import 'package:dito_sdk/user/token_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../event/event_repository.dart';
import '../utils/custom_data.dart';
import 'address_entity.dart';
import 'user_entity.dart';
import 'user_repository.dart';

/// UserInterface is an interface for communication with the user repository
interface class UserInterface {
  final UserRepository _repository = UserRepository();
  final EventRepository _eventRepository = EventRepository();

  /// Gets the user data from the repository.
  ///
  /// Returns the UserEntity object containing user data.
  UserEntity get data => _repository.data;
  TokenRepository get token => TokenRepository();


  /// Identifies the user by saving their data and sending it to Dito.
  ///
  /// [user] - The UserEntity object containing user data.
  /// Returns a Future that completes with true if the identification was successful.
  Future<bool> identify(
      {required String userID,
      String? name,
      String? cpf,
      String? email,
      String? gender,
      String? birthday,
      String? city,
      String? street,
      String? state,
      String? postalCode,
      String? country,
      String? mobileToken,
      Map<String, dynamic>? customData}) async {
    final String userCurrentToken =
        mobileToken ?? await FirebaseMessaging.instance.getToken() ?? "";

    final address = AddressEntity(
        city: city,
        street: street,
        state: state,
        postalCode: postalCode,
        country: country);

    final user = UserEntity(
        userID: userID,
        name: name,
        cpf: cpf,
        email: email,
        gender: gender,
        birthday: birthday,
        address: address,
        token: userCurrentToken,
        customData: customData);

    try {
      final version = await customDataVersion;
      if (user.customData == null) {
        user.customData = version;
      } else {
        user.customData?.addAll(version);
      }

      final resultIdentify = await _repository.identify(user);
      _eventRepository.verifyPendingEvents();

      if (userCurrentToken.isNotEmpty) {
        final resultTokenRegistry = await token.registryToken(userCurrentToken);
        token.verifyPendingEvents();

        return resultIdentify && resultTokenRegistry;
      }

      return resultIdentify;
    } catch (e) {
      if (kDebugMode) {
        print('Error identifying user: $e');
      }
      return false;
    }
  }

  /// Send a login event of user to Dito.
  ///
  /// [userID] - The UserEntity object containing user data.
  /// [token] - Mobile Token of user is optional.
  /// Returns a Future that completes with true if the login was successful.
  Future<bool> login({required String userID, String? mobileToken}) async {
    final String userCurrentToken =
        mobileToken ?? await FirebaseMessaging.instance.getToken() ?? "";

    final user = UserEntity(userID: userID, token: userCurrentToken);

    try {
      final resultLogin = await _repository.login(user);
      _eventRepository.verifyPendingEvents();

      if (userCurrentToken.isNotEmpty) {
        final resultTokenRegistry =
            await token.pingToken(userCurrentToken);
        token.verifyPendingEvents();

        return resultLogin && resultTokenRegistry;
      }

      return resultLogin;
    } catch (e) {
      if (kDebugMode) {
        print('Error identifying user: $e');
      }
      return false;
    }
  }
}
