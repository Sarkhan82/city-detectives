import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/admin/models/dashboard_overview.dart';

/// Repository dashboard admin (Story 7.1 – FR61). Appelle la query getAdminDashboard (réservée aux admins).
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
}

/// Erreur 403 – accès réservé aux administrateurs (Story 7.1 – FR61).
class DashboardForbiddenException implements Exception {
  DashboardForbiddenException(this.message);
  final String message;
  @override
  String toString() => message;
}
