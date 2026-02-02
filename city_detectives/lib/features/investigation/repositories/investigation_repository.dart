import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';

/// Repository des enquêtes (Story 2.1, 3.1) – listInvestigations, investigation(id).
/// Backend = source de vérité ; pas de validation métier côté client.
class InvestigationRepository {
  InvestigationRepository(this._client);

  final GraphQLClient _client;

  static const String _listQuery = r'''
    query ListInvestigations {
      listInvestigations {
        id
        titre
        description
        durationEstimate
        difficulte
        isFree
      }
    }
  ''';

  static const String _investigationByIdQuery = r'''
    query GetInvestigationById($id: String!) {
      investigation(id: $id) {
        investigation {
          id
          titre
          description
          durationEstimate
          difficulte
          isFree
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

  /// Liste des enquêtes disponibles (durée, difficulté, description).
  Future<List<Investigation>> listInvestigations() async {
    final result = await _client.query(QueryOptions(document: gql(_listQuery)));
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors du chargement des enquêtes';
      throw Exception(message);
    }
    final list = result.data?['listInvestigations'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Investigation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Enquête par id avec liste ordonnée d'énigmes (Story 3.1) – pour écran « enquête en cours ».
  Future<InvestigationWithEnigmas?> getInvestigationById(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_investigationByIdQuery),
        variables: <String, dynamic>{'id': id},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors du chargement de l\'enquête';
      throw Exception(message);
    }
    final root = result.data?['investigation'] as Map<String, dynamic>?;
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
}
