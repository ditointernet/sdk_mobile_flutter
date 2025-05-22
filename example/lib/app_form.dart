import 'package:dito_sdk/dito_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppForm extends StatefulWidget {
  const AppForm({super.key});

  @override
  AppFormState createState() {
    return AppFormState();
  }
}

class AppFormState extends State<AppForm> {
  final _formKey = GlobalKey<FormState>();

  final cpfController = TextEditingController(text: "33333333333");
  final emailController = TextEditingController(text: "testepush@dito.com.br");

  @override
  Widget build(BuildContext context) {
    final dito = Provider.of<DitoSDK>(context);

    @override
    void dispose() {
      // Clean up the controller when the widget is disposed.
      cpfController.dispose();
      emailController.dispose();
      super.dispose();
    }

    identify() async {
      dito.identify(
        userID: cpfController.text,
        cpf: cpfController.text,
        name: emailController.text,
        email: emailController.text,
      );
      await dito.identifyUser();

      final token = await dito.notificationService().getDeviceFirebaseToken();

      if (token != null && token.isNotEmpty) {
        dito.registryMobileToken(token: token);
      }
    }

    handleIdentify() async {
      if (_formKey.currentState!.validate()) {
        await identify();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuário identificado')));
      }
    }

    handleNotification() async {
      if (_formKey.currentState!.validate()) {
        await identify();
        await dito.trackEvent(eventName: 'action-test');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento de notificação solicitado')),
        );
      }
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: cpfController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: handleIdentify,
                      child: const Text('Registrar Identify'),
                    ),
                    OutlinedButton(
                      onPressed: handleNotification,
                      child: const Text('Receber Notification'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
