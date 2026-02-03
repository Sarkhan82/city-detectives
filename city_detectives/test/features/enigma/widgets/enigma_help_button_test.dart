// Story 4.3 – Tests widget bouton Aide : affichage, ouverture du panneau d'indices (API mockée).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';
import 'package:city_detectives/features/enigma/widgets/enigma_help_button.dart';

void main() {
  Widget wrapWithProviders(Widget child, EnigmaValidationRepository repo) {
    return ProviderScope(
      overrides: [
        enigmaValidationRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('EnigmaHelpButton shows help icon', (WidgetTester tester) async {
    final fake = _FakeHintsRepository();
    await tester.pumpWidget(
      wrapWithProviders(EnigmaHelpButton(enigmaId: 'test-id'), fake),
    );

    expect(find.byIcon(Icons.help_outline), findsOneWidget);
  });

  testWidgets('EnigmaHelpButton tap opens bottom sheet with hints panel', (
    WidgetTester tester,
  ) async {
    final fake = _FakeHintsRepository();
    await tester.pumpWidget(
      wrapWithProviders(EnigmaHelpButton(enigmaId: 'test-id'), fake),
    );

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Indice 1'), findsOneWidget);
    expect(find.text('Une suggestion légère.'), findsOneWidget);
    expect(find.text('Voir l\'indice suivant'), findsOneWidget);
  });

  testWidgets('EnigmaHelpButton full flow suggestion then hint then solution', (
    WidgetTester tester,
  ) async {
    final fake = _FakeHintsRepository();
    await tester.pumpWidget(
      wrapWithProviders(EnigmaHelpButton(enigmaId: 'test-id'), fake),
    );

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Indice 1'), findsOneWidget);
    expect(find.text('Une suggestion légère.'), findsOneWidget);

    await tester.tap(find.text('Voir l\'indice suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Indice 2'), findsOneWidget);
    expect(find.text('Un indice plus direct.'), findsOneWidget);

    await tester.tap(find.text('Voir l\'indice suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Solution'), findsOneWidget);
    expect(find.text('La solution.'), findsOneWidget);
    expect(find.text('Fermer'), findsOneWidget);
  });
}

class _FakeHintsRepository extends EnigmaValidationRepository {
  _FakeHintsRepository()
    : super(
        GraphQLClient(
          cache: GraphQLCache(store: InMemoryStore()),
          link: HttpLink('http://localhost:8080/graphql'),
        ),
      );

  @override
  Future<EnigmaHints> getEnigmaHints({required String enigmaId}) async {
    return const EnigmaHints(
      suggestion: 'Une suggestion légère.',
      hint: 'Un indice plus direct.',
      solution: 'La solution.',
    );
  }

  @override
  Future<EnigmaExplanation> getEnigmaExplanation({
    required String enigmaId,
  }) async {
    return const EnigmaExplanation(
      historicalExplanation: 'Contexte historique.',
      educationalContent: 'Contenu éducatif.',
    );
  }
}
