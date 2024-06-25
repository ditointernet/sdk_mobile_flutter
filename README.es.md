[![es](https://img.shields.io/badge/lang-es-yellow.svg)](https://github.com/ditointernet/sdk_mobile_flutter/blob/main/README.es.md)

```markdown
# Dito SDK (Flutter)

DitoSDK es una biblioteca Dart que proporciona métodos para integrar aplicaciones con la plataforma de Dito. Permite identificar usuarios, registrar eventos y enviar datos personalizados.

## Instalación

Para instalar la biblioteca DitoSDK en tu aplicación Flutter, debes seguir las instrucciones proporcionadas [en este enlace](https://pub.dev/packages/dito_sdk/install).

## Métodos

### initialize()

Este método debe ser llamado antes de cualquier otra operación con el SDK. Inicializa las claves de API y SECRET necesarias para la autenticación en la plataforma Dito.

```dart
void initialize({required String apiKey, required String secretKey});
```

#### Parámetros

- **apiKey** _(String, obligatorio)_: La clave de API de la plataforma Dito.
- **secretKey** _(String, obligatorio)_: El secreto de la clave de API de la plataforma Dito.

### initializePushNotificationService()

Este método debe ser llamado después de la inicialización del SDK. Inicializa las configuraciones y servicios necesarios para el funcionamiento de notificaciones push de la plataforma Dito.

```dart
void initializePushNotificationService();
```

#### Parámetros

- **apiKey** _(String, obligatorio)_: La clave de API de la plataforma Dito.
- **secretKey** _(String, obligatorio)_: El secreto de la clave de API de la plataforma Dito.

### identify()

Este método define el ID del usuario que se utilizará para todas las operaciones subsiguientes.

```dart
void identify(String userId);
```

- **userID** _(String, obligatorio)_: ID para identificar al usuario en la plataforma Dito.
- **name** _(String)_: Parámetro para identificar al usuario en la plataforma Dito.
- **email** _(String)_: Parámetro para identificar al usuario en la plataforma Dito.
- **gender** _(String)_: Parámetro para identificar al usuario en la plataforma Dito.
- **birthday** _(String)_: Parámetro para identificar al usuario en la plataforma Dito.
- **location** _(String)_: Parámetro para identificar al usuario en la plataforma Dito.
- **customData** _(Map<String, dynamic>)_: Datos personalizados para identificar al usuario en la plataforma Dito.

### trackEvent()

Este método permite registrar eventos personalizados en la plataforma Dito.

```dart
void trackEvent({
  required String eventName,
  double? revenue,
  Map<String, dynamic>? customData,
});
```

- **eventName** _(String, obligatorio)_: El nombre del evento a ser registrado.
- **revenue** _(double, opcional)_: Ingreso generado por el evento.
- **customData** _(Map<String, dynamic>, opcional)_: Datos personalizados relacionados con el evento.

### Ejemplo de Uso

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

dito.initialize(
  apiKey: 'tu_api_key',
  secretKey: 'tu_secret_key',
);

dito.identify(
  userId: 'id_del_usuario',
  name: 'Nombre del Usuario',
  email: 'email@ejemplo.com',
  gender: 'género',
  birthday: 'fecha_de_nacimiento',
  location: 'ubicación',
  customData: {
    'llave_personalizada': 'valor_personalizado',
  },
);

dito.trackEvent(
  eventName: 'nombre_del_evento',
  revenue: 100.0,
  customData: {
    'llave_personalizada': 'valor_personalizado',
  },
);
```

Puedes llamar al método `identify()` en cualquier momento para agregar o actualizar los detalles del usuario, y solo cuando sea necesario, enviarlos a través del método `identifyUser()`.

#### archivoZ.dart

```dart
import 'package:dito_sdk/dito_sdk.dart';

final dito = DitoSDK();

// Registra un evento en Dito
dito.trackEvent(
  eventName: 'compró producto',
  revenue: 99.90,
  customData: {
    'producto': 'productoX',
    'sku_producto': '99999999',
    'método_pago': 'Visa',
  },
);
```

### Uso del SDK con notificaciones push:

Para el funcionamiento es necesario configurar la biblioteca de Firebase Cloud Message (FCM), siguiendo los siguientes pasos:

```shell
dart pub global activate flutterfire_cli
flutter pub add firebase_core firebase_messaging
```

```shell
flutterfire configure
```

Sigue los pasos que aparecerán en la CLI, así tendrás las claves de acceso de Firebase configuradas dentro de las aplicaciones Android e iOS.

#### main.dart
```dart
import 'package:dito_sdk/dito_sdk.dart';

// Método para registrar un servicio que recibirá los push cuando la aplicación esté completamente cerrada
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = DataPayload.fromJson(jsonDecode(message.data["data"]));

  dito.notificationService().showLocalNotification(CustomNotification(
      id: message.hashCode,
      title: notification.details.title || "El nombre de la aplicación",
      body: notification.details.message,
      payload: notification));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  DitoSDK dito = DitoSDK();
  dito.initialize(apiKey: 'tu_api_key', secretKey: 'tu_secret_key');
  await dito.initializePushService();
}
```

> Recuerda reemplazar 'tu_api_key', 'tu_secret_key' y 'id_del_usuario' por los valores correctos en tu entorno.
```