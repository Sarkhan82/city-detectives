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

  // --- Story 4.3 : indices et explications (FR30, FR31, FR32) ---

  /// Indices progressifs (suggestion, hint, solution) pour une énigme.
  Future<EnigmaHints> getEnigmaHints({required String enigmaId}) async {
    const String query = r'''
      query GetEnigmaHints($enigmaId: String!) {
        getEnigmaHints(enigmaId: $enigmaId) {
          suggestion
          hint
          solution
        }
      }
    ''';
    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: <String, dynamic>{'enigmaId': enigmaId},
      ),
    );
    if (result.hasException) {
      final msg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur chargement indices';
      throw Exception(msg);
    }
    final data = result.data?['getEnigmaHints'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return EnigmaHints.fromJson(data);
  }

  /// Explications historiques et éducatives pour une énigme.
  Future<EnigmaExplanation> getEnigmaExplanation({
    required String enigmaId,
  }) async {
    const String query = r'''
      query GetEnigmaExplanation($enigmaId: String!) {
        getEnigmaExplanation(enigmaId: $enigmaId) {
          historicalExplanation
          educationalContent
        }
      }
    ''';
    final result = await _client.query(
      QueryOptions(
        document: gql(query),
        variables: <String, dynamic>{'enigmaId': enigmaId},
      ),
    );
    if (result.hasException) {
      final msg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur chargement explications';
      throw Exception(msg);
    }
    final data = result.data?['getEnigmaExplanation'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return EnigmaExplanation.fromJson(data);
  }
}

/// Indices progressifs par énigme (Story 4.3 – FR30).
class EnigmaHints {
  const EnigmaHints({
    required this.suggestion,
    required this.hint,
    required this.solution,
  });

  factory EnigmaHints.fromJson(Map<String, dynamic> json) {
    return EnigmaHints(
      suggestion: json['suggestion'] as String? ?? '',
      hint: json['hint'] as String? ?? '',
      solution: json['solution'] as String? ?? '',
    );
  }

  final String suggestion;
  final String hint;
  final String solution;

  /// Niveau 0 = suggestion, 1 = hint, 2 = solution.
  String getLevel(int level) {
    switch (level) {
      case 0:
        return suggestion;
      case 1:
        return hint;
      case 2:
        return solution;
      default:
        return solution;
    }
  }
}

/// Explications historiques et éducatives par énigme (Story 4.3 – FR31, FR32).
class EnigmaExplanation {
  const EnigmaExplanation({
    required this.historicalExplanation,
    required this.educationalContent,
  });

  factory EnigmaExplanation.fromJson(Map<String, dynamic> json) {
    return EnigmaExplanation(
      historicalExplanation: json['historicalExplanation'] as String? ?? '',
      educationalContent: json['educationalContent'] as String? ?? '',
    );
  }

  final String historicalExplanation;
  final String educationalContent;
}
