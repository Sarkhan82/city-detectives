import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';

/// Repository des enquêtes (Story 2.1) – query listInvestigations.
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
}
