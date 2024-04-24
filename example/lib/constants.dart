abstract class Constants {
  static const String ditoApiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  static const String ditoSecretKey = String.fromEnvironment(
    'SECRET_KEY',
    defaultValue: '',
  );

  static const String firebaseAndroidApKey = String.fromEnvironment(
    'ANDROID_FIREBASE_APP_KEY',
    defaultValue: '',
  );

  static const String firebaseAndroidAppID = String.fromEnvironment(
    'FIREBASE_MESSAGE_SENDER_ID',
    defaultValue: '',
  );

  static const String firebaseMessageID = String.fromEnvironment(
    'ANDROID_FIREBASE_APP_ID',
    defaultValue: '',
  );

  static const String firebaseProjectID = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String firebaseIosAppKey = String.fromEnvironment(
    'IOS_FIREBASE_APP_KEY',
    defaultValue: '',
  );

  static const String firebaseIosAppID = String.fromEnvironment(
    'IOS_FIREBASE_APP_ID',
    defaultValue: '',
  );
}