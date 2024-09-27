import 'dart:convert';

import 'address_entity.dart';

class UserEntity {
  String? userID;
  String? name;
  String? cpf;
  String? email;
  String? gender;
  String? birthday;
  String? phone;
  AddressEntity? address;
  String? token;
  Map<String, dynamic>? customData;

  UserEntity(
      {this.userID,
      this.name,
      this.cpf,
      this.email,
      this.gender,
      this.birthday,
      this.phone,
      this.address,
      this.token,
      this.customData});

  String? get id => userID;

  /// User is valid when userId is not empty
  bool get isValid => userID != null && userID!.isNotEmpty;

  bool get isNotValid => userID == null || userID!.isEmpty;

  // Factory method to instance a user from a JSON object
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    final address = map['address'] != null 
      ? AddressEntity.fromMap(map['address'] as Map<String, dynamic>) 
      : null;
    return UserEntity(
        userID: map['userID'],
        name: map['name'],
        cpf: map['cpf'],
        email: map['email'],
        gender: map['gender'],
        birthday: map['birthday'],
        phone: map['phone'],
        token: map['token'],
        address: address,
        customData: map['customData'] != null
            ? (json.decode(map['customData']) as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value as String))
            : null);
  }

  // Factory method to convert a user to JSON object
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': cpf,
      'email': email,
      'gender': gender,
      'birthday': birthday,
      'phone': phone,
      'token': token,
      'address': address?.toJson() ?? {},
      'data': customData != null ? jsonEncode(customData) : null,
    };
  }

  // Factory method to convert a user to Map object
  Map<String, dynamic> toMap() {
    return toJson();
  }
}
