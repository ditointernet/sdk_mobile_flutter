[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.md)
[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.pt-br.md)
[![es](https://img.shields.io/badge/lang-es-yellow.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.es.md)

```markdown
# Dito SDK (Flutter)

DitoSDK is a Dart library that provides methods to integrate applications with the Dito platform. It allows user identification, event registration, and sending custom data.

## Installation

To install the DitoSDK library in your Flutter application, you should follow the instructions provided [at this link](https://pub.dev/packages/dito_sdk/install).

## Methods

### initialize()

This method must be called before any other operation with the SDK. It initializes the API and SECRET keys necessary for authentication on the Dito platform.

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

#### Parameters

- **apiKey** _(String, required)_: The API key for the Dito platform.
- **secretKey** _(String, required)_: The secret key for the Dito platform.

### identify()

This method sets the user ID that will be used for all subsequent operations.

```dart
void identify(String userId);
```

- **userID** _(String, required)_: ID to identify the user on the Dito platform.
- **name** _(String)_: Parameter to identify the user on the Dito platform.
- **email** _(String)_: Parameter to identify the user on the Dito platform.
- **gender** _(String)_: Parameter to identify the user on the Dito platform.
- **birthday** _(String)_: Parameter to identify the user on the Dito platform.
- **location** _(String)_: Parameter to identify the user on the Dito platform.
- **customData** _(Map<String, dynamic>)_: Parameter to identify the user on the Dito platform.

### trackEvent()

This method records an event on the Dito platform.

```dart
void trackEvent({required String eventName, double? revenue, Map<String, dynamic>? customData});
```

- **eventName** _(String, required)_: Name of the event to be tracked.
- **revenue** _(double)_: Revenue generated from the event.
- **customData** _(Map<String, dynamic)_: Custom data related to the event.

## Example Usage

Below is an example of how to use the DitoSDK:

### main.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

void main() {
  DitoSDK dito = DitoSDK();

  dito.initialize(apiKey: 'your_api_key', secretKey: 'your_secret_key');
  dito.initializePushNotificationService();

  dito.identify('user_id', name: 'John Doe', email: 'john.doe@example.com');
  dito.trackEvent(
    eventName: 'purchased product',
    revenue: 99.90,
    customData: {
      'product': 'productX',
      'sku_product': '99999999',
      'payment_method': 'Visa',
    },
  );
}
```

You can call the `identify()` method at any time to add or update user details, and only when necessary, send them through the `identifyUser()` method.

### arquivoZ.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Record an event on Dito
dito.trackEvent(
  eventName: 'purchased product',
  revenue: 99.90,
  customData: {
    'product': 'productX',
    'sku_product': '99999999',
    'payment_method': 'Visa',
  },
);
```

### Using SDK with Push Notification:

To make it work, it is necessary to configure the Firebase Cloud Messaging (FCM) library by following these steps:

```shell
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_messaging
```

```shell
flutterfire configure
```

Follow the steps that will appear on the CLI, so you will have the Firebase access keys configured within the Android and iOS apps.

#### main.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

// Method to register a service that will receive push notifications when the app is completely closed
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  dito.notificationService().showLocalNotification(NotificationEntity(
      id: message.hashCode,
      title: notification.details.title || "App Name",
      body: notification.details.message,
      payload: notification));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: 'your_api_key', secretKey: 'your_secret_key');
  await dito.initializePushService();
}
```

> Remember to replace 'your_api_key', 'your_secret_key', and 'user_id' with the correct values in your environment.
```