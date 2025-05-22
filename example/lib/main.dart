import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';

Future<DitoSDK> _setupDito() async {
  final String ditoApiKey = String.fromEnvironment('API_KEY');
  final String ditoSecretKey = String.fromEnvironment('SECRET_KEY');

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: ditoApiKey, secretKey: ditoSecretKey);
  await dito.initializePushNotificationService();

  dito.notificationService().onClick = (String link) {
    print(link);
  };

  return dito;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _setupDito();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final dito = await _setupDito();

  runApp(
    MultiProvider(
      providers: [
        Provider<DitoSDK>(
          create: (context) {
            return dito;
          },
        ),
      ],
      child: const App(),
    ),
  );
}
