import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DitoSDK dito = DitoSDK();
  dito.onBackgroundMessageHandler(message,
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
  dito.setOnMessageClick((data) {
    print('app is in a terminated or background state');
    print(data.toJson());
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
  await dito.initializePushNotificationService();
  dito.setOnMessageClick((data) {
    print('app is open');
    print(data.toJson());
  });

  runApp(MultiProvider(providers: [
    Provider<DitoSDK>(
      create: (context) {
        return dito;
      },
    ),
  ], child: const App()));
}
