// Story 1.1 / 1.3 – Tests widget WelcomeScreen : contenu, navigation vers inscription, redirection si token.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/core/services/auth_service.dart';
import 'package:city_detectives/features/onboarding/providers/onboarding_provider.dart';
import 'package:city_detectives/features/onboarding/providers/onboarding_storage.dart';
import 'package:city_detectives/features/onboarding/screens/onboarding_screen.dart';
import 'package:city_detectives/features/onboarding/screens/register_screen.dart';
import 'package:city_detectives/features/onboarding/screens/welcome_screen.dart';

/// Fake AuthService pour les tests : getStoredToken retourne un token configurable.
class FakeAuthService implements AuthService {
  FakeAuthService({String? token}) : _token = token;
  final String? _token;

  @override
  Future<String?> getStoredToken() async => _token;

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

/// Stockage onboarding en mémoire pour les tests.
class _FakeOnboardingStorage implements OnboardingStorage {
  _FakeOnboardingStorage([Map<String, String>? initial])
    : _store = Map.from(initial ?? {});
  final Map<String, String> _store;

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  testWidgets('WelcomeScreen shows title and Continuer button (FR1)', (
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
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    expect(find.text('City Detectives'), findsOneWidget);
    expect(find.text('L\'expérience d\'enquête urbaine'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('WelcomeScreen tap Continuer navigates to register screen', (
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
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });

  testWidgets(
    'WelcomeScreen has Semantics for accessibility (WCAG 2.1 Level A)',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.welcome,
        routes: [
          GoRoute(
            path: AppRouter.welcome,
            builder: (context, state) => const WelcomeScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    },
  );

  testWidgets(
    'WelcomeScreen with token and onboarding not completed redirects to onboarding',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.welcome,
        routes: [
          GoRoute(
            path: AppRouter.welcome,
            builder: (context, state) => const WelcomeScreen(),
          ),
          GoRoute(
            path: AppRouter.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(
              FakeAuthService(token: 'token'),
            ),
            onboardingStorageProvider.overrideWithValue(
              _FakeOnboardingStorage(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Votre première enquête'), findsOneWidget);
    },
  );

  testWidgets(
    'WelcomeScreen with token and onboarding completed redirects to home',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.welcome,
        routes: [
          GoRoute(
            path: AppRouter.welcome,
            builder: (context, state) => const WelcomeScreen(),
          ),
          GoRoute(
            path: AppRouter.home,
            builder: (context, state) => Scaffold(
              body: Center(child: Text('Bienvenue – vous êtes connecté.')),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(
              FakeAuthService(token: 'token'),
            ),
            onboardingStorageProvider.overrideWithValue(
              _FakeOnboardingStorage({'onboarding_completed': 'true'}),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bienvenue – vous êtes connecté.'), findsOneWidget);
    },
  );
}
