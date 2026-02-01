// Story 1.2 – Tests widget écran d'inscription (champs, bouton).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/app.dart';
import 'package:city_detectives/core/router/app_router.dart';
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
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Les mots de passe ne correspondent pas.'), findsOneWidget);
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
      ProviderScope(
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });
}
