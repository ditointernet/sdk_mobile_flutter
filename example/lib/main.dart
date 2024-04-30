import 'dart:convert';

import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/entity/custom_notification.dart';
import 'package:dito_sdk/entity/data_payload.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';


import 'app.dart';
import 'constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final appName = packageInfo.appName;

  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);

  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  dito.notificationService().showLocalNotification(CustomNotification(
      id: message.hashCode,
      title: appName,
      body: notification.details.message,
      payload: notification));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
  await dito.initializePushNotificationService();

  runApp(MultiProvider(providers: [
    Provider<DitoSDK>(
      create: (context) {
        return dito;
      },
    ),
  ], child: const App()));
}
