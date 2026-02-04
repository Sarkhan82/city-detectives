// Story 8.1 – providers pour PushService et enregistrement du token après login.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/core/services/push_service.dart';

/// Service push (Story 8.1). Injecte getAuthToken pour le refresh FCM.
final pushServiceProvider = Provider<PushService>((ref) {
  final auth = ref.watch(authServiceProvider);
  return PushService(getAuthToken: () => auth.getStoredToken());
});

/// Enregistre le token push auprès du backend quand l'utilisateur est connecté.
/// Dépend de [currentUserProvider] : quand l'utilisateur est non null, on appelle ensureInitialized, requestPermission, registerWithBackend.
final pushRegistrationProvider = FutureProvider<bool?>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) return null;
  final auth = ref.read(authServiceProvider);
  final token = await auth.getStoredToken();
  if (token == null || token.isEmpty) return null;
  final push = ref.read(pushServiceProvider);
  await push.ensureInitialized();
  await push.requestPermission();
  return push.registerWithBackend(token);
});
