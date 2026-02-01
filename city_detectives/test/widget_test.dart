// Story 1.1 – Vérifier que l'app se construit et affiche l'écran d'accueil (FR1).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/app.dart';
import 'package:city_detectives/features/onboarding/screens/welcome_screen.dart';

void main() {
  testWidgets('App builds and shows welcome screen (FR1)', (
    WidgetTester tester,
  ) async {
    // Given: l'app est lancée
    await tester.pumpWidget(const App());

    // When: un frame est déclenché
    await tester.pump();

    // Then: l'écran d'accueil affiche le titre et le bouton Continuer
    expect(find.text('City Detectives'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('WelcomeScreen builds without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
