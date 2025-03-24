import 'dart:convert';

import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/entity/custom_notification.dart';
import 'package:dito_sdk/entity/data_payload.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DitoSDK dito = DitoSDK();
  dito.initialize(
    apiKey: Constants.ditoApiKey,
    secretKey: Constants.ditoSecretKey,
  );

  await dito.initializePushNotificationService();
  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  dito.notificationService().showLocalNotification(
    CustomNotification(
      id: message.hashCode,
      title: notification.details.title,
      body: notification.details.message,
      payload: notification,
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(
    apiKey: Constants.ditoApiKey,
    secretKey: Constants.ditoSecretKey,
  );

  await dito.initializePushNotificationService();

  runApp(
    MultiProvider(
      providers: [
        Provider<DitoSDK>(
          create: (context) {
            dito.notificationService().onClick = (
              Map<String, dynamic> payload,
            ) {
              print(payload);
            };

            return dito;
          },
        ),
      ],
      child: const App(),
    ),
  );
}
