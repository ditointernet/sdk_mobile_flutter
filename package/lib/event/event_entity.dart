import 'dart:convert';

class EventEntity {
  String eventName;
  String? eventMoment;
  double? revenue;
  Map<String, dynamic>? customData;

  EventEntity({
    required this.eventName,
    this.revenue,
    this.eventMoment,
    this.customData,
  });

  factory EventEntity.fromMap(Map<String, dynamic> map) {
    return EventEntity(
      eventName: map['eventName'],
      revenue: map['revenue'],
      eventMoment: map['eventMoment'],
      customData: map['customData'] != null
          ? (json.decode(map['customData']) as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value as String))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventMoment': eventMoment,
      'revenue': revenue,
      'customData': customData != null ? jsonEncode(customData) : null,
    };
  }

  Map<String, dynamic> toJson() => {
        'action': eventName,
        'revenue': revenue,
        'data': customData,
        'created_at': eventMoment
      };
}