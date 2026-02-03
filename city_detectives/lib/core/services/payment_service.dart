import 'package:graphql_flutter/graphql_flutter.dart';

/// Interface du service paiement (Story 6.2) – permet de mocker en tests.
abstract interface class PaymentServiceInterface {
  Future<void> recordPurchaseIntent(String investigationId);
  Future<void> simulatePurchase(String investigationId);
  Future<List<String>> getUserPurchases();
}

/// Service paiement (Story 6.2 – FR48, FR52, FR53).
/// MVP : simulation uniquement ; recordPurchaseIntent, simulatePurchase, getUserPurchases.
/// Utilise un [GraphQLClient] authentifié (Bearer).
class PaymentService implements PaymentServiceInterface {
  PaymentService(this._client);

  final GraphQLClient _client;

  static const String _recordIntentMutation = r'''
    mutation RecordPurchaseIntent($investigationId: String!) {
      recordPurchaseIntent(investigationId: $investigationId)
    }
  ''';

  static const String _simulatePurchaseMutation = r'''
    mutation SimulatePurchase($investigationId: String!) {
      simulatePurchase(investigationId: $investigationId)
    }
  ''';

  static const String _getUserPurchasesQuery = r'''
    query GetUserPurchases {
      getUserPurchases
    }
  ''';

  /// Enregistre une intention d'achat (clic Acheter/Payer) – FR52.
  @override
  Future<void> recordPurchaseIntent(String investigationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_recordIntentMutation),
        variables: <String, dynamic>{'investigationId': investigationId},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors;
      final msg = errors != null && errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString();
      throw Exception(msg ?? 'Erreur enregistrement intention d\'achat');
    }
    final ok = result.data?['recordPurchaseIntent'] as bool?;
    if (ok != true) throw Exception('recordPurchaseIntent a échoué');
  }

  /// Simule un achat réussi (MVP) – FR48, FR53.
  @override
  Future<void> simulatePurchase(String investigationId) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(_simulatePurchaseMutation),
        variables: <String, dynamic>{'investigationId': investigationId},
      ),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors;
      final msg = errors != null && errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString();
      throw Exception(msg ?? 'Erreur simulation achat');
    }
    final ok = result.data?['simulatePurchase'] as bool?;
    if (ok != true) throw Exception('simulatePurchase a échoué');
  }

  /// Liste des IDs d'enquêtes achetées par l'utilisateur courant – FR48.
  @override
  Future<List<String>> getUserPurchases() async {
    final result = await _client.query(
      QueryOptions(document: gql(_getUserPurchasesQuery)),
    );
    if (result.hasException) {
      final errors = result.exception?.graphqlErrors;
      final msg = errors != null && errors.isNotEmpty
          ? errors.first.message
          : result.exception?.linkException?.toString();
      throw Exception(msg ?? 'Erreur chargement achats');
    }
    final list = result.data?['getUserPurchases'] as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => e.toString()).toList();
  }
}
