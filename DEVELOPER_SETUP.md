# DEVELOPER SETUP — Dito SDK (passo a passo)

Este guia descreve passo a passo o que um desenvolvedor precisa fazer para que a SDK Dito Flutter funcione corretamente, incluindo integração de push (FCM).

1) Pré-requisitos
- Flutter e Dart compatíveis com o projeto (ver `pubspec.yaml`).
- Conta e credenciais Dito: `API_KEY` e `SECRET_KEY`.
- Firebase configurado para Android e iOS (para push notifications).

2) Instalar dependências
- Adicione a SDK do Dito ao projeto (pub.dev) ou utilize a dependência local/monorepo.

3) Configurar Firebase (Android / iOS)
- Execute `flutterfire configure` (requer `flutterfire_cli`) ou adicione manualmente `google-services.json` e `GoogleService-Info.plist` aos projetos nativos.

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4) Armazenar credenciais com segurança
- Nunca comite `API_KEY`/`SECRET_KEY` no repositório.
- Use variáveis de ambiente, arquivos seguros do CI, ou secret manager.

Exemplo (iOS/Android runtime):
- Defina variáveis de ambiente no CI ou no `flutter run` se necessário:

```bash
flutter run --dart-define=API_KEY=xxx --dart-define=SECRET_KEY=yyy
```

5) Inicialização (main.dart)
- Garanta que o Firebase seja inicializado antes de iniciar o serviço de push da SDK.

Exemplo recomendado:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dito_sdk/dito_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dito = DitoSDK();
  dito.initialize(
    apiKey: const String.fromEnvironment('API_KEY'),
    secretKey: const String.fromEnvironment('SECRET_KEY'),
  );
  await dito.initializePushNotificationService();

  // Exemplo de callback de clique em notificação
  dito.notificationService().onClick = (String link) {
    // deep link handler
    deepLinkHandle(link);
  };

  // registrar handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}
```

6) Background handler do FCM
- Declare o handler com `@pragma('vm:entry-point')` e inicialize o SDK dentro dele (importante para funcionamento quando o app está fechado).

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dito = DitoSDK();
  dito.initialize(
    apiKey: const String.fromEnvironment('API_KEY'),
    secretKey: const String.fromEnvironment('SECRET_KEY'),
  );
  await dito.initializePushNotificationService();

  // processar payload / registrar abertura ou mostrar notificação local
}
```

7) Identificação do usuário
- Defina as informações do usuário antes de chamar `identifyUser()`.

```dart
dito.identify(
  userID: 'id_do_usuario',
  name: 'Nome',
  email: 'email@exemplo.com',
  cpf: '00000000000',
);
await dito.identifyUser();
```

- Observação: algumas versões da SDK expõem `identify(String userId)` ou `setUserId()` — confirme a assinatura e garanta que `userId` exista antes de chamar `identifyUser()`.

8) Registro / remoção de token mobile
- Após inicializar o serviço de push e identificar o usuário, registre o token FCM:

```dart
final token = await dito.notificationService().getDeviceFirebaseToken();
await dito.registryMobileToken(token: token, platform: 'Android');
// Para iOS, usar o valor aceito pela SDK, ex: 'iPhone'
```

- Para remover o token:

```dart
await dito.removeMobileToken(token: token, platform: 'Android');
```

- Atenção: os valores válidos para `platform` podem variar entre versões (`'Android'`, `'iPhone'`, `'Apple iPhone'`). Use o valor exato exigido pela sua versão da SDK.

9) Envio de eventos

```dart
await dito.trackEvent(
  eventName: 'comprou produto',
  customData: {'produto': 'X', 'sku': '123'},
);
```

Se o usuário não estiver identificado, a SDK deve enfileirar o evento localmente e enviar após a identificação; valide esse comportamento em testes.

10) Registro de abertura de notificação

Se sua app precisa registrar aberturas manualmente, use `openNotification()` com os campos presentes no payload da Dito:

```dart
await dito.openNotification(
  notificationId: 'notif-id',
  identifier: 'identifier',
  reference: 'reference',
);
```

11) Testes / validação
- Execute testes manuais em dispositivos reais (Android e iOS).
- Teste inicialização no foreground, background e app fechado (background handler).
- Verifique envio de eventos enfileirados antes da identificação.
- Verifique registro e remoção de tokens.

12) Troubleshooting comum
- Erro: "userId não definido" → Certifique-se de chamar `identify()` / `setUserId()` antes de `identifyUser()` ou de métodos que exigem usuário identificado.
- Erro: platform inválido → Use o valor exato esperado pela versão da SDK.
- Push não chega → Verifique configuração do Firebase, `google-services.json` / `GoogleService-Info.plist`, e se `Firebase.initializeApp()` é chamado antes da SDK.

13) Checklist rápido
- [ ] `flutter pub get` executado
- [ ] Firebase configurado (Android e iOS)
- [ ] `API_KEY` e `SECRET_KEY` definidos com segurança
- [ ] `Firebase.initializeApp()` antes de `initializePushNotificationService()`
- [ ] Background handler registrado com `@pragma('vm:entry-point')`
- [ ] Testes manuais em Android e iOS realizados

14) Próximos passos (opcionais)
- Gerar exemplos de código no diretório `example/` adaptados à nova inicialização.
- Abrir PR com alterações de inicialização em arquivos `main.dart` do exemplo (posso gerar se desejar).

---
Arquivo criado automaticamente: `DEVELOPER_SETUP.md`.
