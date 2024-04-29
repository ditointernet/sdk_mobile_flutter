import 'dart:convert';

class User {
  late final String userID;
  late final String? name;
  late final String? cpf;
  late final String? email;
  late final String? gender;
  late final String? birthday;
  late final String? location;
  late final Map<String, dynamic>? customData;

  User(
      {required this.userID,
      this.name,
      this.cpf,
      this.email,
      this.gender,
      this.birthday,
      this.location,
      this.customData});

  validate() {
    return userID.isNotEmpty;
  }

  getUserID() {
    return userID;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        userID: map['userID'],
        name: map['name'],
        cpf: map['cpf'],
        email: map['email'],
        gender: map['gender'],
        birthday: map['birthday'],
        location: map['location'],
        customData: map['customData'] != null
            ? (json.decode(map['customData']) as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, value as String))
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'cpf': name,
      'email': email,
      'gender': gender,
      'birthday': birthday,
      'location': location,
      'customData': customData != null ? json.encode(customData) : null,
    };
  }
}
