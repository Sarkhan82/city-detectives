import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/repositories/user_repository.dart';
import 'package:city_detectives/core/services/auth_service.dart';

/// Provider du service d'authentification (Story 1.2).
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Token stocké (pour clients authentifiés et currentUser).
final _authTokenProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return auth.getStoredToken();
});

/// Utilisateur courant (Story 7.1 – FR61). Null si non connecté ou erreur ; isAdmin pour afficher l'accès dashboard.
final currentUserProvider = FutureProvider<CurrentUser?>((ref) async {
  final token = await ref.watch(_authTokenProvider.future);
  if (token == null || token.isEmpty) return null;
  try {
    final repo = UserRepository(createGraphQLClient(authToken: token));
    return await repo.getMe();
  } catch (_) {
    return null;
  }
});
