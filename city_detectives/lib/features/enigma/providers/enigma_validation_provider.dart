import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';

/// Client GraphQL avec token pour la mutation validateEnigmaResponse (authentification requise).
final _graphqlClientProvider = Provider<GraphQLClient>((ref) {
  final token = ref.watch(_authTokenForEnigmaProvider).valueOrNull;
  return createGraphQLClient(authToken: token);
});

final _authTokenForEnigmaProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return auth.getStoredToken();
});

/// Repository de validation des énigmes (Story 4.1).
final enigmaValidationRepositoryProvider = Provider<EnigmaValidationRepository>(
  (ref) {
    final client = ref.watch(_graphqlClientProvider);
    return EnigmaValidationRepository(client);
  },
);
