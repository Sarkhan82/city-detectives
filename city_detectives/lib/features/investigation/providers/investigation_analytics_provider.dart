import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_analytics_repository.dart';

/// Client GraphQL authentifié pour les événements analytics d'enquête.
final _analyticsGraphqlClientProvider = Provider<GraphQLClient>((ref) {
  final token = ref.watch(_authTokenForAnalyticsProvider).valueOrNull;
  return createGraphQLClient(authToken: token);
});

final _authTokenForAnalyticsProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return auth.getStoredToken();
});

/// Repository analytics d'enquête (Story 7.4 – FR69, FR70).
final investigationAnalyticsRepositoryProvider =
    Provider<InvestigationAnalyticsRepository>((ref) {
  final client = ref.watch(_analyticsGraphqlClientProvider);
  return InvestigationAnalyticsRepository(client);
});

