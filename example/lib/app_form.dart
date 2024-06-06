import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/entity/custom_notification.dart';
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

  @override
  Widget build(BuildContext context) {
    final dito = Provider.of<DitoSDK>(context);

    String cpf = "22222222222";
    String email = "teste@dito.com.br";

    identify() async {
      dito.identify(
          userID: cpf, cpf: cpf, name: 'Teste SDK Flutter', email: email);
      await dito.identifyUser();

      final token = await dito.notificationService().getDeviceFirebaseToken();

      if (token != null && token.isNotEmpty) {
        dito.registryMobileToken(token: token);
      }
    }

    handleIdentify() async {
      if (_formKey.currentState!.validate()) {
        await identify();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário identificado')),
        );
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

    handleLocalNotification() {
      dito.notificationService().addNotificationToStream(CustomNotification(
          id: 123,
          title: "Notificação local",
          body:
              "Está é uma mensagem de teste, validando o stream de dados das notificações locais"));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Push enviado para a fila')),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onSaved: (value) {
              cpf = value!;
            },
            initialValue: cpf,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            onSaved: (value) {
              email = value!;
            },
            initialValue: email,
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
                  child: Column(children: [
                    FilledButton(
                      onPressed: handleIdentify,
                      child: const Text('Registrar Identify'),
                    ),
                    OutlinedButton(
                      onPressed: handleNotification,
                      child: const Text('Receber Notification'),
                    ),
                    TextButton(
                      onPressed: handleLocalNotification,
                      child: const Text('Criar notificação local'),
                    )
                  ])))
        ],
      ),
    );
  }
}
