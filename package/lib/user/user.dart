import 'dart:async';

import 'package:dito_sdk/user/user_entity.dart';
import 'package:dito_sdk/user/user_repository.dart';

interface class UserInterface {
  UserInterface();

  FutureOr<bool> identify(UserEntity? user) => UserRepository().identify(user);

  void set(UserEntity user) => UserRepository().set(user);

  String? get id => UserRepository().data.userID;

  String? get name => UserRepository().data.name;

  String? get email => UserRepository().data.email;

  String? get cpf => UserRepository().data.cpf;

  String? get gender => UserRepository().data.gender;

  String? get birthday => UserRepository().data.birthday;

  String? get location => UserRepository().data.location;

  Map<String, dynamic>? get customData => UserRepository().data.customData;

  bool get isNotValid => UserRepository().data.isNotValid;

  UserEntity get user => UserRepository().data;
}
