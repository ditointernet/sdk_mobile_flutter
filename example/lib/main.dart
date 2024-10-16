import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

const apiKey = String.fromEnvironment(
  'API_KEY',
  defaultValue: '',
);

const secretKey = String.fromEnvironment(
  'SECRET_KEY',
  defaultValue: '',
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: apiKey, secretKey: secretKey);
  dito.onBackgroundPushNotificationHandler(message: message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: apiKey, secretKey: secretKey);
  await dito.initializePushNotificationService();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  dito.notification.onMessageClick = (data) {
    if (kDebugMode) {
      print(data);
    }
  };

  runApp(MultiProvider(providers: [
    Provider<DitoSDK>(
      create: (context) {
        return dito;
      },
    ),
  ], child: const App()));
}
