## Dito SDK (Flutter)
==================

DitoSDK é uma biblioteca Dart que fornece métodos para integrar aplicativos com a plataforma da
Dito. Ela permite identificar usuários, registrar eventos e enviar dados personalizados.

## Instalação
----------

Para instalar a biblioteca DitoSDK em seu aplicativo Flutter, siga as instruções
fornecidas [neste link](https://pub.dev/packages/dito_sdk/install).

## Métodos
-------

### initialize()

Este método deve ser chamado antes de qualquer outra operação com o SDK. Ele inicializa as chaves de
API e SECRET necessárias para a autenticação na plataforma Dito.

```dart
void initialize({required String apiKey, required String secretKey});
```
#### Parâmetros

- **apiKey** *(String, obrigatório)*: A chave de API da plataforma Dito.
- **secretKey** *(String, obrigatório)*: O segredo da chave de API da plataforma Dito.

### initializePushNotificationService()

Este método deve ser chamado após a inicialização do SDK. Ele inicializa as configurações e serviços
necessários para o funcionamento de push notifications da plataforma Dito.

```dart
void initializePushNotificationService();
```

### identify()

Este método registra o usuário na plataforma da Dito com as informações fornecidas anteriormente
usando o método `identify()`.

dart
Future<bool> identify(UserEntity user) async;`

### trackEvent()

O método `trackEvent()` registra um evento na plataforma da Dito. Caso o `userId` já tenha sido
registrado, o evento será enviado imediatamente. Caso contrário, o evento será armazenado localmente
e enviado posteriormente quando o `userId` for registrado.

```dart 
Future<void> trackEvent
(
{
required
String
eventName, double? revenue, Map<String, String>
?
customData
}
)
async;
```

#### Parâmetros

- **eventName** *(String, obrigatório)*: O nome do evento a ser registrado.
- **revenue** *(double, opcional)*: A receita associada ao evento.
- **customData** *(Map<String, String>, opcional)*: Dados personalizados adicionais associados ao
  evento.

### registryMobileToken()

Este método permite registrar um token mobile para o usuário.

```dart
Future<http.Response> registryMobileToken
(
{
required
String
token
,
String
?
platform
}
)
async;
```

#### Parâmetros

- **token** *(String, obrigatório)*: O token mobile que será registrado.
- **platform** *(String, opcional)*: Nome da plataforma que o usuário está acessando o aplicativo.
  Valores válidos: 'iPhone' e 'Android'. *Caso não seja passado algum valor nessa prop, a sdk irá
  pegar por default o valor pela `platform`.*

#### Exceções

- Caso seja passado um valor diferente de 'iPhone' ou 'Android' na propriedade `platform`, ocorrerá
  um erro no aplicativo.
- Caso a SDK ainda não tenha `userId` cadastrado quando esse método for chamado, ocorrerá um erro no
  aplicativo. (utilize o método `identify()` para definir o `userId`)

### removeMobileToken()

Este método permite remover um token mobile para o usuário.

```dart
Future<http.Response> removeMobileToken
(
{
required
String
token
,
String
?
platform
}
)
async;
```

#### Parâmetros

- **token** *(String, obrigatório)*: O token mobile que será removido.
- **platform** *(String, opcional)*: Nome da plataforma que o usuário está acessando o aplicativo.
  Valores válidos: 'iPhone' e 'Android'. *Caso não seja passado algum valor nessa prop, a sdk irá
  pegar por default o valor pela `platform`.*

#### Exceções

- Caso seja passado um valor diferente de 'iPhone' ou 'Android' na propriedade `platform`, ocorrerá
  um erro no aplicativo.
- Caso a SDK ainda não tenha `userId` cadastrado quando esse método for chamado, ocorrerá um erro no
  aplicativo. (utilize o método `identify()` para definir o `userId`)

### openNotification()

Este método permite registrar a abertura de uma notificação mobile.

```dart
Future<http.Response> openNotification
(
{
required
String
notificationId, required String identifier, required String reference}) async;
```

#### Parâmetros

- **notificationId** *(String, obrigatório)*: Id da notificação da Dito recebida pelo aplicativo.
- **identifier** *(String, obrigatório)*: Parâmetro para identificar a notificação na plataforma da
  Dito.
- **reference** *(String, obrigatório)*: Parâmetro para identificar o usuário na plataforma da Dito.

Classes
-------

### UserEntity

Classe para manipulação dos dados do usuário.

dart
User user = User('sha1_hash', 'João da Silva', 'joao@example.com', 'São Paulo');`

#### Parâmetros

- **userId** *(String, obrigatório)*: Id para identificar o usuário na plataforma da Dito.
- **name** *(String, opcional)*: Nome do usuário.
- **email** *(String, opcional)*: Email do usuário.
- **gender** *(String, opcional)*: Gênero do usuário.
- **birthday** *(String, opcional)*: Data de nascimento do usuário.
- **location** *(String, opcional)*: Localização do usuário.
- **customData** *(Map<String, dynamic>, opcional)*: Dados personalizados adicionais do usuário.

Exemplos
--------

### Uso básico da SDK

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize
(
apiKey: 'sua_api_key', secretKey: 'sua_secret_key');

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify('sha1_hash', name: 'João da Silva', email: 'joao@example.com', location: 'São Paulo');

// Envia as informações do usuário (que foram definidas ou atualizadas pelo identify) para a Dito
await dito.identifyUser();

// Registra um evento na Dito
await dito.trackEvent(
eventName
:
'
login
'
);
```

### Uso avançado da SDK

#### main.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize
(
apiKey: 'sua_api_key', secretKey: 'sua_secret_key');
```

#### login.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define o ID do usuário
dito.identify
('sha1_hash
'
, name: 'João da Silva', email: 'joao@example.com', location: 'São Paulo');
await dito.identifyUser();
```

#### arquivoX.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify
('sha1_hash
'
, name: 'João da Silva', email: 'joao@example.com', location: 'São Paulo');
await dito.identifyUser();
await dito.registryMobileToken(token
:
'
token_value
'
);
```

#### arquivoY.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
await
dito.identify
('sha1_hash
'
,name: 'João da Silva',
email: 'joao@example.com',
location: 'Rio de Janeiro',
customData: {
'loja preferida': 'LojaX',
'canal preferido': 'Loja Física'
}
);
```

A nossa SDK é uma instância única, o que significa que, mesmo que ela seja inicializada em vários
arquivos ou mais de uma vez, ela sempre referenciará as mesmas informações previamente armazenadas.
Isso nos proporciona a flexibilidade de chamar o método `identify()` a qualquer momento para
adicionar ou atualizar os detalhes do usuário, e somente quando necessário, enviá-los através do
método `identifyUser()`.

#### arquivoZ.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Registra um evento na Dito
await
dito.trackEvent
(
eventName: 'comprou produto',
revenue: 99.90,
customData: {
'produto': 'produtoX',
'sku_produto': '99999999',
'metodo_pagamento': 'Visa',
}
);
```

### Uso da SDK com push notification

Para o funcionamento é necessário configurar a biblioteca do Firebase Cloud Messaging (FCM),
seguindo os seguintes passos:

```shell
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_messaging
flutterfire configure
```

Siga os passos que irão aparecer na CLI para configurar as chaves de acesso do Firebase dentro dos
aplicativos Android e iOS.

#### main.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';

// Método para registrar um serviço que irá receber os push quando o app estiver totalmente fechado
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  dito.notificationService().showLocalNotification(NotificationEntity(
      id: message.hashCode,
      title: notification.details.title ?? "O nome do aplicativo",
      body: notification.details.message ?? "",
      payload: notification));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final dito = DitoSDK();
  dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');
  await dito.initializePushNotificationService();
}
```

> Lembre-se de substituir 'sua_api_key', 'sua_secret_key' e 'id_do_usuario' pelos valores corretos
> em seu ambiente.
