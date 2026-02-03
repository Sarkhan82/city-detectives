import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/core/services/payment_service.dart';

/// Token pour requêtes paiement (Story 6.2 – authentification requise).
final _authTokenForPaymentProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return auth.getStoredToken();
});

/// Client GraphQL authentifié pour le service paiement.
final _paymentGraphqlClientProvider = Provider<GraphQLClient>((ref) {
  final token = ref.watch(_authTokenForPaymentProvider).valueOrNull;
  return createGraphQLClient(authToken: token);
});

/// Service paiement (Story 6.2 – FR48, FR52, FR53).
final paymentServiceProvider = Provider<PaymentServiceInterface>((ref) {
  final client = ref.watch(_paymentGraphqlClientProvider);
  return PaymentService(client);
});

/// IDs des enquêtes achetées par l'utilisateur (Story 6.2 – FR48).
/// Invalider après simulatePurchase pour rafraîchir catalogue/détail.
final userPurchasesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(paymentServiceProvider);
  return service.getUserPurchases();
});
