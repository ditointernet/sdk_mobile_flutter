import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_sdk_test/services/data_payload.dart';

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