// Story 1.1 – Vérifier que l'app se construit et affiche l'écran d'accueil (FR1).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/core/services/auth_service.dart';
import 'package:city_detectives/features/onboarding/providers/onboarding_provider.dart';
import 'package:city_detectives/features/onboarding/providers/onboarding_storage.dart';
import 'package:city_detectives/features/onboarding/screens/register_screen.dart';
import 'package:city_detectives/features/onboarding/screens/welcome_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class _FakeAuthNoToken implements AuthService {
  @override
  Future<String?> getStoredToken() async => null;

  @override
  Future<String> register({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  GraphQLClient getAuthenticatedClient() => createGraphQLClient();
}

class _FakeOnboardingStorage implements OnboardingStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  testWidgets('App builds and shows welcome screen (FR1)', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.welcome,
      routes: [
        GoRoute(
          path: AppRouter.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRouter.register,
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_FakeAuthNoToken()),
          onboardingStorageProvider.overrideWithValue(_FakeOnboardingStorage()),
        ],
        child: MaterialApp.router(
          title: 'City Detectives',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('City Detectives'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('WelcomeScreen builds without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
    );
    await tester.pump();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
