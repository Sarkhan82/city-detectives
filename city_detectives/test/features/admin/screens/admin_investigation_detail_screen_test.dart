// Story 7.3 – Tests widget détail enquête admin : boutons Prévisualiser, Publier, Rollback, confirmation (FR65, FR66, FR67).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/admin/screens/admin_investigation_detail_screen.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';

void main() {
  const draftInv = Investigation(
    id: 'inv-draft',
    titre: 'Enquête brouillon',
    description: 'Description brouillon.',
    durationEstimate: 30,
    difficulte: 'facile',
    isFree: true,
    status: 'draft',
  );

  const publishedInv = Investigation(
    id: 'inv-published',
    titre: 'Enquête publiée',
    description: 'Description publiée.',
    durationEstimate: 45,
    difficulte: 'moyen',
    isFree: false,
    status: 'published',
  );

  testWidgets(
    'AdminInvestigationDetailScreen shows Prévisualiser and Publier when draft',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminInvestigationDetailScreen(investigation: draftInv),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enquête brouillon'), findsOneWidget);
      expect(find.text('Description brouillon.'), findsOneWidget);
      expect(find.text('Statut : Brouillon'), findsOneWidget);
      expect(find.text('Prévisualiser'), findsOneWidget);
      expect(find.text('Publier'), findsOneWidget);
      expect(find.text('Rollback'), findsNothing);
    },
  );

  testWidgets(
    'AdminInvestigationDetailScreen shows Prévisualiser and Rollback when published',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminInvestigationDetailScreen(investigation: publishedInv),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enquête publiée'), findsOneWidget);
      expect(find.text('Statut : Publiée'), findsOneWidget);
      expect(find.text('Prévisualiser'), findsOneWidget);
      expect(find.text('Rollback'), findsOneWidget);
      expect(find.text('Publier'), findsNothing);
    },
  );

  testWidgets(
    'AdminInvestigationDetailScreen Rollback shows confirmation dialog',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminInvestigationDetailScreen(investigation: publishedInv),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rollback'));
      await tester.pumpAndSettle();

      expect(find.text('Dépublier l\'enquête ?'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Dépublier'), findsOneWidget);
    },
  );
}
