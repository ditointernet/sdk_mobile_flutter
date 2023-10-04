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

### registerUser()
Este método registra o usuário na plataforma da Dito com as informações fornecidas anteriormente usando o método identify.

```dart
Future<void> registerUser() async;
```

### trackEvent()
Este método registra um evento na plataforma Dito, associado ao usuário atual.

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

## Exemplo
Aqui está um exemplo de uso básico da SDK:

```dart
final dito = DitoSDK();

dito.initialize(apiKey: 'sua_api_key', secretKey: 'sua_secret_key');

dito.setUserId('id_do_usuario');

dito.identify(
  name: 'João da Silva',
  email: 'joao@example.com',
  location: 'São Paulo',
);

await dito.registerUser();

await dito.trackEvent(eventName: 'login');
```

> Certifique-se de substituir 'sua_api_key', 'sua_secret_key' e 'id_do_usuario' pelos valores apropriados em seu ambiente.
