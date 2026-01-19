
# 📦 Dito SDK (Flutter)

`dito_sdk` é uma biblioteca Flutter que facilita a integração com a plataforma Dito, permitindo a identificação de usuários, o envio de eventos personalizados e a integração com notificações push.

[![pub package](https://img.shields.io/pub/v/dito_sdk.svg)](https://pub.dev/packages/dito_sdk)

## ✨ Recursos

- 📌 Identificação de usuários
- 📊 Envio e rastreamento de eventos personalizados
- 📱 Integração com notificações push (via Firebase Cloud Messaging)
- 💾 Armazenamento local de eventos para usuários não identificados
- 🔗 Suporte a deep linking via notificações

---

## 🚀 Começando

### ✅ Pré-requisitos

- **Dart SDK**: `>=2.12.0 <3.0.0` *(ajuste conforme a versão utilizada)*
- **Flutter SDK**: `>=1.20.0`
- **Conta na Dito**: Você precisará de uma conta ativa e credenciais da plataforma Dito (API Key e Secret).

### 📦 Instalação

Adicione o pacote no seu projeto Flutter:

```bash
flutter pub add dito_sdk
```

### ⚙️ Inicialização

Importe o pacote e inicialize o SDK com suas credenciais:

```dart
import 'package:dito_sdk/dito_sdk.dart';
void main() async { 
// Certifique-se de inicializar o binding do Flutter se estiver usando em um app Flutter
WidgetsFlutterBinding. ensureInitialized();
final String ditoApiKey = String.fromEnvironment('API_KEY');  
final String ditoSecretKey = String.fromEnvironment('SECRET_KEY'); 

DitoSDK dito = DitoSDK();  
dito.initialize(apiKey: ditoApiKey, secretKey: ditoSecretKey);  
await dito.initializePushNotificationService(); //está linha é necessário se for utilizar o serviço de push notification, aqui é feito o registro automático dos eventos de push;
```

## 🛠️ Uso da SDK

### 👤 Identificando um usuário

```dart
dito.identify(  
  userID: 'id_do_usuario',  
  cpf: 'cpf_do_usuario',  
  name: 'nome_do_usuario',  
  email: 'email_do_usuario',  
);  
await dito.identifyUser();
```
📌 Enquanto o usuário não for identificado, os eventos serão armazenados localmente.
___

### 📈 Enviando eventos
```dart
await dito.trackEvent( 
	eventName:  'comprou produto', 
	customData:  { 
		'produto':  'produtoX', 
		'sku_produto':  '99999999', 
	}, 
);
```
___


### 📲 Registrando o dispositivo
```dart
final token = await dito.notificationService().getDeviceFirebaseToken();
await dito.registryMobileToken(token: token);
```
*Importante: o usuário precisa estar identificado antes do registro do token.*
___

## 🔔 Integração com Push Notifications (FCM)

### 1. Instale os pacotes Firebase:

```dart
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_messaging
flutterfire configure
```
Siga as instruções para configurar o Firebase para Android e iOS.

### 2. Exemplo de uso com notificação:

```dart
import 'package:dito_sdk/dito_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<DitoSDK> _setupDito() async {
  final String apiKey = String.fromEnvironment('API_KEY');
  final String secretKey = String.fromEnvironment('SECRET_KEY');

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: apiKey, secretKey: secretKey);
  await dito.initializePushNotificationService();

  dito.notificationService().onClick = (String link) {
    deepLinkHandle(link); // sua lógica de navegação
  };

  return dito;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await _setupDito();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final dito = await _setupDito();
  // continuação do app...
}
```

___

## 📚 API da SDK

`initialize()`

Inicializa a SDK com suas credenciais.

```dart  
void initialize({required String apiKey, required String secretKey});  
```  
 
--- 

`initializePushNotificationService()`
Ativa os serviços de notificação da Dito.
```dart  
Future<void> initializePushNotificationService();  
```
  
---

`identify()`  
Configura os dados de identificação do usuário.
```dart  
void identify({
  required String userID,
  String? name,
  String? email,
  String? gender,
  String? birthday,
  String? location,
  String? cpf,
  Map<String, dynamic>? customData,
});
```

---

`identifyUser() `
Registra o usuário na plataforma com base nas informações previamente definidas.
```dart  
Future<http.Response> identifyUser();  
```  
*:warning: Gera erro se `userID` não estiver definido.*

---

`trackEvent()`

Registra um evento para o usuário.

```dart  
Future<void> trackEvent({
  required String eventName,
  double? revenue,
  Map<String, String>? customData,
});
```  

---

`registryMobileToken() `
Registra um token de push notification para o usuário.
```dart  
Future<http.Response> registryMobileToken({
  required String token,
  String? platform, // 'Android' ou 'Apple iPhone'
});
```  
*:warning: Gera erro se o usuário não estiver identificado ou se a plataforma for inválida.*

---

`removeMobileToken()`
Remove o token de notificação de um usuário.
```dart  
Future<http.Response> removeMobileToken({
  required String token,
  String? platform,
});
```  
*:warning: Mesmas regras de exceção do `registryMobileToken()`.*

___

`openNotification() `
Registra a abertura de uma notificação.
```dart  
Future<http.Response> openNotification({
  required String notificationId,
  required String identifier,
  required String reference,
});
```  
:bulb: *Obs: Esses parâmetros estarão presentes no data da notificação*
 
---

## 🧪 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests. Antes de contribuir, por favor leia o arquivo `CONTRIBUTING.md` se disponível.


<center>Desenvolvido com 💙 pela equipe Dito.</center>
