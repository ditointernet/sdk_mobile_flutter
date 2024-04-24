import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdk_test/app_form.dart';
import 'package:provider/provider.dart';

import 'services/firebase_messaging_service.dart';
import 'services/notification_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override

  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    initializeDito();
    init();
  }

  initializeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false)
        .initialize();
  }

  initializeDito() {
    Provider.of<DitoSDK>(context, listen: false);
  }

  init() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notification Demo',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test SDK Flutter'),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(15.0),
              child: const AppForm(),
            ),
          ),
        ));
  }
}
