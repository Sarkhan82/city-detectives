import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/repositories/user_repository.dart';

const _defaultTokenKey = 'auth_jwt_token';

/// Service d'authentification (Story 1.2).
/// Inscription via GraphQL, stockage du JWT dans flutter_secure_storage.
class AuthService {
  AuthService({FlutterSecureStorage? secureStorage, String? tokenKey})
    : _storage = secureStorage ?? const FlutterSecureStorage(),
      _tokenKey = tokenKey ?? _defaultTokenKey;

  final FlutterSecureStorage _storage;
  final String _tokenKey;

  String? _cachedToken;

  UserRepository get _userRepo => UserRepository(createGraphQLClient());

  /// Inscription : appelle l'API register, stocke le JWT en secure storage.
  Future<String> register({
    required String email,
    required String password,
  }) async {
    final token = await _userRepo.register(email: email, password: password);
    await _storage.write(key: _tokenKey, value: token);
    _cachedToken = token;
    return token;
  }

  /// Token stocké (lecture au démarrage pour session persistante).
  Future<String?> getStoredToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  /// Déconnexion : supprime le token (pas de log).
  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
    _cachedToken = null;
  }

  /// Client GraphQL avec token pour requêtes authentifiées.
  /// Appeler [getStoredToken] au préalable pour remplir le cache ; sinon le client est créé sans token.
  GraphQLClient getAuthenticatedClient() {
    if (kDebugMode && _cachedToken == null) {
      debugPrint(
        'AuthService.getAuthenticatedClient: token non chargé. '
        'Appeler getStoredToken() au démarrage pour les requêtes authentifiées.',
      );
    }
    return createGraphQLClient(authToken: _cachedToken);
  }
}
