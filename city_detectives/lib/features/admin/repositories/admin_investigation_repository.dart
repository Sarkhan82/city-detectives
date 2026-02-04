import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';

/// Repository admin pour prévisualisation, publication et rollback (Story 7.3 – FR65, FR66, FR67).
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
          orderIndex
          type
          titre
        }
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
