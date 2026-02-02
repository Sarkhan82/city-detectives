import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_cache.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_repository.dart';

/// Client GraphQL pour les requêtes investigation (token optionnel).
final _graphqlClientProvider = Provider<GraphQLClient>((ref) {
  return createGraphQLClient();
});

/// Cache des enquêtes (Story 3.4, FR78) – chargement <2s depuis cache.
final investigationCacheProvider = Provider<InvestigationCache>((ref) {
  final box = Hive.box<String>(kInvestigationCacheBoxName);
  return InvestigationCache(box);
});

/// Repository des enquêtes (Story 2.1, 3.4 – cache-first).
final investigationRepositoryProvider = Provider<InvestigationRepository>((
  ref,
) {
  final client = ref.watch(_graphqlClientProvider);
  final cache = ref.watch(investigationCacheProvider);
  return InvestigationRepository(client, cache);
});

/// État liste des enquêtes : `AsyncValue<List<Investigation>>` (Story 2.1).
/// Pas de booléen isLoading séparé – AsyncValue gère loading/data/error.
final investigationListProvider =
    AsyncNotifierProvider<InvestigationListNotifier, List<Investigation>>(
      InvestigationListNotifier.new,
    );

class InvestigationListNotifier extends AsyncNotifier<List<Investigation>> {
  @override
  Future<List<Investigation>> build() async {
    final repo = ref.read(investigationRepositoryProvider);
    return repo.listInvestigations();
  }
}
