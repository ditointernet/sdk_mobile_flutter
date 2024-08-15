import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
  dito.onBackgroundPushNotificationHandler(message: message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
  await dito.initializePushNotificationService();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  dito.notification.onMessageClick = (data) {
    if (kDebugMode) {
      print(data.toJson());
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
