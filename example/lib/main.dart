import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'constants.dart';

Future<DitoSDK> _setupDito() async {
  DitoSDK dito = DitoSDK();
  dito.initialize(
    apiKey: Constants.ditoApiKey,
    secretKey: Constants.ditoSecretKey,
  );
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
