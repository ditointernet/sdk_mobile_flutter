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

  @override
  Widget build(BuildContext context) {
    final dito = Provider.of<DitoSDK>(context);

    String cpf = "33333333333";
    String email = "teste.sdk-flutter@dito.com.br";

    identify() async {
      await dito.user.identify(
          userID: "e400c65b1800bee5bf546c5b7bd37cd4f7452bb8",
          cpf: cpf,
          name: 'Teste SDK Flutter 33333333333',
          email: email);
    }

    handleIdentify() async {
      if (_formKey.currentState!.validate()) {
        await identify().then((response) => {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuário identificado')),
              )
            });
      }
    }

    handleNotification() async {
      if (_formKey.currentState!.validate()) {
        await dito.event.track(action: 'action-test');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento de notificação solicitado')),
        );
      }
    }

    handleDeleteToken() async {
      await dito.user.token.removeToken(dito.user.data.token);
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onChanged: (value) {
              cpf = value;
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
            onChanged: (value) {
              email = value;
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
