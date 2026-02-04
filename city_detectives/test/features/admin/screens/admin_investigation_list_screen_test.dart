// Story 7.3 – Tests widget liste des enquêtes admin. Brouillon / Publiée, navigation (provider mocké).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/screens/admin_investigation_list_screen.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';

void main() {
  final mockList = [
    const Investigation(
      id: 'inv-draft',
      titre: 'Brouillon test',
      description: 'Desc',
      durationEstimate: 20,
      difficulte: 'moyen',
      isFree: true,
      status: 'draft',
    ),
    const Investigation(
      id: 'inv-published',
      titre: 'Publiée test',
      description: 'Desc',
      durationEstimate: 45,
      difficulte: 'facile',
      isFree: false,
      status: 'published',
    ),
  ];

  testWidgets(
    'AdminInvestigationListScreen shows list with draft and published labels',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.adminInvestigationListPath(),
        routes: [
          GoRoute(
            path: AppRouter.adminInvestigationListPath(),
            builder: (_, __) => const AdminInvestigationListScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminInvestigationListProvider.overrideWith(
              (ref) => Future.value(mockList),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enquêtes (admin)'), findsOneWidget);
      expect(find.text('Brouillon test'), findsOneWidget);
      expect(find.text('Publiée test'), findsOneWidget);
      expect(find.text('Brouillon'), findsOneWidget);
      expect(find.text('Publiée'), findsOneWidget);
    },
  );

  testWidgets('AdminInvestigationListScreen shows empty when list is empty', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.adminInvestigationListPath(),
      routes: [
        GoRoute(
          path: AppRouter.adminInvestigationListPath(),
          builder: (_, __) => const AdminInvestigationListScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminInvestigationListProvider.overrideWith(
            (ref) => Future.value([]),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucune enquête.'), findsOneWidget);
  });
}
