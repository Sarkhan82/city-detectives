// Story 1.2 – Tests widget écran d'inscription (champs, bouton).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/app.dart';
import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/core/services/auth_service.dart';
import 'package:city_detectives/features/onboarding/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen shows form fields and submit button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Créer un compte'), findsOneWidget);
    expect(find.text('Créer mon compte'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('RegisterScreen shows error when passwords do not match', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.register,
      routes: [
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

    await tester.enterText(
      find.byKey(const Key('register_email')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm')),
      'different',
    );
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
  });

  testWidgets('RegisterScreen builds in isolation with router', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.register,
      routes: [
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

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });

  testWidgets('RegisterScreen shows API error when register fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith(
            (ref) => _FakeAuthServiceThrowsApiError(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: AppRouter.register,
            routes: [
              GoRoute(
                path: AppRouter.register,
                builder: (context, state) => const RegisterScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('register_email')),
      'used@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register_password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm')),
      'password123',
    );
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Email déjà utilisé'), findsOneWidget);
  });
}

/// AuthService factice qui lance une erreur API au register (Story 1.2 – test affichage erreur).
class _FakeAuthServiceThrowsApiError extends AuthService {
  _FakeAuthServiceThrowsApiError() : super();

  @override
  Future<String> register({
    required String email,
    required String password,
  }) async {
    throw Exception('Email déjà utilisé');
  }
}
