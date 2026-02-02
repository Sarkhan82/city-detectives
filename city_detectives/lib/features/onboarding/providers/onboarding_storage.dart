/// Interface minimale pour le stockage de l'état onboarding (Story 1.3).
/// Permet d'injecter un fake en test sans dépendre directement de FlutterSecureStorage.
abstract class OnboardingStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}
