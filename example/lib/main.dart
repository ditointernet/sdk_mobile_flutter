import 'dart:convert';

import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdk_test/constants.dart';
import 'package:flutter_sdk_test/services/custom_notification.dart';
import 'package:flutter_sdk_test/services/data_payload.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/firebase_messaging_service.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final appName = packageInfo.appName;

  DitoSDK dito = DitoSDK();
  dito.initialize(
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);

  NotificationService notificationService = NotificationService(dito);
  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  notificationService.showLocalNotification(CustomNotification(
      id: message.hashCode,
      title: appName,
      body: notification.details.message,
      payload: notification));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(providers: [
    Provider<DitoSDK>(
      create: (context) {
        DitoSDK dito = DitoSDK();
        dito.initialize(
            apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);

        return dito;
      },
    ),
    Provider<NotificationService>(
      create: (context) => NotificationService(context.read<DitoSDK>()),
    ),
    Provider<FirebaseMessagingService>(
      create: (context) =>
          FirebaseMessagingService(context.read<NotificationService>()),
    ),
  ], child: const App()));
}
