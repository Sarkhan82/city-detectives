import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/repositories/dashboard_repository.dart';

/// Client GraphQL authentifié pour le dashboard admin (Story 7.1 – FR61).
final _dashboardGraphqlClientProvider = Provider<GraphQLClient>((ref) {
  final token = ref.watch(_authTokenForDashboardProvider).valueOrNull;
  return createGraphQLClient(authToken: token);
});

final _authTokenForDashboardProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return auth.getStoredToken();
});

/// Vue d'ensemble du dashboard admin. AsyncValue pour chargement / erreur / données (Story 7.1 – FR61).
final adminDashboardProvider = FutureProvider<DashboardOverview>((ref) async {
  final client = ref.watch(_dashboardGraphqlClientProvider);
  final repo = DashboardRepository(client);
  return repo.getAdminDashboard();
});
