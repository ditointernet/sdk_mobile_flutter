import 'dart:convert';

class User {
  String? userID;
  String? name;
  String? cpf;
  String? email;
  String? gender;
  String? birthday;
  String? location;
  Map<String, dynamic>? customData;

  User(
      {this.userID,
      this.name,
      this.cpf,
      this.email,
      this.gender,
      this.birthday,
      this.location,
      this.customData});

  String? get id => userID;
  bool get isValid => userID != null && userID!.isNotEmpty;
  bool get isNotValid => !isValid;

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
      'name': name,
      'cpf': cpf,
      'email': email,
      'gender': gender,
      'birthday': birthday,
      'location': location,
      'data': customData != null ? jsonEncode(customData) : null,
    };
  }
}
