import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/onboarding/providers/onboarding_storage.dart';

const _onboardingCompletedKey = 'onboarding_completed';

/// Adaptateur FlutterSecureStorage → OnboardingStorage (production).
class _SecureStorageAdapter implements OnboardingStorage {
  _SecureStorageAdapter(this._delegate);
  final FlutterSecureStorage _delegate;

  @override
  Future<String?> read(String key) => _delegate.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _delegate.write(key: key, value: value);
}

/// Provider du stockage onboarding (production = secure storage).
/// En test, override avec un [OnboardingStorage] en mémoire.
final onboardingStorageProvider = Provider<OnboardingStorage>((ref) {
  return _SecureStorageAdapter(const FlutterSecureStorage());
});

/// État onboarding (Story 1.3) : complété ou non, persistant via secure storage.
/// Utilisé pour rediriger post-inscription vers onboarding puis home.
class OnboardingNotifier extends AsyncNotifier<bool> {
  OnboardingStorage? _storage;

  @override
  Future<bool> build() async {
    _storage ??= ref.read(onboardingStorageProvider);
    final value = await _storage!.read(_onboardingCompletedKey);
    return value == 'true';
  }

  /// Marque l'onboarding comme complété et persiste.
  Future<void> markCompleted() async {
    _storage ??= ref.read(onboardingStorageProvider);
    await _storage!.write(_onboardingCompletedKey, 'true');
    state = const AsyncValue.data(true);
  }
}

/// Provider : true si l'utilisateur a terminé l'onboarding, false sinon.
final onboardingCompletedProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
