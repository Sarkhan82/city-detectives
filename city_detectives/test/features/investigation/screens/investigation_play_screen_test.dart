// Story 3.1 – Tests widget écran « enquête en cours » : première énigme, navigation Suivant/Précédent.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/providers/investigation_play_provider.dart';
import 'package:city_detectives/features/investigation/screens/investigation_play_screen.dart';

void main() {
  const investigationId = '11111111-1111-1111-1111-111111111111';
  final mockData = InvestigationWithEnigmas(
    investigation: const Investigation(
      id: investigationId,
      titre: 'Le mystère du parc',
      description: 'Une enquête familiale.',
      durationEstimate: 45,
      difficulte: 'facile',
      isFree: true,
    ),
    enigmas: const [
      Enigma(id: 'e1', orderIndex: 1, type: 'text', titre: 'Première énigme'),
      Enigma(id: 'e2', orderIndex: 2, type: 'text', titre: 'Deuxième énigme'),
      Enigma(id: 'e3', orderIndex: 3, type: 'text', titre: 'Troisième énigme'),
    ],
  );

  Widget wrapWithProviders(Widget child) {
    return ProviderScope(
      overrides: [
        investigationWithEnigmasProvider(
          investigationId,
        ).overrideWith((ref) => Future.value(mockData)),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('InvestigationPlayScreen shows first enigma title and stepper', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        InvestigationPlayScreen(investigationId: investigationId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Le mystère du parc'), findsOneWidget);
    expect(find.text('Énigme 1 / 3'), findsOneWidget);
    expect(find.text('Première énigme'), findsOneWidget);
    expect(find.text('Précédent'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('InvestigationPlayScreen Suivant shows second enigma', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        InvestigationPlayScreen(investigationId: investigationId),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Première énigme'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('Énigme 2 / 3'), findsOneWidget);
    expect(find.text('Deuxième énigme'), findsOneWidget);
  });

  testWidgets('InvestigationPlayScreen Précédent goes back to first enigma', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        InvestigationPlayScreen(investigationId: investigationId),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Deuxième énigme'), findsOneWidget);

    await tester.tap(find.text('Précédent'));
    await tester.pumpAndSettle();
    expect(find.text('Énigme 1 / 3'), findsOneWidget);
    expect(find.text('Première énigme'), findsOneWidget);
  });

  testWidgets('InvestigationPlayScreen shows loading then content', (
    WidgetTester tester,
  ) async {
    final completer = Completer<InvestigationWithEnigmas?>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investigationWithEnigmasProvider(
            investigationId,
          ).overrideWith((ref) => completer.future),
        ],
        child: MaterialApp(
          home: InvestigationPlayScreen(investigationId: investigationId),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(mockData);
    await tester.pumpAndSettle();
    expect(find.text('Première énigme'), findsOneWidget);
  });

  testWidgets(
    'InvestigationPlayScreen shows error message and Retour button on load failure',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            investigationWithEnigmasProvider(investigationId).overrideWith(
              (ref) => Future<InvestigationWithEnigmas?>.error(
                Exception('Erreur réseau'),
              ),
            ),
          ],
          child: MaterialApp(
            home: InvestigationPlayScreen(investigationId: investigationId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur'), findsOneWidget);
      expect(find.text('Retour'), findsOneWidget);
    },
  );
}
