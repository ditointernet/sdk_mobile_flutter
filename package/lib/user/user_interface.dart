import 'dart:async';

import '../event/event_repository.dart';
import '../utils/custom_data.dart';
import '../utils/logger.dart';
import 'address_entity.dart';
import 'token_repository.dart';
import 'user_entity.dart';
import 'user_repository.dart';

/// `UserInterface` defines methods for interacting with the user repository,
/// handling user identification and login flows, and managing related tokens.
interface class UserInterface {
  final UserRepository _repository = UserRepository();
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
      final String userCurrentToken = mobileToken ?? await token.data ?? "";

      final address = AddressEntity(
        city: city,
        street: street,
        state: state,
        postalCode: postalCode,
        country: country,
      );

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

      final version = await customDataVersion;
      if (user.customData == null) {
        user.customData = version;
      } else {
        user.customData?.addAll(version);
      }

      final resultIdentify = await _repository.identify(user);
      await _eventRepository.verifyPendingEvents();
      await token.verifyPendingEvents();

      return resultIdentify;
    } catch (e) {
      loggerError('Error identifying user: $e');

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
      final String userCurrentToken = mobileToken ?? await token.data ?? "";
      final user = UserEntity(userID: userID, token: userCurrentToken);

      final result = await _repository.login(user);
      await _eventRepository.verifyPendingEvents();
      await token.verifyPendingEvents();

      return result;
    } catch (e) {
      loggerError('Error identifying user: $e');

      return false;
    }
  }
}
