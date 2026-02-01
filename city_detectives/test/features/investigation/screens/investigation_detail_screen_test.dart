// Story 2.2 – Tests widget écran détail enquête (titre, description, chip Gratuit/Payant, CTA Démarrer).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/screens/investigation_detail_screen.dart';

void main() {
  testWidgets(
    'InvestigationDetailScreen shows title, description, Gratuit chip and CTA',
    (WidgetTester tester) async {
      const inv = Investigation(
        id: 'id-1',
        titre: 'Le mystère du parc',
        description: 'Une enquête familiale.',
        durationEstimate: 45,
        difficulte: 'facile',
        isFree: true,
      );

      await tester.pumpWidget(
        MaterialApp(home: InvestigationDetailScreen(investigation: inv)),
      );

      expect(find.text('Le mystère du parc'), findsOneWidget);
      expect(find.text('Une enquête familiale.'), findsOneWidget);
      expect(find.text('Gratuit'), findsOneWidget);
      expect(find.text('Démarrer l\'enquête'), findsOneWidget);
      expect(find.text('~45 min'), findsOneWidget);
      expect(find.text('facile'), findsOneWidget);
    },
  );

  testWidgets(
    'InvestigationDetailScreen shows Payant chip when isFree is false',
    (WidgetTester tester) async {
      const inv = Investigation(
        id: 'id-paid',
        titre: 'Enquête premium',
        description: 'Enquête payante.',
        durationEstimate: 60,
        difficulte: 'moyen',
        isFree: false,
      );

      await tester.pumpWidget(
        MaterialApp(home: InvestigationDetailScreen(investigation: inv)),
      );

      expect(find.text('Payant'), findsOneWidget);
      expect(find.text('Gratuit'), findsNothing);
      expect(find.text('Démarrer l\'enquête'), findsOneWidget);
    },
  );
}
