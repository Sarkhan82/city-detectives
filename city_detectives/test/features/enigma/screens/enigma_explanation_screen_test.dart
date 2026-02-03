// Story 4.3 – Tests écran Explications : affichage historique et éducatif après résolution (API mockée).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';
import 'package:city_detectives/features/enigma/screens/enigma_explanation_screen.dart';

void main() {
  Widget wrapWithProviders(Widget child, EnigmaValidationRepository repo) {
    return ProviderScope(
      overrides: [
        enigmaValidationRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('EnigmaExplanationScreen shows loading then content', (
    WidgetTester tester,
  ) async {
    final fake = _FakeExplanationRepository();
    await tester.pumpWidget(
      wrapWithProviders(
        EnigmaExplanationScreen(enigmaId: 'test-id', onContinue: () {}),
        fake,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Explications'), findsOneWidget);
    expect(find.text('Contexte historique'), findsOneWidget);
    expect(find.text('Texte historique mock.'), findsOneWidget);
    expect(find.text('Pour en savoir plus'), findsOneWidget);
    expect(find.text('Contenu éducatif mock.'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('EnigmaExplanationScreen Continuer calls onContinue', (
    WidgetTester tester,
  ) async {
    var continueCalled = false;
    final fake = _FakeExplanationRepository();
    await tester.pumpWidget(
      wrapWithProviders(
        EnigmaExplanationScreen(
          enigmaId: 'test-id',
          onContinue: () => continueCalled = true,
        ),
        fake,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(continueCalled, isTrue);
  });
}

class _FakeExplanationRepository extends EnigmaValidationRepository {
  _FakeExplanationRepository()
    : super(
        GraphQLClient(
          cache: GraphQLCache(store: InMemoryStore()),
          link: HttpLink('http://localhost:8080/graphql'),
        ),
      );

  @override
  Future<EnigmaHints> getEnigmaHints({required String enigmaId}) async {
    return const EnigmaHints(suggestion: '', hint: '', solution: '');
  }

  @override
  Future<EnigmaExplanation> getEnigmaExplanation({
    required String enigmaId,
  }) async {
    return const EnigmaExplanation(
      historicalExplanation: 'Texte historique mock.',
      educationalContent: 'Contenu éducatif mock.',
    );
  }
}
