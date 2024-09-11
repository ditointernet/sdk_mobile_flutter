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

    identify() {
      return dito.user.identify(
          userID: "1575213826e164f73d28c4ed1b5fabaad4bd4a13",
          cpf: cpf,
          name: 'Teste SDK Flutter 33333333333',
          email: email);
    }

    login() {
      return dito.user
          .login(userID: '1575213826e164f73d28c4ed1b5fabaad4bd4a13');
    }

    handleIdentify() async {
      if (_formKey.currentState!.validate()) {
        final bool response = await identify();

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário identificado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ocorreu um erro!'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }

    handleLogin() async {
      if (_formKey.currentState!.validate()) {
        final bool response = await login();

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário logado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ocorreu um erro!'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }

    handleGenericTrack() async {
      if (_formKey.currentState!.validate()) {
        final bool response = await dito.event.track(action: 'action-test');

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento de notificação solicitado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ocorreu um erro!'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }

    handleNavigation() async {
      if (_formKey.currentState!.validate()) {
        final bool response = await dito.event.navigate(name: 'home');

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento de notificação solicitado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ocorreu um erro!'),
                backgroundColor: Colors.redAccent),
          );
        }
      }
    }

    handleClickNotification() async {
      if (_formKey.currentState!.validate()) {
        final bool response = await dito.notification.click(
          identifier: 'identifier-not-sdk-test',
          notification: 'notification-sdk-test',
          notificationLogId: 'notification-dispatch-sdk-test',
          reference: "reference-notification-sdk-test"
        );

        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento de notificação solicitado')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ocorreu um erro!'),
                backgroundColor: Colors.redAccent),
          );
        }
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
                      child: const Text('Registrar usuário'),
                    ),
                    FilledButton(
                      onPressed: handleLogin,
                      child: const Text('Logar usuário'),
                    ),
                    OutlinedButton(
                      onPressed: handleGenericTrack,
                      child: const Text('Registrar evento genérico'),
                    ),
                    OutlinedButton(
                      onPressed: handleNavigation,
                      child: const Text('Registrar evento de navegação'),
                    ),
                    OutlinedButton(
                      onPressed: handleClickNotification,
                      child: const Text('Registrar evento de click'),
                    ),
                    FilledButton(
                      onPressed: handleDeleteToken,
                      child: const Text('Deletar token'),
                    ),
                  ])))
        ],
      ),
    );
  }
}
