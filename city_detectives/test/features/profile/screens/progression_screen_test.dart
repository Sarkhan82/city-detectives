// Story 5.1 – Tests widget écran progression (statut par enquête, progression globale, historique).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';
import 'package:city_detectives/features/investigation/repositories/completed_investigation_repository.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';
import 'package:city_detectives/features/profile/screens/progression_screen.dart';

class FakeInvestigationListNotifier extends InvestigationListNotifier {
  FakeInvestigationListNotifier(this._data);

  final List<Investigation> _data;

  @override
  Future<List<Investigation>> build() async => _data;
}

void main() {
  testWidgets('ProgressionScreen shows global progress and status section', (
    WidgetTester tester,
  ) async {
    final mockList = [
      const Investigation(
        id: 'inv-1',
        titre: 'Enquête A',
        description: 'Description A',
        durationEstimate: 30,
        difficulte: 'facile',
        isFree: true,
      ),
      const Investigation(
        id: 'inv-2',
        titre: 'Enquête B',
        description: 'Description B',
        durationEstimate: 45,
        difficulte: 'moyen',
        isFree: false,
      ),
    ];
    final progressRepo = InvestigationProgressRepository.forTest();
    final completedRepo = CompletedInvestigationRepository.forTest();

    final router = GoRouter(
      initialLocation: AppRouter.progression,
      routes: [
        GoRoute(
          path: AppRouter.progression,
          builder: (context, state) => const ProgressionScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investigationListProvider.overrideWith(
            () => FakeInvestigationListNotifier(mockList),
          ),
          investigationProgressRepositoryProvider.overrideWith(
            (_) => progressRepo,
          ),
          completedInvestigationRepositoryProvider.overrideWith(
            (_) => completedRepo,
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProgressionScreen), findsOneWidget);
    expect(find.text('Ma progression'), findsOneWidget);
    expect(find.text('Statut par enquête'), findsOneWidget);
    expect(find.text('Enquêtes complétées'), findsOneWidget);
    expect(find.text('Enquête A'), findsOneWidget);
    expect(find.text('Enquête B'), findsOneWidget);
    expect(find.textContaining('0 / 2'), findsOneWidget);
  });

  testWidgets(
    'ProgressionScreen shows completed count and history when one completed',
    (WidgetTester tester) async {
      final mockList = [
        const Investigation(
          id: 'inv-1',
          titre: 'Le parc mystérieux',
          description: 'Desc',
          durationEstimate: 30,
          difficulte: 'facile',
          isFree: true,
        ),
      ];
      final progressRepo = InvestigationProgressRepository.forTest();
      final completedRepo = CompletedInvestigationRepository.forTest();
      await completedRepo.markCompleted('inv-1');

      final router = GoRouter(
        initialLocation: AppRouter.progression,
        routes: [
          GoRoute(
            path: AppRouter.progression,
            builder: (context, state) => const ProgressionScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            investigationListProvider.overrideWith(
              () => FakeInvestigationListNotifier(mockList),
            ),
            investigationProgressRepositoryProvider.overrideWith(
              (_) => progressRepo,
            ),
            completedInvestigationRepositoryProvider.overrideWith(
              (_) => completedRepo,
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('1 / 1'), findsOneWidget);
      expect(find.text('Le parc mystérieux'), findsAtLeastNWidgets(1));
      expect(find.text('Complétée'), findsOneWidget);
    },
  );

  testWidgets('ProgressionScreen has semantics for accessibility', (
    WidgetTester tester,
  ) async {
    final mockList = [
      const Investigation(
        id: 'inv-1',
        titre: 'Test',
        description: 'D',
        durationEstimate: 10,
        difficulte: 'facile',
        isFree: true,
      ),
    ];
    final router = GoRouter(
      initialLocation: AppRouter.progression,
      routes: [
        GoRoute(
          path: AppRouter.progression,
          builder: (context, state) => const ProgressionScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investigationListProvider.overrideWith(
            () => FakeInvestigationListNotifier(mockList),
          ),
          investigationProgressRepositoryProvider.overrideWith(
            (_) => InvestigationProgressRepository.forTest(),
          ),
          completedInvestigationRepositoryProvider.overrideWith(
            (_) => CompletedInvestigationRepository.forTest(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel(
        'Progression – statut des enquêtes, progression globale et historique',
      ),
      findsOneWidget,
    );
  });
}
