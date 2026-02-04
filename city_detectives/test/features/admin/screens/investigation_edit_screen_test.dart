// Story 7.2 – Tests widget écran d’édition d’enquête (FR62).

import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/repositories/admin_investigation_repository.dart';
import 'package:city_detectives/features/admin/screens/investigation_edit_screen.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  const existing = Investigation(
    id: 'inv-1',
    titre: 'Enquête existante',
    description: 'Description existante',
    durationEstimate: 45,
    difficulte: 'moyen',
    isFree: true,
    status: 'draft',
  );

  testWidgets('InvestigationEditScreen (create) shows basic form fields', (
    WidgetTester tester,
  ) async {
    final fakeRepo = _FakeAdminInvestigationRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminInvestigationRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(home: InvestigationEditScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Créer une enquête'), findsOneWidget);
    expect(
      find.byType(TextField),
      findsNWidgets(4),
    ); // titre, desc, durée, diff
    expect(find.text('Titre de l’enquête'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Durée estimée (minutes)'), findsOneWidget);
    expect(
      find.text('Difficulté (facile / moyen / difficile)'),
      findsOneWidget,
    );
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets(
    'InvestigationEditScreen (edit) shows existing investigation data',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: InvestigationEditScreen(investigation: existing),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Éditer l’enquête'), findsOneWidget);
      expect(find.text('Enquête existante'), findsOneWidget);
      expect(find.text('Description existante'), findsOneWidget);
      expect(find.text('moyen'), findsOneWidget);
    },
  );

  testWidgets(
    'InvestigationEditScreen (create) calls createInvestigation on save',
    (WidgetTester tester) async {
      final fakeRepo = _FakeAdminInvestigationRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminInvestigationRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: InvestigationEditScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.labelText ?? '') == 'Titre de l’enquête',
        ),
        'Nouvelle enquête',
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.labelText ?? '') == 'Description',
        ),
        'Description test',
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.labelText ?? '') == 'Durée estimée (minutes)',
        ),
        '30',
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.labelText ?? '') ==
                  'Difficulté (facile / moyen / difficile)',
        ),
        'facile',
      );

      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(fakeRepo.createCalled, isTrue);
    },
  );
}

final GraphQLClient _fakeGraphQLClient = GraphQLClient(
  link: HttpLink('http://localhost'),
  cache: GraphQLCache(),
);

class _FakeAdminInvestigationRepository extends AdminInvestigationRepository {
  _FakeAdminInvestigationRepository() : super(_fakeGraphQLClient);

  bool createCalled = false;

  @override
  Future<Investigation> createInvestigation({
    required String titre,
    required String description,
    required int durationEstimate,
    required String difficulte,
    required bool isFree,
    int? priceAmount,
    String? priceCurrency,
    double? centerLat,
    double? centerLng,
    String status = 'draft',
  }) async {
    createCalled = true;
    return Investigation(
      id: 'test',
      titre: titre,
      description: description,
      durationEstimate: durationEstimate,
      difficulte: difficulte,
      isFree: isFree,
      priceAmount: priceAmount,
      priceCurrency: priceCurrency,
      centerLat: centerLat,
      centerLng: centerLng,
      status: status,
    );
  }
}
