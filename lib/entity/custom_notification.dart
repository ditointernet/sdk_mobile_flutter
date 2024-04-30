import 'package:firebase_messaging/firebase_messaging.dart';

import 'data_payload.dart';

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
