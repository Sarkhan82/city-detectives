import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';

/// Repository admin pour création/édition d’énigmes et validation
/// du contenu historique (Story 7.2 – FR63, FR64).
class AdminEnigmaRepository {
  AdminEnigmaRepository(this._client);

  final GraphQLClient _client;

  static const String _createMutation = r'''
    mutation CreateEnigma($input: CreateEnigmaInput!) {
      createEnigma(input: $input) {
        id
        investigationId
        orderIndex
        type
        titre
        consigne
        targetLat
        targetLng
        toleranceMeters
        referencePhotoUrl
        hintSuggestion
        hintHint
        hintSolution
        historicalExplanation
        educationalContent
        historicalContentValidated
      }
    }
  ''';

  static const String _updateMutation = r'''
    mutation UpdateEnigma($id: String!, $input: UpdateEnigmaInput!) {
      updateEnigma(id: $id, input: $input) {
        id
        investigationId
        orderIndex
        type
        titre
        consigne
        targetLat
        targetLng
        toleranceMeters
        referencePhotoUrl
        hintSuggestion
        hintHint
        hintSolution
        historicalExplanation
        educationalContent
        historicalContentValidated
      }
    }
  ''';

  static const String _validateHistoricalMutation = r'''
    mutation ValidateEnigmaHistoricalContent($enigmaId: String!) {
      validateEnigmaHistoricalContent(enigmaId: $enigmaId) {
        id
        historicalContentValidated
      }
    }
  ''';

  /// Crée une énigme pour une enquête donnée (admin uniquement – FR63).
  Future<Enigma> createEnigma({
    required String investigationId,
    required int orderIndex,
    required String type,
    required String titre,
    String? consigne,
    double? targetLat,
    double? targetLng,
    double? toleranceMeters,
    String? referencePhotoUrl,
    String? hintSuggestion,
    String? hintHint,
    String? hintSolution,
    String? historicalExplanation,
    String? educationalContent,
    bool? historicalContentValidated,
  }) async {
    final input = <String, dynamic>{
      'investigationId': investigationId,
      'orderIndex': orderIndex,
      'type': type,
      'titre': titre,
      if (consigne != null && consigne.isNotEmpty) 'consigne': consigne,
      if (targetLat != null) 'targetLat': targetLat,
      if (targetLng != null) 'targetLng': targetLng,
      if (toleranceMeters != null) 'toleranceMeters': toleranceMeters,
      if (referencePhotoUrl != null && referencePhotoUrl.isNotEmpty)
        'referencePhotoUrl': referencePhotoUrl,
      if (hintSuggestion != null && hintSuggestion.isNotEmpty)
        'hintSuggestion': hintSuggestion,
      if (hintHint != null && hintHint.isNotEmpty) 'hintHint': hintHint,
      if (hintSolution != null && hintSolution.isNotEmpty)
        'hintSolution': hintSolution,
      if (historicalExplanation != null && historicalExplanation.isNotEmpty)
        'historicalExplanation': historicalExplanation,
      if (educationalContent != null && educationalContent.isNotEmpty)
        'educationalContent': educationalContent,
      if (historicalContentValidated != null)
        'historicalContentValidated': historicalContentValidated,
    };

    final result = await _client.mutate(
      MutationOptions(
        document: gql(_createMutation),
        variables: <String, dynamic>{'input': input},
      ),
    );

    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors de la création de l’énigme';
      throw Exception(message);
    }
    final data = result.data?['createEnigma'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Enigma.fromJson(data);
  }

  /// Met à jour une énigme existante (admin – FR63, FR64).
  Future<Enigma> updateEnigma(
    String id, {
    int? orderIndex,
    String? type,
    String? titre,
    String? consigne,
    double? targetLat,
    double? targetLng,
    double? toleranceMeters,
    String? referencePhotoUrl,
    String? hintSuggestion,
    String? hintHint,
    String? hintSolution,
    String? historicalExplanation,
    String? educationalContent,
    bool? historicalContentValidated,
  }) async {
    final input = <String, dynamic>{
      if (orderIndex != null) 'orderIndex': orderIndex,
      if (type != null && type.isNotEmpty) 'type': type,
      if (titre != null && titre.isNotEmpty) 'titre': titre,
      if (targetLat != null) 'targetLat': targetLat,
      if (targetLng != null) 'targetLng': targetLng,
      if (toleranceMeters != null) 'toleranceMeters': toleranceMeters,
      if (referencePhotoUrl != null && referencePhotoUrl.isNotEmpty)
        'referencePhotoUrl': referencePhotoUrl,
      if (consigne != null && consigne.isNotEmpty) 'consigne': consigne,
      if (hintSuggestion != null && hintSuggestion.isNotEmpty)
        'hintSuggestion': hintSuggestion,
      if (hintHint != null && hintHint.isNotEmpty) 'hintHint': hintHint,
      if (hintSolution != null && hintSolution.isNotEmpty)
        'hintSolution': hintSolution,
      if (historicalExplanation != null && historicalExplanation.isNotEmpty)
        'historicalExplanation': historicalExplanation,
      if (educationalContent != null && educationalContent.isNotEmpty)
        'educationalContent': educationalContent,
      if (historicalContentValidated != null)
        'historicalContentValidated': historicalContentValidated,
    };

    final result = await _client.mutate(
      MutationOptions(
        document: gql(_updateMutation),
        variables: <String, dynamic>{'id': id, 'input': input},
      ),
    );

    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors de la mise à jour de l’énigme';
      throw Exception(message);
    }
    final data = result.data?['updateEnigma'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Enigma.fromJson(data);
  }

  /// Marque le contenu historique comme validé (FR64).
  Future<Enigma> validateHistoricalContent(String enigmaId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_validateHistoricalMutation),
        variables: <String, dynamic>{'enigmaId': enigmaId},
      ),
    );

    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors de la validation du contenu historique';
      throw Exception(message);
    }
    final data =
        result.data?['validateEnigmaHistoricalContent']
            as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Enigma.fromJson(data);
  }
}
