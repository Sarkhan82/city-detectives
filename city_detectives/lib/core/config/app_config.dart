/// Configuration applicative (Story 1.2 – API_BASE_URL pour HTTPS).
/// En prod, utiliser des variables d'environnement / --dart-define.
class AppConfig {
  AppConfig._();

  /// URL de base de l'API (HTTPS en prod).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
