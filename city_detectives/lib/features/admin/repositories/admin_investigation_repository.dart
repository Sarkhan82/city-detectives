import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';

/// Repository admin pour CRUD enquêtes + prévisualisation, publication et
/// rollback (Story 7.2 – FR62, 7.3 – FR65, FR66, FR67).
class AdminInvestigationRepository {
  AdminInvestigationRepository(this._client);

  final GraphQLClient _client;

  static const String _investigationForPreviewQuery = r'''
    query InvestigationForPreview($id: String!) {
      investigationForPreview(id: $id) {
        investigation {
          id
          titre
          description
          durationEstimate
          difficulte
          isFree
          priceAmount
          priceCurrency
          centerLat
          centerLng
          status
        }
        enigmas {
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
    }
  ''';

  static const String _createMutation = r'''
    mutation CreateInvestigation($input: CreateInvestigationInput!) {
      createInvestigation(input: $input) {
        id
        titre
        description
        durationEstimate
        difficulte
        isFree
        priceAmount
        priceCurrency
        centerLat
        centerLng
        status
      }
    }
  ''';

  static const String _updateMutation = r'''
    mutation UpdateInvestigation($id: String!, $input: UpdateInvestigationInput!) {
      updateInvestigation(id: $id, input: $input) {
        id
        titre
        description
        durationEstimate
        difficulte
        isFree
        priceAmount
        priceCurrency
        centerLat
        centerLng
        status
      }
    }
  ''';

  static const String _publishMutation = r'''
    mutation PublishInvestigation($id: String!) {
      publishInvestigation(id: $id) {
        id
        titre
        status
      }
    }
  ''';

  static const String _rollbackMutation = r'''
    mutation RollbackInvestigation($id: String!) {
      rollbackInvestigation(id: $id) {
        id
        titre
        status
      }
    }
  ''';

  /// Crée une enquête (admin – Story 7.2, FR62).
  Future<Investigation> createInvestigation({
    required String titre,
    required String description,
    required int durationEstimate,
    required String difficulte,
    required bool isFree,
    int? priceAmount,
    String? priceCurrency,
    double? centerLat,
    double? centerLng,
    String status = 'draft',
  }) async {
    final input = <String, dynamic>{
      'titre': titre,
      'description': description,
      'durationEstimate': durationEstimate,
      'difficulte': difficulte,
      'isFree': isFree,
      'status': status,
      if (!isFree && priceAmount != null) 'priceAmount': priceAmount,
      if (!isFree && (priceCurrency?.isNotEmpty ?? false))
        'priceCurrency': priceCurrency!,
      if (centerLat != null) 'centerLat': centerLat,
      if (centerLng != null) 'centerLng': centerLng,
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
                'Erreur lors de la création de l’enquête';
      throw Exception(message);
    }
    final data = result.data?['createInvestigation'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Investigation.fromJson(data);
  }

  /// Met à jour une enquête existante (admin – Story 7.2, FR62).
  Future<Investigation> updateInvestigation(
    String id, {
    String? titre,
    String? description,
    int? durationEstimate,
    String? difficulte,
    bool? isFree,
    int? priceAmount,
    String? priceCurrency,
    double? centerLat,
    double? centerLng,
    String? status,
  }) async {
    final input = <String, dynamic>{
      if (titre?.isNotEmpty ?? false) 'titre': titre!,
      if (description?.isNotEmpty ?? false) 'description': description!,
      if (durationEstimate != null) 'durationEstimate': durationEstimate,
      if (difficulte?.isNotEmpty ?? false) 'difficulte': difficulte!,
      if (isFree != null) 'isFree': isFree,
      if (priceAmount != null) 'priceAmount': priceAmount,
      if (priceCurrency?.isNotEmpty ?? false) 'priceCurrency': priceCurrency!,
      if (centerLat != null) 'centerLat': centerLat,
      if (centerLng != null) 'centerLng': centerLng,
      if (status?.isNotEmpty ?? false) 'status': status!,
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
                'Erreur lors de la mise à jour de l’enquête';
      throw Exception(message);
    }
    final data = result.data?['updateInvestigation'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Investigation.fromJson(data);
  }

  /// Prévisualisation d'une enquête (brouillon ou publiée) – admin uniquement (FR65).
  Future<InvestigationWithEnigmas?> getInvestigationForPreview(
    String id,
  ) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_investigationForPreviewQuery),
        variables: <String, dynamic>{'id': id},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors du chargement de la prévisualisation';
      throw Exception(message);
    }
    final root =
        result.data?['investigationForPreview'] as Map<String, dynamic>?;
    if (root == null) return null;
    final invMap = root['investigation'] as Map<String, dynamic>?;
    final enigmasList = root['enigmas'] as List<dynamic>?;
    if (invMap == null || enigmasList == null) return null;
    final investigation = Investigation.fromJson(invMap);
    final enigmas = enigmasList
        .map((e) => Enigma.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return InvestigationWithEnigmas(
      investigation: investigation,
      enigmas: enigmas,
    );
  }

  /// Publie une enquête (draft → published) – admin uniquement (FR66).
  Future<Investigation> publishInvestigation(String id) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_publishMutation),
        variables: <String, dynamic>{'id': id},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors de la publication';
      throw Exception(message);
    }
    final data = result.data?['publishInvestigation'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Investigation.fromJson(data);
  }

  /// Dépublie une enquête (published → draft) – admin uniquement (FR67).
  Future<Investigation> rollbackInvestigation(String id) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_rollbackMutation),
        variables: <String, dynamic>{'id': id},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors du rollback';
      throw Exception(message);
    }
    final data = result.data?['rollbackInvestigation'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide');
    return Investigation.fromJson(data);
  }
}
