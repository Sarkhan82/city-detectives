import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/admin/models/completion_rate_entry.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/models/technical_metrics.dart';
import 'package:city_detectives/features/admin/models/user_analytics.dart';
import 'package:city_detectives/features/admin/models/user_journey_analytics.dart';

/// Repository dashboard admin (Story 7.1 – FR61, 7.4 – FR68). getAdminDashboard et getTechnicalMetrics (réservés aux admins).
class DashboardRepository {
  DashboardRepository(this._client);

  final GraphQLClient _client;

  static const String _getAdminDashboardQuery = r'''
    query GetAdminDashboard {
      getAdminDashboard {
        investigationCount
        publishedCount
        draftCount
        enigmaCount
      }
    }
  ''';

  static const String _getTechnicalMetricsQuery = r'''
    query GetTechnicalMetrics {
      getTechnicalMetrics {
        healthStatus
        apiLatencyAvgMs
        apiLatencyP95Ms
        errorRate
        crashCount
        sentryDashboardUrl
      }
    }
  ''';

  static const String _getUserAnalyticsQuery = r'''
    query GetUserAnalytics {
      getUserAnalytics {
        activeUserCount
        totalCompletions
      }
    }
  ''';

  static const String _getCompletionRatesQuery = r'''
    query GetCompletionRates {
      getCompletionRates {
        investigationId
        investigationTitle
        startedCount
        completedCount
        completionRate
      }
    }
  ''';

  static const String _getUserJourneyAnalyticsQuery = r'''
    query GetUserJourneyAnalytics {
      getUserJourneyAnalytics {
        funnelSteps { label userCount }
      }
    }
  ''';

  /// Récupère la vue d'ensemble. Lance une exception si 403 (non-admin) ou erreur réseau.
  Future<DashboardOverview> getAdminDashboard() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getAdminDashboardQuery)),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final code = errors.isNotEmpty
          ? (errors.first.extensions?['code'] as String?)
          : null;
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur chargement dashboard';
      if (code == 'FORBIDDEN' || message.toLowerCase().contains('réservé')) {
        throw DashboardForbiddenException(message);
      }
      throw Exception(message);
    }
    final data = result.data?['getAdminDashboard'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Réponse invalide du serveur');
    }
    return DashboardOverview.fromJson(data);
  }

  /// Récupère les métriques techniques (Story 7.4 – FR68). Lance une exception si 403 ou erreur.
  Future<TechnicalMetrics> getTechnicalMetrics() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getTechnicalMetricsQuery)),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final code = errors.isNotEmpty
          ? (errors.first.extensions?['code'] as String?)
          : null;
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ??
                'Erreur chargement métriques techniques';
      if (code == 'FORBIDDEN' || message.toLowerCase().contains('réservé')) {
        throw DashboardForbiddenException(message);
      }
      throw Exception(message);
    }
    final data = result.data?['getTechnicalMetrics'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Réponse invalide du serveur');
    }
    return TechnicalMetrics.fromJson(data);
  }

  /// Récupère les analytics utilisateurs (Story 7.4 – FR69, FR70).
  Future<UserAnalytics> getUserAnalytics() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getUserAnalyticsQuery)),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final code = errors.isNotEmpty
          ? (errors.first.extensions?['code'] as String?)
          : null;
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ?? 'Erreur chargement analytics';
      if (code == 'FORBIDDEN' || message.toLowerCase().contains('réservé')) {
        throw DashboardForbiddenException(message);
      }
      throw Exception(message);
    }
    final data = result.data?['getUserAnalytics'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide du serveur');
    return UserAnalytics.fromJson(data);
  }

  /// Récupère les taux de complétion par enquête (Story 7.4 – FR70).
  Future<List<CompletionRateEntry>> getCompletionRates() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getCompletionRatesQuery)),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final code = errors.isNotEmpty
          ? (errors.first.extensions?['code'] as String?)
          : null;
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ?? 'Erreur chargement taux';
      if (code == 'FORBIDDEN' || message.toLowerCase().contains('réservé')) {
        throw DashboardForbiddenException(message);
      }
      throw Exception(message);
    }
    final list = result.data?['getCompletionRates'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => CompletionRateEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Récupère le parcours utilisateur (funnel) (Story 7.4 – FR71).
  Future<UserJourneyAnalytics> getUserJourneyAnalytics() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getUserJourneyAnalyticsQuery)),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors ?? [];
      final code = errors.isNotEmpty
          ? (errors.first.extensions?['code'] as String?)
          : null;
      final message = errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString() ?? 'Erreur chargement parcours';
      if (code == 'FORBIDDEN' || message.toLowerCase().contains('réservé')) {
        throw DashboardForbiddenException(message);
      }
      throw Exception(message);
    }
    final data = result.data?['getUserJourneyAnalytics'] as Map<String, dynamic>?;
    if (data == null) throw Exception('Réponse invalide du serveur');
    return UserJourneyAnalytics.fromJson(data);
  }
}

/// Erreur 403 – accès réservé aux administrateurs (Story 7.1 – FR61).
class DashboardForbiddenException implements Exception {
  DashboardForbiddenException(this.message);
  final String message;
  @override
  String toString() => message;
}
