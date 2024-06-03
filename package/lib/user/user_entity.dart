import 'dart:convert';

class UserEntity {
  String? userID;
  String? name;
  String? cpf;
  String? email;
  String? gender;
  String? birthday;
  String? location;
  Map<String, dynamic>? customData;

  UserEntity(
      {this.userID,
      this.name,
      this.cpf,
      this.email,
      this.gender,
      this.birthday,
      this.location,
      this.customData});

  String? get id => userID;

  bool get isValid => userID!.isNotEmpty;

  bool get isNotValid => !isValid;

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
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

@Deprecated("This data class was deprecated! ")
class User extends UserEntity {}
