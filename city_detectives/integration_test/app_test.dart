// E2E – parcours welcome → register ; optionnel : onboarding → investigations (nécessite API mockée).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:city_detectives/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App E2E', () {
    testWidgets('app launches and shows welcome screen', (
      WidgetTester tester,
    ) async {
      runApp(const App());
      await tester.pumpAndSettle();

      expect(find.text('City Detectives'), findsOneWidget);
      expect(find.text('L\'expérience d\'enquête urbaine'), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
    });

    testWidgets('tap Continuer navigates to register screen', (
      WidgetTester tester,
    ) async {
      runApp(const App());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.text('Créer un compte'), findsOneWidget);
      expect(find.text('Créer mon compte'), findsOneWidget);
    });

    testWidgets('from register, back returns to welcome', (
      WidgetTester tester,
    ) async {
      runApp(const App());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('City Detectives'), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
    });
  });
}
