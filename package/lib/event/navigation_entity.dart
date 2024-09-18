import 'dart:convert';

class NavigationEntity {
  String pageName;
  String? createdAt;
  Map<String, dynamic>? customData;


  NavigationEntity({
    required this.pageName,
    this.createdAt,
    this.customData,
  });

  factory NavigationEntity.fromMap(Map<String, dynamic> map) {
    return NavigationEntity(
      pageName: map['pageName'],
      createdAt: map['createdAt'],
      customData:
          map['customData'] != null ? jsonDecode(map['customData']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageName': pageName,
      'createdAt': createdAt,
      'data': customData,
    };
  }
}
