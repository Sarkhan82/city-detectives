// Story 2.1 + 2.2 – Tests widget écran liste enquêtes (liste, durée, difficulté, description, Gratuit/Payant, tap → navigation).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_progress.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';
import 'package:city_detectives/features/investigation/screens/investigation_list_screen.dart';

/// Notifier factice pour tests – retourne une liste fixe sans appeler l'API.
class FakeInvestigationListNotifier extends InvestigationListNotifier {
  FakeInvestigationListNotifier(this._data);

  final List<Investigation> _data;

  @override
  Future<List<Investigation>> build() async => _data;
}

/// Notifier factice qui simule une erreur (pour tester l'affichage erreur).
class FakeErrorInvestigationListNotifier extends InvestigationListNotifier {
  FakeErrorInvestigationListNotifier(this.message);

  final String message;

  @override
  Future<List<Investigation>> build() async => throw Exception(message);
}

void main() {
  testWidgets(
    'InvestigationListScreen shows list with duration, difficulty, description',
    (WidgetTester tester) async {
      final mockList = [
        const Investigation(
          id: 'id-1',
          titre: 'Le mystère du parc',
          description: 'Une enquête familiale dans le parc central.',
          durationEstimate: 45,
          difficulte: 'facile',
          isFree: true,
        ),
      ];
      final router = GoRouter(
        initialLocation: AppRouter.investigations,
        routes: [
          GoRoute(
            path: AppRouter.investigations,
            builder: (context, state) => const InvestigationListScreen(),
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
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InvestigationListScreen), findsOneWidget);
      expect(find.text('Enquêtes'), findsOneWidget);
      expect(find.text('Le mystère du parc'), findsOneWidget);
      expect(
        find.text('Une enquête familiale dans le parc central.'),
        findsOneWidget,
      );
      expect(find.text('~45 min'), findsOneWidget);
      expect(find.text('facile'), findsOneWidget);
      expect(find.text('Gratuit'), findsOneWidget);
    },
  );

  testWidgets(
    'InvestigationListScreen shows Payant when isFree is false (Story 2.2)',
    (WidgetTester tester) async {
      final mockList = [
        const Investigation(
          id: 'id-paid',
          titre: 'Enquête premium',
          description: 'Enquête payante.',
          durationEstimate: 60,
          difficulte: 'moyen',
          isFree: false,
        ),
      ];
      final router = GoRouter(
        initialLocation: AppRouter.investigations,
        routes: [
          GoRoute(
            path: AppRouter.investigations,
            builder: (context, state) => const InvestigationListScreen(),
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
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Payant'), findsOneWidget);
      expect(find.text('Gratuit'), findsNothing);
    },
  );

  testWidgets(
    'InvestigationListScreen shows price for paid investigation (Story 6.1 FR47, FR49)',
    (WidgetTester tester) async {
      final mockList = [
        const Investigation(
          id: 'id-paid',
          titre: 'Enquête premium',
          description: 'Enquête payante.',
          durationEstimate: 60,
          difficulte: 'moyen',
          isFree: false,
          priceAmount: 299,
          priceCurrency: 'EUR',
        ),
      ];
      final router = GoRouter(
        initialLocation: AppRouter.investigations,
        routes: [
          GoRoute(
            path: AppRouter.investigations,
            builder: (context, state) => const InvestigationListScreen(),
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
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2,99 €'), findsOneWidget);
      expect(find.text('Payant'), findsOneWidget);
    },
  );

  testWidgets(
    'InvestigationListScreen tap on item navigates to detail (Story 2.2)',
    (WidgetTester tester) async {
      final mockList = [
        const Investigation(
          id: 'id-1',
          titre: 'Le mystère du parc',
          description: 'Une enquête familiale.',
          durationEstimate: 45,
          difficulte: 'facile',
          isFree: true,
        ),
      ];
      final router = AppRouter.createRouter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            investigationListProvider.overrideWith(
              () => FakeInvestigationListNotifier(mockList),
            ),
            investigationProgressRepositoryProvider.overrideWith(
              (_) => InvestigationProgressRepository.forTest(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      router.go(AppRouter.investigations);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Le mystère du parc'));
      await tester.pumpAndSettle();

      expect(find.text('Démarrer l\'enquête'), findsOneWidget);
      expect(find.text('Une enquête familiale.'), findsOneWidget);
    },
  );

  testWidgets('InvestigationListScreen shows empty state when list is empty', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.investigations,
      routes: [
        GoRoute(
          path: AppRouter.investigations,
          builder: (context, state) => const InvestigationListScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investigationListProvider.overrideWith(
            () => FakeInvestigationListNotifier([]),
          ),
          investigationProgressRepositoryProvider.overrideWith(
            (_) => InvestigationProgressRepository.forTest(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Aucune enquête disponible pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('InvestigationListScreen shows user-friendly error message', (
    WidgetTester tester,
  ) async {
    const errorMessage = 'Erreur réseau';
    final router = GoRouter(
      initialLocation: AppRouter.investigations,
      routes: [
        GoRoute(
          path: AppRouter.investigations,
          builder: (context, state) => const InvestigationListScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          investigationListProvider.overrideWith(
            () => FakeErrorInvestigationListNotifier(errorMessage),
          ),
          investigationProgressRepositoryProvider.overrideWith(
            (_) => InvestigationProgressRepository.forTest(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InvestigationListScreen), findsOneWidget);
    expect(find.text(errorMessage), findsOneWidget);
  });

  // Story 3.3 – Enquêtes en cours et reprise
  testWidgets(
    'InvestigationListScreen shows Enquêtes en cours section when progress exists',
    (WidgetTester tester) async {
      final mockList = [
        const Investigation(
          id: 'inv-1',
          titre: 'Le mystère du parc',
          description: 'Une enquête.',
          durationEstimate: 45,
          difficulte: 'facile',
          isFree: true,
        ),
      ];
      final progressRepo = InvestigationProgressRepository.forTest();
      await progressRepo.saveProgress(
        InvestigationProgress(
          investigationId: 'inv-1',
          currentEnigmaIndex: 1,
          completedEnigmaIds: ['e1'],
          updatedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final router = GoRouter(
        initialLocation: AppRouter.investigations,
        routes: [
          GoRoute(
            path: AppRouter.investigations,
            builder: (context, state) => const InvestigationListScreen(),
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
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enquêtes en cours'), findsOneWidget);
      expect(find.text('Reprendre'), findsOneWidget);
      expect(find.text('Le mystère du parc'), findsWidgets);
    },
  );
}
