# MIGRAÇÃO PARA A NOVA ESTRUTURA (feat/new-push-approach)

Este documento descreve os passos necessários para migrar projetos que usam a SDK Dito Flutter para a nova estrutura/abordagem de push implementada na branch `feat/new-push-approach`.

Resumo das mudanças principais
- Consolidação/ajuste da inicialização do serviço de push (métodos relacionados a push reorganizados).
- Pequenas mudanças de nome e comportamento em métodos de identificação (`identify` / `setUserId`) e registro de token.
- Atualizações de exemplo de uso para compatibilidade com handlers de background do FCM.

Antes de começar
- Tenha o código do app em controle de versão e crie uma branch de migração.
- Atualize as dependências: execute `flutter pub get` após aplicar mudanças.
- Configure o Firebase (Android/iOS) se ainda não estiver configurado.

1) Dependências e configurações
- Instale/atualize `firebase_core` e `firebase_messaging`:

```bash
flutter pub add firebase_core firebase_messaging
flutter pub get
```

- Configure Firebase usando o `flutterfire` CLI (se ainda não configurado):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

- Inclua os arquivos de configuração das plataformas: `GoogleService-Info.plist` (iOS) e `google-services.json` (Android).

2) Inicialização da SDK

Antes (exemplo comum):

```dart
final dito = DitoSDK();
dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');
await dito.initializePushNotificationService();
```

Após a migração: verifique que a inicialização do SDK e do serviço de push estão presentes e que o Firebase foi inicializado antes de chamar o método de push. Exemplo recomendado:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();

final dito = DitoSDK();
dito.initialize(apiKey: 'SUA_API_KEY', secretKey: 'SEU_SECRET');
await dito.initializePushNotificationService();

// opcional: configurar callback de clique em notificações
dito.notificationService().onClick = (String link) {
  // deep link handler
  deepLinkHandle(link);
};
```

Observação: em alguns exemplos da `main` foi usado `initializePushService` ou `initializePushNotificationService` — confirme no código da versão que você está usando qual é o nome do método e adapte o trecho acima.

3) Background handler (FCM)

Certifique-se de registrar um handler de background com `@pragma('vm:entry-point')` e inicializar o SDK dentro dele. Exemplo:

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dito = DitoSDK();
  dito.initialize(apiKey: 'SUA_API_KEY', secretKey: 'SEU_SECRET');
  await dito.initializePushNotificationService();

  // manipule a mensagem (ex: mostrar notificação local ou processar payload)
}

// no main():
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

4) Identificação do usuário

Antigo (exemplo do README antigo):

```dart
dito.identify(
  userID: 'id_do_usuario',
  cpf: 'cpf_do_usuario',
  name: 'nome',
  email: 'email',
);
await dito.identifyUser();
```

Notas de migração:
- A `main` apresenta outras variantes (`identify(String userId)` e `setUserId()`); verifique qual assinatura sua versão da SDK expõe.
- Recomendação: garantir que o `userId` esteja definido antes de chamar `identifyUser()`/`setUserId()` — caso contrário a SDK lançará erro.

5) Registro e remoção de token mobile

Uso comum:

```dart
final token = await dito.notificationService().getDeviceFirebaseToken();
await dito.registryMobileToken(token: token, platform: 'Android');
// ou para iOS: platform: 'iPhone' (algumas versões usam 'Apple iPhone')
```

Observações:
- A `main` indica que valores aceitos podem ser `'iPhone'` e `'Android'`. Em outras documentações locais pode aparecer `'Apple iPhone'`. Para evitar erros, use exatamente o valor esperado pela versão da SDK que você está consumindo (ou utilize constantes se a SDK expô-las).

6) Eventos (trackEvent)

Uso permanece similar:

```dart
await dito.trackEvent(
  eventName: 'comprou produto',
  customData: {'produto': 'X', 'sku': '123'},
);
```

Se sua app dependia do comportamento de enfileiramento local (eventos enviados apenas após identificação), verifique que esse comportamento continua igual após a migração.

7) Testes e validação
- Teste a inicialização em `main()` e no handler de background.
- Envie eventos enquanto o usuário não está identificado e confirme envio após `identifyUser()`.
- Teste registro e remoção de tokens, e o fluxo de clique em notificações (`onClick`).

8) Checklist rápido
- [ ] Atualizar dependências e rodar `flutter pub get`.
- [ ] Confirmar nome do método de inicialização de push na versão da SDK.
- [ ] Garantir `Firebase.initializeApp()` antes de inicializar push.
- [ ] Registrar handler de background com `@pragma('vm:entry-point')`.
- [ ] Validar valores `platform` ao registrar token.
- [ ] Testar envio/recebimento de notificações em Android e iOS.

Rollback
- Caso identifique problemas, reverta a branch e abra uma branch de hotfix para corrigir pontos específicos (ex.: nome do método, valores de `platform`, inicialização do Firebase).

Se quiser, eu posso:
- Gerar um pull request com este arquivo `MIGRATION.md`.
- Aplicar correções automáticas no código de inicialização (se você indicar os arquivos a modificar).
