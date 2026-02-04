import 'package:graphql_flutter/graphql_flutter.dart';

/// Repository analytics d'enquêtes (Story 7.4 – FR69, FR70).
/// Envoie des événements « enquête démarrée » / « enquête complétée » au backend.
class InvestigationAnalyticsRepository {
  InvestigationAnalyticsRepository(this._client);

  final GraphQLClient _client;

  static const String _recordStartedMutation = r'''
    mutation RecordInvestigationStarted($investigationId: String!) {
      recordInvestigationStarted(investigationId: $investigationId)
    }
  ''';

  static const String _recordCompletedMutation = r'''
    mutation RecordInvestigationCompleted($investigationId: String!) {
      recordInvestigationCompleted(investigationId: $investigationId)
    }
  ''';

  Future<void> recordInvestigationStarted(String investigationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_recordStartedMutation),
        variables: <String, dynamic>{'investigationId': investigationId},
      ),
    );
    if (result.hasException) {
      // Analytics best-effort : log côté client si besoin, mais ne bloque pas l'expérience.
      return;
    }
  }

  Future<void> recordInvestigationCompleted(String investigationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_recordCompletedMutation),
        variables: <String, dynamic>{'investigationId': investigationId},
      ),
    );
    if (result.hasException) {
      return;
    }
  }
}

