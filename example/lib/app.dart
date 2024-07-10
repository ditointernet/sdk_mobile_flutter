import 'package:dito_sdk/dito_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './app_form.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    initializeDito();
  }

  initializeDito() {
    Provider.of<DitoSDK>(context, listen: false);
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
            body: const Center(
              child: AppForm(),
            )));
  }
}
