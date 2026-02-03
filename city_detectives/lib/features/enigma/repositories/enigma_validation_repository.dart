import 'package:graphql_flutter/graphql_flutter.dart';

/// Résultat de la validation d'une énigme (Story 4.1 – FR28, FR29).
class ValidateEnigmaResult {
  const ValidateEnigmaResult({required this.validated, required this.message});

  factory ValidateEnigmaResult.fromJson(Map<String, dynamic> json) {
    return ValidateEnigmaResult(
      validated: json['validated'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  final bool validated;
  final String message;
}

/// Repository de validation des énigmes (Story 4.1) – mutation validateEnigmaResponse.
class EnigmaValidationRepository {
  EnigmaValidationRepository(this._client);

  final GraphQLClient _client;

  static const String _mutation = r'''
    mutation ValidateEnigmaResponse($enigmaId: String!, $payload: ValidateEnigmaPayload!) {
      validateEnigmaResponse(enigmaId: $enigmaId, payload: $payload) {
        validated
        message
      }
    }
  ''';

  /// Valide une réponse géolocalisation (userLat, userLng).
  Future<ValidateEnigmaResult> validateGeolocation({
    required String enigmaId,
    required double userLat,
    required double userLng,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_mutation),
        variables: <String, dynamic>{
          'enigmaId': enigmaId,
          'payload': {'userLat': userLat, 'userLng': userLng},
        },
      ),
    );
    if (result.hasException) {
      final msg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur de validation';
      throw Exception(msg);
    }
    final data =
        result.data?['validateEnigmaResponse'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return ValidateEnigmaResult.fromJson(data);
  }

  /// Valide une réponse photo (photoUrl ou photoBase64).
  Future<ValidateEnigmaResult> validatePhoto({
    required String enigmaId,
    String? photoUrl,
    String? photoBase64,
  }) async {
    final payload = <String, dynamic>{};
    if (photoUrl != null && photoUrl.isNotEmpty) payload['photoUrl'] = photoUrl;
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      payload['photoBase64'] = photoBase64;
    }
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_mutation),
        variables: <String, dynamic>{'enigmaId': enigmaId, 'payload': payload},
      ),
    );
    if (result.hasException) {
      final msg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur de validation';
      throw Exception(msg);
    }
    final data =
        result.data?['validateEnigmaResponse'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return ValidateEnigmaResult.fromJson(data);
  }

  /// Valide une réponse énigme mots (Story 4.2 – FR25, FR28, FR29).
  Future<ValidateEnigmaResult> validateWords({
    required String enigmaId,
    required String textAnswer,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_mutation),
        variables: <String, dynamic>{
          'enigmaId': enigmaId,
          'payload': {'textAnswer': textAnswer},
        },
      ),
    );
    if (result.hasException) {
      final msg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur de validation';
      throw Exception(msg);
    }
    final data =
        result.data?['validateEnigmaResponse'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return ValidateEnigmaResult.fromJson(data);
  }

  /// Valide une réponse énigme puzzle (Story 4.2 – FR26, FR28, FR29).
  Future<ValidateEnigmaResult> validatePuzzle({
    required String enigmaId,
    required String codeAnswer,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_mutation),
        variables: <String, dynamic>{
          'enigmaId': enigmaId,
          'payload': {'codeAnswer': codeAnswer},
        },
      ),
    );
    if (result.hasException) {
      final msg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur de validation';
      throw Exception(msg);
    }
    final data =
        result.data?['validateEnigmaResponse'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return ValidateEnigmaResult.fromJson(data);
  }
}
