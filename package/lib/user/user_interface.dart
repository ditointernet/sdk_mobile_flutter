import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../event/event_repository.dart';
import '../utils/custom_data.dart';
import 'address_entity.dart';
import 'token_repository.dart';
import 'user_entity.dart';
import 'user_repository.dart';

/// `UserInterface` defines methods for interacting with the user repository,
/// handling user identification and login flows, and managing related tokens.
interface class UserInterface {
  /// Repository instance for managing user-related operations.
  final UserRepository _repository = UserRepository();

  /// Repository instance for managing event-related operations.
  final EventRepository _eventRepository = EventRepository();

  /// Provides access to the current user's data by retrieving it from the repository.
  ///
  /// Returns a [UserEntity] object representing the user's information.
  UserEntity get data => _repository.data;

  /// Provides access to the `TokenRepository` for handling token-related operations.
  TokenRepository get token => TokenRepository();

  /// Identifies the user by saving their data and sending it to Dito.
  ///
  /// - [userID] is the required identifier of the user.
  /// - Optional parameters like [name], [cpf], [email], [gender], [birthday], etc.,
  ///   allow the specification of additional user details.
  /// - [mobileToken] can be passed, or it will be fetched using FirebaseMessaging if not provided.
  /// - [customData] allows sending extra information related to the user.
  ///
  /// Returns a [Future] that completes with `true` if the user identification is successful.
  Future<bool> identify({
    required String userID,
    String? name,
    String? cpf,
    String? email,
    String? gender,
    String? birthday,
    String? phone,
    String? city,
    String? street,
    String? state,
    String? postalCode,
    String? country,
    String? mobileToken,
    Map<String, dynamic>? customData,
  }) async {
    try {
      // Retrieve the mobile token. Use the provided token if available; otherwise,
      // fetch it from FirebaseMessaging.
      final String userCurrentToken =
          mobileToken ?? await FirebaseMessaging.instance.getToken() ?? "";

      // Create an AddressEntity instance to hold the user's address information.
      final address = AddressEntity(
        city: city,
        street: street,
        state: state,
        postalCode: postalCode,
        country: country,
      );

      // Create a UserEntity instance with the provided user information.
      final user = UserEntity(
        userID: userID,
        name: name,
        cpf: cpf,
        email: email,
        gender: gender,
        birthday: birthday,
        phone: phone,
        address: address,
        token: userCurrentToken,
        customData: customData,
      );

      // Retrieve any custom data version and merge it with the user's custom data.
      final version = await customDataVersion;
      if (user.customData == null) {
        user.customData = version;
      } else {
        user.customData?.addAll(version);
      }

      // Identify the user in the repository and verify any pending events.
      final resultIdentify = await _repository.identify(user);
      await _eventRepository.verifyPendingEvents();
      await token.verifyPendingEvents();

      return resultIdentify;
    } catch (e) {
      // Log the error if running in debug mode.
      if (kDebugMode) {
        print('Error identifying user: $e');
      }
      return false;
    }
  }

  /// Logs the user into the system by sending a login event to Dito.
  ///
  /// - [userID] is the required identifier of the user.
  /// - [mobileToken] is optional and, if not provided, it will be fetched using FirebaseMessaging.
  ///
  /// Returns a [Future] that completes with `true` if the login was successful.
  Future<bool> login({required String userID, String? mobileToken}) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final user = UserEntity(userID: userID, token:  mobileToken ?? token);
      // Log the user in through the repository and verify any pending events.
      return await _repository.login(user);
    } catch (e) {
      // Log the error if running in debug mode.
      if (kDebugMode) {
        print('Error identifying user: $e');
      }
      return false;
    }
  }
}
