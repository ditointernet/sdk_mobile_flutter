import 'package:dito_sdk/dito_sdk.dart';
import 'package:dito_sdk/user/user_entity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

    String cpf = "32190381209";
    String email = "teste.sdk2@dito.com.br";

    identify() async {
      final user = UserEntity(
          userID: cpf, cpf: cpf, name: 'Teste SDK Flutter', email: email);

      await dito.user.identify(user);
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

    handleDeleteToken() async {
      await FirebaseMessaging.instance.deleteToken();
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
                    OutlinedButton(
                      onPressed: handleDeleteToken,
                      child: const Text('Deletar token'),
                    ),
                  ])))
        ],
      ),
    );
  }
}
