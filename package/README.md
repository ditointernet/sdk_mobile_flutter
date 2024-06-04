# Dito SDK (Flutter)

DitoSDK é uma biblioteca Dart que fornece métodos para integrar aplicativos com a plataforma da
Dito. Ela permite identificar usuários, registrar eventos e enviar dados personalizados.

## Instalação

Para instalar a biblioteca DitoSDK em seu aplicativo Flutter, você deve seguir as instruções
fornecidas [nesse link](https://pub.dev/packages/dito_sdk/install).

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

#### Parâmetros

- **apiKey** _(String, obrigatório)_: A chave de API da plataforma Dito.
- **secretKey** _(String, obrigatório)_: O segredo da chave de API da plataforma Dito.

### identify()

Este método define o ID do usuário que será usado para todas as operações subsequentes.

```dart
void identify(String userId);
```

- **userID** _(String, obrigatório)_: Id para identificar o usuário na plataforma da Dito.
- **name** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **email** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **gender** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **birthday** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **location** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **customData** _(Map<String, dynamic>)_: Parâmetro para identificar o usuário na plataforma da
  Dito.

#### identifyUser()

Este método registra o usuário na plataforma da Dito com as informações fornecidas anteriormente
usando o método `identify()`.

```dart
Future<http.Response> identifyUser

() async;
```

#### Exception

- Caso a SDK ainda não tenha `userId` cadastrado quando esse método for chamado, irá ocorrer um erro
  no aplicativo. (utilize o método `setUserId()` para definir o `userId`)

### trackEvent()

O método `trackEvent()` tem a finalidade de registrar um evento na plataforma da Dito. Caso o userID
já tenha sido registrado, o evento será enviado imediatamente. No entanto, caso o userID ainda não
tenha sido registrado, o evento será armazenado localmente e posteriormente enviado quando o userID
for registrado por meio do método `setUserId()`.

```dart
Future<void> trackEvent
(
{
required
String
eventName,
double? revenue,
Map<String, String>
?
customData
,
}
)
async;
```

#### Parâmetros

- **eventName** _(String, obrigatório)_: O nome do evento a ser registrado.
- **revenue** _(double, opcional)_: A receita associada ao evento.
- **customData** _(Map<String, String>, opcional)_: Dados personalizados adicionais associados ao
  evento.

### registryMobileToken()

Este método permite registrar um token mobile para o usuário.

```dart
Future<http.Response> registryMobileToken({
  required String token,
  String? platform,
});
```

#### Parâmetros

- **token** _(String, obrigatório)_: O token mobile que será registrado.
- **platform** _(String, opcional)_: Nome da plataforma que o usuário está acessando o aplicativo.
  Valores válidos: 'iPhone' e 'Android'.
  `<br>`_Caso não seja passado algum valor nessa prop, a sdk irá pegar por default o valor
  pelo `platform`._

#### Exception

- Caso seja passado um valor diferente de 'iPhone' ou 'Android' na propriedade platform, irá ocorrer
  um erro no aplicativo.
- Caso a SDK ainda não tenha `identify` cadastrado quando esse método for chamado, irá ocorrer um
  erro no aplicativo. (utilize o método `identify()` para definir o id do usuário)

### removeMobileToken()

Este método permite remover um token mobile para o usuário.

```dart
Future<http.Response> removeMobileToken({
  required String token,
  String? platform,
});
```

#### Parâmetros

- **token** _(String, obrigatório)_: O token mobile que será removido.
- **platform** _(String, opcional)_: Nome da plataforma que o usuário está acessando o aplicativo.
  Valores válidos: 'iPhone' e 'Android'.
  `<br>`_Caso não seja passado algum valor nessa prop, a sdk irá pegar por default o valor
  pelo `platform`._

#### Exception

- Caso seja passado um valor diferente de 'iPhone' ou 'Android' na propriedade platform, irá ocorrer
  um erro no aplicativo.
- Caso a SDK ainda não tenha `identify` cadastrado quando esse método for chamado, irá ocorrer um
  erro no aplicativo. (utilize o método `identify()` para definir o id do usuário)

### openNotification()

Este método permite registrar a abertura de uma notificação mobile.

```dart
Future<http.Response> openNotification
(
{
required
String
notificationId,
required String identifier,
required String reference
}) async
```

#### Parâmetros

- **notificationId** _(String, obrigatório)_: Id da notificação da Dito recebida pelo aplicativo.
- **identifier** _(String, obrigatório)_: Parâmetro para dentificar a notificação na plataforma da
  Dito.
- **reference** _(String, obrigatório)_: Parâmetro para identificar o usuário na plataforma da Dito.

###### Observações

- Esses parâmetros estarão presentes no data da notificação

## Classes

### User

Classe para manipulação dos dados do usuário.

```dart

User user = User(sha1("joao@example.com"), 'João da Silva', 'joao@example.com', 'São Paulo');
```

#### Parâmetros

- **userID** _(String, obrigatório)_: Id para identificar o usuário na plataforma da Dito.
- **name** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **email** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **gender** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **birthday** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **location** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito.
- **customData** _(Map<String, dynamic>)_: Parâmetro para identificar o usuário na plataforma da
  Dito.

## Exemplos

### Uso básico da SDK:

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize
(
apiKey: 'sua_api_key', secretKey: 'sua_secret_key');

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify( sha1("joao@example.com"), 'João da Silva', 'joao@example.com', 'São Paulo');

// Envia as informações do usuário (que foram definidas ou atualizadas pelo identify) para a Dito
await dito.identifyUser();

// Registra um evento na Dito
await dito.trackEvent(eventName: '
login
'
);
```

### Uso avançado da SDK:

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
dito.setUserId
('id_do_usuario
'
);dito.identify( sha1("joao@example.com"), 'João da Silva', 'joao@example.com', 'São Paulo');
await dito.identifyUser();
```

#### arquivoX.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify
(
sha1("joao@example.com"), 'João da Silva', 'joao@example.com', 'São Paulo');
await dito.identifyUser();
await dito.registryMobileToken(
token
:
token
);

```

#### arquivoY.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify
(
sha1("joao@example.com"), 'João da Silva', 'joao@example.com', 'Rio de Janeiro', {
'loja preferida': 'LojaX',
'canal preferido': 'Loja Física'
});
await
dito
.
identifyUser
(
);
```

Isso resultará no envio do seguinte payload do usuário ao chamar `identifyUser()`:

```javascript
{
  name: 'João da Silva',
  email: 'joao@example.com',
  location: 'Rio de Janeiro',
  customData: {
    'loja preferida': 'LojaX',
    'canal preferido': 'Loja Física'
  }
}
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
dito.trackEvent
(
eventName: 'comprou produto',
revenue: 99.90,
customData: {
'produto': 'produtoX',
'sku_produto': '99999999',
'metodo_pagamento': 'Visa',
},
);
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

// Método para registrar um serviço que irá receber os push quando o app estiver totalmente fechado
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  dito.notificationService().showLocalNotification(CustomNotification(
      id: message.hashCode,
      title: notification.details.title || "O nome do aplicativo",
      body: notification.details.message,
      payload: notification));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');
  await dito.initializePushService();
}
```

> Lembre-se de substituir 'sua_api_key', 'sua_secret_key' e 'id_do_usuario' pelos valores corretos
> em seu ambiente.
