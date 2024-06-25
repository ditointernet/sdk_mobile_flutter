# Dito SDK (Flutter)

DitoSDK é uma biblioteca Dart que fornece métodos para integrar aplicativos com a plataforma da
Dito. Ela permite identificar usuários, registrar eventos e enviar dados personalizados.

## Instalação

Para instalar a biblioteca DitoSDK em seu aplicativo Flutter, você deve seguir as instruções
fornecidas [nesse link](https://pub.dev/packages/dito_sdk/install).

## Entidades

### UserEntity

```dart
class UserEntity {
  String? userID;
  String? name;
  String? cpf;
  String? email;
  String? gender;
  String? birthday;
  String? location;
  Map<String, dynamic>? customData;
}
```

### DataPayload

```dart
class Details {
  final String? link;
  final String message;
  final String? title;
}

class DataPayload {
  final String reference;
  final String identifier;
  final String? notification;
  final String? notification_log_id;
  final Details details;
}
```

## Métodos

### initialize() 

Este método deve ser chamado antes de qualquer outra operação com o SDK. Ele inicializa as chaves de
API e SECRET necessárias para a autenticação na plataforma Dito.

```dart
void initialize({required String apiKey, required String secretKey});
```

#### Parâmetros

- **apiKey** _(String, obrigatório)_: A chave de API da plataforma Dito.
- **secretKey** _(String, obrigatório)_: O segredo da chave de API da plataforma Dito.

### initializePushNotificationService() 

Este método deve ser chamado após a inicialização da SDK. Ele inicializa as configurações e serviços
necessários para o funcionamento de push notifications da plataforma Dito.

```dart
void initializePushNotificationService();
```

### identify()

Este método define as configurações do usuário que será usado para todas as operações subsequentes.

```dart
void identify(UserEntity user);
```

- **user** _(UserEntity, obrigatório)_: Parâmetro para identificar o usuário na plataforma da Dito.

### trackEvent()

O método `trackEvent()` tem a finalidade de registrar um evento na plataforma da Dito. Caso o usuário
já tenha sido registrado, o evento será enviado imediatamente. No entanto, caso o usuário ainda não
tenha sido registrado, o evento será armazenado localmente e posteriormente enviado quando o usuário
for registrado por meio do método `identify()`.

```dart
Future<void> trackEvent({
  required String eventName,
  double? revenue,
  Map<String, String>? customData,
});
```

#### Parâmetros

- **eventName** _(String, obrigatório)_: O nome do evento a ser registrado.
- **revenue** _(double, opcional)_: A receita associada ao evento.
- **customData** _(Map<String, String>, opcional)_: Dados personalizados adicionais associados ao
  evento.

### setOnMessageClick()

O método `setOnMessageClick()` configura uma callback para o evento de clique na notificação push.

```dart
Future<void> setOnMessageClick(
  Function(DataPayload) onMessageClicked
);
```

#### Parâmetros

- **onMessageClicked** _(Function(DataPayload), obrigatório)_: Função que será chamada ao clicar na mensagem


## Gerenciamento de tokens

A nossa SDK garante o registro do token atual do usuário além da deleção dos tokens inválidos. Mas também disponibilizamos os métodos a seguir caso necessite de adicionar/remover algum token.

### registryMobileToken()

Este método permite registrar um token mobile para o usuário.

```dart
Future<http.Response> registryToken({
  String? token,
});
```

#### Parâmetros

- **token** _(String)_: O token mobile que será registrado, caso não seja enviado pegamos o valor do Firebase.

#### Exception

- Caso a SDK ainda não tenha `identify` cadastrado quando esse método for chamado, irá ocorrer um
  erro no aplicativo. (utilize o método `identify()` para definir o usuário)

### removeMobileToken()

Este método permite remover um token mobile para o usuário.

```dart
Future<http.Response> removeMobileToken({
  String? token,
});
```

#### Parâmetros

- **token** _(String)_: O token mobile que será removido, caso não seja enviado pegamos o valor do Firebase.

#### Exception

- Caso a SDK ainda não tenha `identify` cadastrado quando esse método for chamado, irá ocorrer um
  erro no aplicativo. (utilize o método `identify()` para definir o usuário)

## Exemplos

### Uso da SDK somente com tracking de eventos:

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize( apiKey: 'sua_api_key', secretKey: 'sua_secret_key');

// Define ou atualiza informações do usuário na instância 
final user = UserEntity(userID: cpf, cpf: cpf, name: name, email: email);
await dito.identify(user);


// Registra um evento na Dito
await dito.trackEvent(eventName: 'login');
```

### Uso da SDK com push notification:

Para o funcionamento é necessário configurar a lib do Firebase Cloud Message (FCM), seguindo os
seguintes passos:

```shell
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_messaging
```

```shell
flutterfire configure
```

Siga os passos que irá aparecer na CLI, assim terá as chaves de acesso do Firebase configuradas
dentro dos App's Android e iOS.

#### main.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

// Método para registrar um serviço que irá receber as mensagens quando o app estiver totalmente fechado ou em segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DitoSDK dito = DitoSDK();
  dito.onBackgroundMessageHandler(message,
      apiKey: Constants.ditoApiKey, secretKey: Constants.ditoSecretKey);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');
  await dito.initializePushService();
}
```

> Lembre-se de substituir 'sua_api_key', 'sua_secret_key' pelos valores corretos
> em seu ambiente.
