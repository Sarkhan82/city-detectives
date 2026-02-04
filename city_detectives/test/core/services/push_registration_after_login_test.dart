// Story 8.1 – Task 5.2 : vérifier que le token push est envoyé au backend après login.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/repositories/user_repository.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/core/services/auth_service.dart';
import 'package:city_detectives/core/services/push_provider.dart';
import 'package:city_detectives/core/services/push_service.dart';

void main() {
  test(
    'push registration calls registerWithBackend with auth token when user is logged in',
    () async {
      bool registerWithBackendCalled = false;
      String? capturedAuthToken;
      String? capturedFcmToken;

      final pushService = PushService(
        createClient: (_) => _StubGraphQLClient(),
        getAuthToken: () async => 'jwt-test',
        getTokenOverride: () async => 'fake-fcm-token',
        ensureInitializedForTest: true,
        onRegisterWithBackendCalled: (authToken, fcmToken) {
          registerWithBackendCalled = true;
          capturedAuthToken = authToken;
          capturedFcmToken = fcmToken;
        },
      );

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) =>
                Future.value(const CurrentUser(id: 'user-1', isAdmin: false)),
          ),
          authServiceProvider.overrideWithValue(_FakeAuthWithToken('jwt-test')),
          pushServiceProvider.overrideWithValue(pushService),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(pushRegistrationProvider.future);

      expect(result, isTrue);
      expect(
        registerWithBackendCalled,
        isTrue,
        reason: 'registerWithBackend doit être appelé après login',
      );
      expect(capturedAuthToken, 'jwt-test');
      expect(capturedFcmToken, 'fake-fcm-token');
    },
  );
}

/// Client stub qui retourne un succès pour registerPushToken (évite appel réseau).
class _StubGraphQLClient extends GraphQLClient {
  _StubGraphQLClient()
    : super(link: HttpLink('http://localhost/graphql'), cache: GraphQLCache());

  @override
  Future<QueryResult<TParsed>> mutate<TParsed>(
    MutationOptions<TParsed> options,
  ) {
    return Future.value(
      QueryResult<TParsed>(
        options: options,
        data: {'registerPushToken': true} as Map<String, dynamic>?,
        source: QueryResultSource.network,
      ),
    );
  }
}

class _FakeAuthWithToken implements AuthService {
  _FakeAuthWithToken(this._token);

  final String _token;

  @override
  Future<String?> getStoredToken() async => _token;

  @override
  Future<String> register({
    required String email,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  @override
  GraphQLClient getAuthenticatedClient() => _StubGraphQLClient();
}
