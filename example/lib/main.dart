import 'package:dito_sdk/dito_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler() async {
  DitoSDK dito = DitoSDK();
  dito.onBackgroundPushNotificationHandler(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
  await dito.initializePushNotificationService();

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
