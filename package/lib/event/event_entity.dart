import 'dart:convert';

class EventEntity {
  String action;
  String? createdAt;
  double? revenue;
  String? currency;
  Map<String, dynamic>? customData;

  EventEntity({
    required this.action,
    this.revenue,
    this.createdAt,
    this.currency,
    this.customData,
  });

  factory EventEntity.fromMap(Map<String, dynamic> map) {
    return EventEntity(
      action: map['action'],
      revenue: map['revenue'],
      createdAt: map['createdAt'],
      currency: map['currency'],
      customData:
          map['customData'] != null ? jsonDecode(map['customData']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'action': action,
      'revenue': revenue,
      'currency': currency,
      'data': customData,
      'created_at': createdAt
    };

    json.removeWhere((key, value) => value == null);

    return json;
  }
}
