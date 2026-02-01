import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_repository.dart';

/// Client GraphQL pour les requêtes investigation (token optionnel).
final _graphqlClientProvider = Provider<GraphQLClient>((ref) {
  // On pourrait écouter le token ; pour l'instant client sans token pour catalogue public.
  return createGraphQLClient();
});

/// Repository des enquêtes (Story 2.1).
final investigationRepositoryProvider = Provider<InvestigationRepository>((
  ref,
) {
  final client = ref.watch(_graphqlClientProvider);
  return InvestigationRepository(client);
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
