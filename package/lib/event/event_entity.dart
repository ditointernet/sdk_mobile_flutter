import 'dart:convert';

class EventEntity {
  String eventName;
  String? eventMoment;
  double? revenue;
  String? currency;
  Map<String, dynamic>? customData;

  EventEntity({
    required this.eventName,
    this.revenue,
    this.eventMoment,
    this.currency,
    this.customData,
  });

  factory EventEntity.fromMap(Map<String, dynamic> map) {
    return EventEntity(
      eventName: map['eventName'],
      revenue: map['revenue'],
      eventMoment: map['eventMoment'],
      currency: map['currency'],
      customData:
          map['customData'] != null ? json.decode(map['customData']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventMoment': eventMoment,
      'revenue': revenue,
      'currency': currency,
      'customData': customData != null ? jsonEncode(customData) : null,
    };
  }

  Map<String, dynamic> toJson() {
    final json = {
      'action': eventName,
      'revenue': revenue,
      'currency': currency,
      'data': customData,
      'created_at': eventMoment
    };

    json.removeWhere((key, value) => value == null);

    return json;
  }
}
