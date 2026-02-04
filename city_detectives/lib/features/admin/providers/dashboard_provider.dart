import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/admin/models/completion_rate_entry.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/models/technical_metrics.dart';
import 'package:city_detectives/features/admin/models/user_analytics.dart';
import 'package:city_detectives/features/admin/models/user_journey_analytics.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_repository.dart';
import 'package:city_detectives/features/admin/repositories/admin_investigation_repository.dart';
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

/// Métriques techniques pour le dashboard admin (Story 7.4 – FR68).
final adminTechnicalMetricsProvider = FutureProvider<TechnicalMetrics>((
  ref,
) async {
  final client = ref.watch(_dashboardGraphqlClientProvider);
  final repo = DashboardRepository(client);
  return repo.getTechnicalMetrics();
});

/// Analytics utilisateurs pour le dashboard admin (Story 7.4 – FR69, FR70).
final adminUserAnalyticsProvider = FutureProvider<UserAnalytics>((ref) async {
  final client = ref.watch(_dashboardGraphqlClientProvider);
  final repo = DashboardRepository(client);
  return repo.getUserAnalytics();
});

/// Taux de complétion par enquête pour le dashboard admin (Story 7.4 – FR70).
final adminCompletionRatesProvider = FutureProvider<List<CompletionRateEntry>>((
  ref,
) async {
  final client = ref.watch(_dashboardGraphqlClientProvider);
  final repo = DashboardRepository(client);
  return repo.getCompletionRates();
});

/// Parcours utilisateur (funnel) pour le dashboard admin (Story 7.4 – FR71).
final adminUserJourneyAnalyticsProvider = FutureProvider<UserJourneyAnalytics>((
  ref,
) async {
  final client = ref.watch(_dashboardGraphqlClientProvider);
  final repo = DashboardRepository(client);
  return repo.getUserJourneyAnalytics();
});

/// Repository admin pour prévisualisation, publication, rollback (Story 7.3 – FR65, FR66, FR67).
final adminInvestigationRepositoryProvider =
    Provider<AdminInvestigationRepository>((ref) {
      final client = ref.watch(_dashboardGraphqlClientProvider);
      return AdminInvestigationRepository(client);
    });

/// Liste des enquêtes pour l'admin (toutes, avec status) – Story 7.3.
final adminInvestigationListProvider = FutureProvider<List<Investigation>>((
  ref,
) async {
  final client = ref.watch(_dashboardGraphqlClientProvider);
  final repo = InvestigationRepository(client);
  return repo.listInvestigations();
});

/// Données de prévisualisation d'une enquête (admin) – FR65.
final investigationPreviewProvider =
    FutureProvider.family<InvestigationWithEnigmas?, String>((ref, id) async {
      final repo = ref.watch(adminInvestigationRepositoryProvider);
      return repo.getInvestigationForPreview(id);
    });
