# Dito SDK (Flutter)
DitoSDK é uma biblioteca Dart que fornece métodos para integrar aplicativos com a plataforma da Dito. Ela permite identificar usuários, registrar eventos e enviar dados personalizados.

## Instalação
Para instalar a biblioteca DitoSDK em seu aplicativo Flutter, você deve seguir as instruções fornecidas [nesse link](https://pub.dev/packages/dito_sdk/install).

## Métodos

### initialize()
Este método deve ser chamado antes de qualquer outra operação com o SDK. Ele inicializa as chaves de API e SECRET necessárias para a autenticação na plataforma Dito.

```
void initialize({required String apiKey, required String secretKey});
```

#### Parâmetros
- **apiKey** _(String, obrigatório)_: A chave de API da plataforma Dito.
- **secretKey** _(String, obrigatório)_: O segredo da chave de API da plataforma Dito.

### identify()
O método identify permite associar informações do usuário, como nome, email, gênero, data de nascimento, localização e dados personalizados à sessão do usuário.

```dart
void identify({
  String? name,
  String? email,
  String? gender,
  String? birthday,
  String? location,
  Map<String, String>? customData,
});
```

#### Parâmetros
- **name** _(String, opcional)_: Nome do usuário.
- **email** _(String, opcional)_: Endereço de email do usuário.
- **gender** _(String, opcional)_: Gênero do usuário.
- **birthday** _(String, opcional)_: Data de nascimento do usuário (no formato YYYY-MM-DD).
- **location** _(String, opcional)_: Localização do usuário.
- **customData** _(Map<String, String>, opcional)_: Dados personalizados adicionais.

### setUserId()
Este método define o ID do usuário que será usado para todas as operações subsequentes.

```dart
void setUserId(String userId);
```

#### Parâmetros
- **userId** _(String)_: O ID único do usuário.

### setUserAgent()
Este método permite definir o User-Agent que será enviado nas solicitações HTTP para a plataforma Dito.

```dart
void setUserAgent(String userAgent);
```

#### Parâmetros
- **userAgent** _(String)_: O User-Agent personalizado.

### identifyUser()
Este método registra o usuário na plataforma da Dito com as informações fornecidas anteriormente usando o método `identify()`.

```dart
Future<void> identifyUser() async;
```

### trackEvent()
O método `trackEvent()` tem a finalidade de registrar um evento na plataforma da Dito. Caso o userID já tenha sido registrado, o evento será enviado imediatamente. No entanto, caso o userID ainda não tenha sido registrado, o evento será armazenado localmente e posteriormente enviado quando o userID for registrado por meio do método `setUserId()`.

```dart
Future<void> trackEvent({
  required String eventName,
  double? revenue,
  Map<String, String>? customData,
}) async;
```

#### Parâmetros
 - **eventName** _(String, obrigatório)_: O nome do evento a ser registrado.
 - **revenue** _(double, opcional)_: A receita associada ao evento.
 - **customData** _(Map<String, String>, opcional)_: Dados personalizados adicionais associados ao evento.

### registryMobileToken()
Este método permite registrar um token mobile para o usuário.

```dart
Future<void> registryMobileToken(String token, String? platform);
```

#### Parâmetros
- **token** _(String)_: O token mobile que será registrado.
- **platform** _(String)_: Nome da plataforma que o usuário está acessando o aplicativo. Valores válidos: 'Apple iPhone' e 'Android'.

### openNotification()
Este método permite registrar a abertura de uma notificação mobile.

```dart
Future<void> registryMobileToken(String id, String identifier, String reference);
```

#### Parâmetros
- **id** _(String)_: Id da notificação da Dito recebida pelo aplicativo (Esse parâmetro estará presente no data da notificação).
- **identifier** _(String)_: Parâmetro para dentificar a notificação na plataforma da Dito (Esse parâmetro estará presente no data da notificação) .
- **reference** _(String)_: Parâmetro para identificar o usuário na plataforma da Dito (Esse parâmetro estará presente no data da notificação).

## Exemplos
### Uso básico da SDK:

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');

// Define o ID do usuário
dito.setUserId('id_do_usuario');

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify(
  name: 'João da Silva',
  email: 'joao@example.com',
  location: 'São Paulo',
);

// Envia as informações do usuário (que foram definidas ou atualizadas pelo identify) para a Dito
await dito.identifyUser();

// Registra um evento na Dito
await dito.trackEvent(eventName: 'login');
```

### Uso avançado da SDK:

#### main.dart
```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');

// Define um User-Agent personalizado (opcional)
dito.setUserAgent('Mozilla/5.0 (iPhone 14; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E999 DitoApp/1.0')
```

#### login.dart
```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define o ID do usuário
dito.setUserId('id_do_usuario');
```

#### arquivoX.dart
```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify(
  name: 'João da Silva',
  email: 'joao@example.com',
  location: 'São Paulo',
);
```

#### arquivoY.dart
```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Define ou atualiza informações do usuário na instância (neste momento, ainda não há comunicação com a Dito)
dito.identify(
  location: 'Rio de Janeiro',
  customData: {
    'loja preferida': 'LojaX',
    'canal preferido': 'Loja Física'
  }
);

// Envia as informações do usuário (que foram definidas ou atualizadas pelo identify) para a Dito
await dito.identifyUser();
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

A nossa SDK é uma instância única, o que significa que, mesmo que ela seja inicializada em vários arquivos ou mais de uma vez, ela sempre referenciará as mesmas informações previamente armazenadas. Isso nos proporciona a flexibilidade de chamar o método `identify()` a qualquer momento para adicionar ou atualizar os detalhes do usuário, e somente quando necessário, enviá-los através do método `identifyUser()`.

#### arquivoZ.dart
```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Registra um evento na Dito
dito.trackEvent(
  eventName: 'comprou produto',
  revenue: 99.90,
  customData: {
    'produto': 'produtoX',
    'sku_produto': '99999999',
    'metodo_pagamento': 'Visa',
  },
);
```

> Lembre-se de substituir 'sua_api_key', 'sua_secret_key' e 'id_do_usuario' pelos valores corretos em seu ambiente.