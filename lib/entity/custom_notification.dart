import 'package:dito_sdk/entity/data_payload.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CustomNotification {
  final int id;
  final String title;
  final String body;
  final DataPayload? payload;
  final RemoteMessage? remoteMessage;

  CustomNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.remoteMessage,
  });
}
