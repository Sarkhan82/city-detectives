import 'package:graphql_flutter/graphql_flutter.dart';

/// Utilisateur courant (Story 7.1 – FR61). Exposé par la query me.
class CurrentUser {
  const CurrentUser({required this.id, required this.isAdmin});
  final String id;
  final bool isAdmin;
}

/// Repository utilisateur (Story 1.2, 7.1) – mutation register, query me.
/// Backend = source de vérité ; pas de validation métier côté client.
class UserRepository {
  UserRepository(this._client);

  final GraphQLClient _client;

  static const String _registerMutation = r'''
    mutation Register($email: String!, $password: String!) {
      register(email: $email, password: $password)
    }
  ''';

  static const String _meQuery = r'''
    query Me {
      me {
        id
        isAdmin
      }
    }
  ''';

  /// Inscription : envoie email + mot de passe, retourne le JWT ou une erreur.
  Future<String> register({
    required String email,
    required String password,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_registerMutation),
        variables: {'email': email, 'password': password},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur d\'inscription';
      throw Exception(message);
    }
    final token = result.data?['register'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Réponse invalide du serveur');
    }
    return token;
  }

  /// Utilisateur courant (Story 7.1 – FR61). Requiert Bearer token. Retourne id et isAdmin.
  Future<CurrentUser> getMe() async {
    final result = await _client.query(QueryOptions(document: gql(_meQuery)));
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur chargement utilisateur';
      throw Exception(message);
    }
    final me = result.data?['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw Exception('Réponse invalide du serveur');
    }
    final id = me['id'] as String?;
    final isAdmin = me['isAdmin'] as bool? ?? false;
    if (id == null || id.isEmpty) {
      throw Exception('Réponse invalide du serveur');
    }
    return CurrentUser(id: id, isAdmin: isAdmin);
  }
}
