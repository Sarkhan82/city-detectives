import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _onboardingCompletedKey = 'onboarding_completed';

/// État onboarding (Story 1.3) : complété ou non, persistant via secure storage.
/// Utilisé pour rediriger post-inscription vers onboarding puis home.
class OnboardingNotifier extends AsyncNotifier<bool> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<bool> build() async {
    final value = await _storage.read(key: _onboardingCompletedKey);
    return value == 'true';
  }

  /// Marque l'onboarding comme complété et persiste.
  Future<void> markCompleted() async {
    await _storage.write(key: _onboardingCompletedKey, value: 'true');
    state = const AsyncValue.data(true);
  }
}

/// Provider : true si l'utilisateur a terminé l'onboarding, false sinon.
final onboardingCompletedProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
