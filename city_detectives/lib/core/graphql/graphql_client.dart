import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/config/app_config.dart';

/// Client GraphQL partagé (Story 1.2).
/// Utilise [AppConfig.apiBaseUrl] ; en prod l’URL doit être HTTPS.
GraphQLClient createGraphQLClient({String? authToken}) {
  final url = AppConfig.apiBaseUrl;
  if (kDebugMode &&
      !url.startsWith('https') &&
      !url.contains('localhost') &&
      !url.contains('127.0.0.1')) {
    debugPrint('⚠️ API_BASE_URL should be HTTPS in production. Current: $url');
  }
  final link = AuthLink(
    getToken: () async => authToken != null ? 'Bearer $authToken' : null,
  ).concat(HttpLink('$url/graphql'));
  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: link,
  );
}
