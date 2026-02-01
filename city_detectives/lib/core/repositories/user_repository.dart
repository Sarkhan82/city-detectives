import 'package:graphql_flutter/graphql_flutter.dart';

/// Repository utilisateur (Story 1.2) – mutation register.
/// Backend = source de vérité ; pas de validation métier côté client.
class UserRepository {
  UserRepository(this._client);

  final GraphQLClient _client;

  static const String _registerMutation = r'''
    mutation Register($email: String!, $password: String!) {
      register(email: $email, password: $password)
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
}
