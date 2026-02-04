// Story 7.3 – Tests widget écran prévisualisation admin (FR65). Contenu et liste énigmes (provider mocké).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/screens/investigation_preview_screen.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';

void main() {
  const investigationId = 'preview-test-id';
  final mockPreview = InvestigationWithEnigmas(
    investigation: const Investigation(
      id: investigationId,
      titre: 'Enquête prévisualisation',
      description: 'Description pour la prévisualisation.',
      durationEstimate: 30,
      difficulte: 'facile',
      isFree: true,
      status: 'draft',
    ),
    enigmas: const [
      Enigma(id: 'e1', orderIndex: 0, type: 'text', titre: 'Énigme 1'),
      Enigma(id: 'e2', orderIndex: 1, type: 'geolocation', titre: 'Énigme 2'),
    ],
  );

  testWidgets(
    'InvestigationPreviewScreen shows investigation and enigmas when data loaded',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            investigationPreviewProvider(
              investigationId,
            ).overrideWith((ref) => Future.value(mockPreview)),
          ],
          child: MaterialApp(
            home: InvestigationPreviewScreen(investigationId: investigationId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prévisualisation'), findsOneWidget);
      expect(find.text('Enquête prévisualisation'), findsOneWidget);
      expect(
        find.text('Description pour la prévisualisation.'),
        findsOneWidget,
      );
      expect(find.text('Énigmes (2)'), findsOneWidget);
      expect(find.text('Énigme 1'), findsOneWidget);
      expect(find.text('Énigme 2'), findsOneWidget);
      expect(find.text('Type: text'), findsOneWidget);
      expect(find.text('Type: geolocation'), findsOneWidget);
    },
  );

  testWidgets('InvestigationPreviewScreen shows not found when data is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investigationPreviewProvider(
            investigationId,
          ).overrideWith((ref) => Future.value(null)),
        ],
        child: MaterialApp(
          home: InvestigationPreviewScreen(investigationId: investigationId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enquête introuvable.'), findsOneWidget);
  });

  testWidgets(
    'InvestigationPreviewScreen shows error state and Retour au dashboard button',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            investigationPreviewProvider(
              investigationId,
            ).overrideWith((ref) => Future.error(Exception('Erreur réseau'))),
          ],
          child: MaterialApp(
            home: InvestigationPreviewScreen(investigationId: investigationId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Retour au dashboard'), findsOneWidget);
    },
  );
}
