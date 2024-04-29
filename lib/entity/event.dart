import 'dart:convert';

class Event {
  final String eventName;
  final String eventMoment;
  final double? revenue;
  final Map<String, dynamic>? customData;

  Event({
    required this.eventName,
    required this.eventMoment,
    this.revenue,
    this.customData,
  });

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventName: map['eventName'],
      eventMoment: map['eventMoment'],
      revenue: map['revenue'],
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
      'customData': customData != null ? json.encode(customData) : null,
    };
  }

  Map<String, dynamic> toJson() => {
        'action': eventName,
        'revenue': revenue,
        'data': customData,
        'created_at': eventMoment
      };
}
