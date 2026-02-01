// Story 2.2 – Tests widget écran placeholder « Démarrer » (Story 3.1 = écran de jeu).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/investigation/screens/investigation_start_placeholder_screen.dart';

void main() {
  testWidgets(
    'InvestigationStartPlaceholderScreen shows title and investigation id',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InvestigationStartPlaceholderScreen(investigationId: 'inv-123'),
        ),
      );

      expect(find.text('Démarrer l\'enquête'), findsOneWidget);
      expect(find.text('Enquête inv-123'), findsOneWidget);
      expect(
        find.text('L\'écran de jeu sera implémenté en Story 3.1.'),
        findsOneWidget,
      );
      expect(find.text('Retour'), findsOneWidget);
    },
  );
}
