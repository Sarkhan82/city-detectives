import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/core/services/investigation_error_handler.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_cache.dart';

/// Repository des enquêtes (Story 2.1, 3.1, 3.4) – listInvestigations, investigation(id).
/// Cache-first (FR78) : chargement depuis cache en priorité (<2s), rafraîchissement en arrière-plan.
class InvestigationRepository {
  InvestigationRepository(this._client, [InvestigationCache? cache])
    : _cache = cache;

  final GraphQLClient _client;
  final InvestigationCache? _cache;

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
          centerLat
          centerLng
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

  /// Liste des enquêtes disponibles (Story 3.4 : cache-first, <2s).
  Future<List<Investigation>> listInvestigations() async {
    if (_cache != null) {
      final cached = _cache.getCachedList();
      if (cached != null && cached.isNotEmpty) {
        final list = cached.map((e) => Investigation.fromJson(e)).toList();
        _refreshListInBackground();
        return list;
      }
    }
    return _fetchListFromApi();
  }

  Future<void> _refreshListInBackground() async {
    try {
      final list = await _fetchListFromApi();
      if (_cache != null && list.isNotEmpty) {
        final raw = list.map((e) => _investigationToMap(e)).toList();
        await _cache.putList(raw);
      }
    } catch (e, st) {
      logInvestigationError(
        Exception('Background refresh list failed: $e'),
        st,
      );
    }
  }

  static Map<String, dynamic> _investigationToMap(Investigation i) => {
    'id': i.id,
    'titre': i.titre,
    'description': i.description,
    'durationEstimate': i.durationEstimate,
    'difficulte': i.difficulte,
    'isFree': i.isFree,
    'centerLat': i.centerLat,
    'centerLng': i.centerLng,
  };

  Future<List<Investigation>> _fetchListFromApi() async {
    final result = await _client.query(QueryOptions(document: gql(_listQuery)));
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur lors du chargement des enquêtes';
      logInvestigationError(Exception(message));
      throw Exception(message);
    }
    final list = result.data?['listInvestigations'] as List<dynamic>?;
    if (list == null) return [];
    final investigations = list
        .map((e) => Investigation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (_cache != null && investigations.isNotEmpty) {
      final raw = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.putList(raw);
    }
    return investigations;
  }

  /// Enquête par id avec énigmes (Story 3.4 : cache-first, <2s).
  Future<InvestigationWithEnigmas?> getInvestigationById(String id) async {
    if (_cache != null) {
      final cached = _cache.getCachedDetail(id);
      if (cached != null) {
        final invMap = cached['investigation'] as Map<String, dynamic>?;
        final enigmasList = cached['enigmas'] as List<dynamic>?;
        if (invMap != null && enigmasList != null) {
          final investigation = Investigation.fromJson(invMap);
          final enigmas = enigmasList
              .map((e) => Enigma.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          _refreshDetailInBackground(id);
          return InvestigationWithEnigmas(
            investigation: investigation,
            enigmas: enigmas,
          );
        }
      }
    }
    return _fetchDetailFromApi(id);
  }

  Future<void> _refreshDetailInBackground(String id) async {
    try {
      await _fetchDetailFromApi(id);
    } catch (e, st) {
      logInvestigationError(
        Exception('Background refresh detail $id failed: $e'),
        st,
      );
    }
  }

  Future<InvestigationWithEnigmas?> _fetchDetailFromApi(String id) async {
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
      logInvestigationError(Exception(message));
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
    final data = InvestigationWithEnigmas(
      investigation: investigation,
      enigmas: enigmas,
    );
    if (_cache != null) {
      await _cache.putDetail(id, root);
    }
    return data;
  }
}
