abstract class Constants {
  static const String ditoApiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  static const String ditoSecretKey = String.fromEnvironment(
    'SECRET_KEY',
    defaultValue: '',
  );
}
