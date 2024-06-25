[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.md)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.pt-br.md)
[![es](https://img.shields.io/badge/lang-es-yellow.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.es.md)

# Dito SDK (Flutter)

DitoSDK is a Dart library that provides methods to integrate applications with the Dito platform. It allows to identify users, record events, and send personalized data.

## Installation

To install the DitoSDK library in your Flutter application, you must follow the instructions provided at [this link](https://pub.dev/packages/dito_sdk/install).

## Entities

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

## Methods

### initialize() 

This method must be called before any other operation with the SDK. It initializes the API and SECRET keys required for authentication on the Dito platform.

```dart
void initialize({required String apiKey, required String secretKey});
```

#### Parameters

- **apiKey** _(String, required)_: The API key for the Dito platform.
- **secretKey** _(String, required)_: The secret key for the Dito platform.

### initializePushNotificationService() 

This method should be called after the SDK initialization. It initializes the settings and services necessary for the functioning of push notifications on the Dito platform.

```dart
void initializePushNotificationService();
```

### identify()

This method defines user settings that will be used for all subsequent operations.

```dart
void identify(UserEntity user);
```

#### Parameters

- **user** _(UserEntity, obrigatório)_: Parameter to identify the user on Dito’s platform.

### trackEvent()

This method records an event on the Dito platform. If the user has already been registered, the event will be sent immediately. However, if the user has not yet been registered, the event will be stored locally and sent later.

```dart
Future<void> trackEvent({
  required String eventName,
  double? revenue,
  Map<String, String>? customData,
});
```

#### Parameters

- **eventName** _(String, required)_: Name of the event to be tracked.
- **revenue** _(double)_: Revenue generated from the event.
- **customData** _(Map<String, dynamic)_: Custom data related to the event.

### setOnMessageClick()

The `setOnMessageClick()` method sets a callback for the push notification click event.

```dart
Future<void> setOnMessageClick(
  Function(DataPayload) onMessageClicked
);
```

#### Parameters

- **onMessageClicked** _(Function(DataPayload), required)_: Function that will be called when clicking on the message


## Token management

Our SDK ensures the registration of the current user's token in addition to the deletion of invalid tokens. However, we also provide the following methods in case you need to add/remove any token.

### registryMobileToken()

This method allows you to register a mobile token for the user.

```dart
Future<http.Response> registryToken({
  String? token,
});
```

#### Parâmetros

- **token** _(String)_: The mobile token that will be registered, if it is not sent we will get the value from Firebase.

#### Exception

- If the SDK does not already have `user` registered when this method is called, an error will occur in the application. (Use the `identify()` method to define the user)
### removeMobileToken()

This method allows you to remove a mobile token for the user.

```dart
Future<http.Response> removeMobileToken({
  String? token,
});
```

#### Parameters

- **token** _(String)_: The mobile token that will be removed, if it is not sent we will get the value from Firebase.

#### Exception

- If the SDK does not already have `user` registered when this method is called, an error will occur in the application. (Use the `identify()` method to define the user)

## Examples

### Using the SDK only for event tracking:

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Inicializa a SDK com suas chaves de API
dito.initialize( apiKey: 'your_api_key', secretKey: 'your_secret_key');

// Define ou atualiza informações do usuário na instância 
final user = UserEntity(userID: cpf, cpf: cpf, name: name, email: email);
await dito.identify(user);


// Registra um evento na Dito
await dito.trackEvent(eventName: 'login');
```

### Using the SDK for push notification:

For it to work, you need to configure the Firebase Cloud Message (FCM) lib, following the
following steps:

```shell
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_messaging
```

```shell
flutterfire configure
```

Follow the steps that will appear in the CLI, so you will have the Firebase access keys configured
within the Android and iOS Apps.

#### main.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

// Method to register a service that will receive messages when the app is completely closed or in the background
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
  dito.initialize(apiKey: 'your_api_key', secretKey: 'your_secret_key');
  await dito.initializePushService();
}
```

> Remember to replace 'your_api_key', 'your_secret_key' with the correct values
> in your environment.
