// Story 7.2 – Tests widget écran d’édition d’énigme (FR63, FR64).

import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/repositories/admin_enigma_repository.dart';
import 'package:city_detectives/features/admin/screens/enigma_edit_screen.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  const existingEnigma = Enigma(
    id: 'e1',
    orderIndex: 1,
    type: 'words',
    titre: 'Énigme existante',
    historicalExplanation: 'Explication',
    educationalContent: 'Contenu',
    historicalContentValidated: true,
  );

  testWidgets(
    'EnigmaEditScreen (create) shows basic fields and validation checkbox',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: EnigmaEditScreen(investigationId: 'inv-1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Créer une énigme'), findsOneWidget);
      expect(find.text('Titre de l’énigme'), findsOneWidget);
      expect(find.text('Ordre dans l’enquête (orderIndex)'), findsOneWidget);
      expect(
        find.text('Type (words, geolocation, photo, puzzle, …)'),
        findsOneWidget,
      );
      expect(find.text('Contenu historique validé'), findsOneWidget);
    },
  );

  testWidgets(
    'EnigmaEditScreen (edit) shows existing enigma data and validated state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EnigmaEditScreen(
              investigationId: 'inv-1',
              enigma: existingEnigma,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Éditer l’énigme'), findsOneWidget);
      expect(find.text('Énigme existante'), findsOneWidget);
      expect(find.text('Explication'), findsOneWidget);
      expect(find.text('Contenu'), findsOneWidget);
      final checkbox = find.byType(CheckboxListTile);
      expect(checkbox, findsOneWidget);
    },
  );

  testWidgets('EnigmaEditScreen (create) calls createEnigma on save', (
    WidgetTester tester,
  ) async {
    final fakeRepo = _FakeAdminEnigmaRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminEnigmaRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          home: EnigmaEditScreen(investigationId: 'inv-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText ?? '') == 'Titre de l’énigme',
      ),
      'Nouvelle énigme',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText ?? '') ==
                'Ordre dans l’enquête (orderIndex)',
      ),
      '1',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText ?? '') ==
                'Type (words, geolocation, photo, puzzle, …)',
      ),
      'words',
    );

    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(fakeRepo.createCalled, isTrue);
  });

  testWidgets('EnigmaEditScreen (edit) calls updateEnigma on save', (
    WidgetTester tester,
  ) async {
    final fakeRepo = _FakeAdminEnigmaRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminEnigmaRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          home: EnigmaEditScreen(
            investigationId: 'inv-1',
            enigma: existingEnigma,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(fakeRepo.updateCalled, isTrue);
  });
}

final GraphQLClient _fakeGraphQLClient = GraphQLClient(
  link: HttpLink('http://localhost'),
  cache: GraphQLCache(),
);

class _FakeAdminEnigmaRepository extends AdminEnigmaRepository {
  _FakeAdminEnigmaRepository() : super(_fakeGraphQLClient);

  bool createCalled = false;
  bool updateCalled = false;

  @override
  Future<Enigma> createEnigma({
    required String investigationId,
    required int orderIndex,
    required String type,
    required String titre,
    String? consigne,
    double? targetLat,
    double? targetLng,
    double? toleranceMeters,
    String? referencePhotoUrl,
    String? hintSuggestion,
    String? hintHint,
    String? hintSolution,
    String? historicalExplanation,
    String? educationalContent,
    bool? historicalContentValidated,
  }) async {
    createCalled = true;
    return Enigma(
      id: 'e-test',
      orderIndex: orderIndex,
      type: type,
      titre: titre,
      investigationId: investigationId,
      consigne: consigne,
      targetLat: targetLat,
      targetLng: targetLng,
      toleranceMeters: toleranceMeters,
      referencePhotoUrl: referencePhotoUrl,
      hintSuggestion: hintSuggestion,
      hintHint: hintHint,
      hintSolution: hintSolution,
      historicalExplanation: historicalExplanation,
      educationalContent: educationalContent,
      historicalContentValidated: historicalContentValidated,
    );
  }

  @override
  Future<Enigma> updateEnigma(
    String id, {
    int? orderIndex,
    String? type,
    String? titre,
    String? consigne,
    double? targetLat,
    double? targetLng,
    double? toleranceMeters,
    String? referencePhotoUrl,
    String? hintSuggestion,
    String? hintHint,
    String? hintSolution,
    String? historicalExplanation,
    String? educationalContent,
    bool? historicalContentValidated,
  }) async {
    updateCalled = true;
    return Enigma(
      id: id,
      orderIndex: orderIndex ?? 1,
      type: type ?? 'words',
      titre: titre ?? '',
      investigationId: null,
      consigne: consigne,
      targetLat: targetLat,
      targetLng: targetLng,
      toleranceMeters: toleranceMeters,
      referencePhotoUrl: referencePhotoUrl,
      hintSuggestion: hintSuggestion,
      hintHint: hintHint,
      hintSolution: hintSolution,
      historicalExplanation: historicalExplanation,
      educationalContent: educationalContent,
      historicalContentValidated: historicalContentValidated,
    );
  }
}
