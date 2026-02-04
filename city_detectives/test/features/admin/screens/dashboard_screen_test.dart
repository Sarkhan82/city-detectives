// Story 7.1, 7.4 – Tests widget écran dashboard admin (vue d'ensemble, métriques, analytics, parcours) et accès refusé.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/models/completion_rate_entry.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/models/technical_metrics.dart';
import 'package:city_detectives/features/admin/models/user_analytics.dart';
import 'package:city_detectives/features/admin/models/user_journey_analytics.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/repositories/dashboard_repository.dart';
import 'package:city_detectives/features/admin/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen shows overview when data loaded', (
    WidgetTester tester,
  ) async {
    const overview = DashboardOverview(
      investigationCount: 5,
      publishedCount: 4,
      draftCount: 1,
      enigmaCount: 12,
    );
    const technicalMetrics = TechnicalMetrics(
      healthStatus: 'ok',
      apiLatencyAvgMs: null,
      apiLatencyP95Ms: null,
      errorRate: 0.0,
      crashCount: 0,
      sentryDashboardUrl: null,
    );
    const userAnalytics = UserAnalytics(
      activeUserCount: 10,
      totalCompletions: 7,
    );
    const completionRates = <CompletionRateEntry>[
      CompletionRateEntry(
        investigationId: 'inv-1',
        investigationTitle: 'Enquête 1',
        startedCount: 5,
        completedCount: 3,
        completionRate: 0.6,
      ),
    ];
    const userJourney = UserJourneyAnalytics(
      funnelSteps: [
        JourneyStep(label: 'Enquête démarrée', userCount: 8),
        JourneyStep(label: 'Enquête complétée', userCount: 4),
      ],
    );

    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardProvider.overrideWith((ref) => Future.value(overview)),
          adminTechnicalMetricsProvider.overrideWith(
            (ref) => Future.value(technicalMetrics),
          ),
          adminUserAnalyticsProvider.overrideWith(
            (ref) => Future.value(userAnalytics),
          ),
          adminCompletionRatesProvider.overrideWith(
            (ref) => Future.value(completionRates),
          ),
          adminUserJourneyAnalyticsProvider.overrideWith(
            (ref) => Future.value(userJourney),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard admin'), findsOneWidget);
    expect(find.text('Vue d\'ensemble'), findsOneWidget);
    expect(find.text('5'), findsWidgets);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Enquêtes (total)'), findsOneWidget);
    expect(find.text('Énigmes'), findsOneWidget);
  });

  testWidgets(
    'DashboardScreen shows technical metrics and analytics sections (Story 7.4)',
    (WidgetTester tester) async {
      const overview = DashboardOverview(
        investigationCount: 2,
        publishedCount: 1,
        draftCount: 1,
        enigmaCount: 4,
      );
      const technicalMetrics = TechnicalMetrics(
        healthStatus: 'ok',
        apiLatencyAvgMs: 120.0,
        apiLatencyP95Ms: null,
        errorRate: 0.01,
        crashCount: 2,
        sentryDashboardUrl: null,
      );
      const userAnalytics = UserAnalytics(
        activeUserCount: 15,
        totalCompletions: 9,
      );
      const completionRates = <CompletionRateEntry>[];
      const userJourney = UserJourneyAnalytics(
        funnelSteps: [
          JourneyStep(label: 'Enquête démarrée', userCount: 12),
          JourneyStep(label: 'Enquête complétée', userCount: 9),
        ],
      );

      final router = GoRouter(
        initialLocation: AppRouter.adminDashboard,
        routes: [
          GoRoute(
            path: AppRouter.adminDashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminDashboardProvider.overrideWith(
              (ref) => Future.value(overview),
            ),
            adminTechnicalMetricsProvider.overrideWith(
              (ref) => Future.value(technicalMetrics),
            ),
            adminUserAnalyticsProvider.overrideWith(
              (ref) => Future.value(userAnalytics),
            ),
            adminCompletionRatesProvider.overrideWith(
              (ref) => Future.value(completionRates),
            ),
            adminUserJourneyAnalyticsProvider.overrideWith(
              (ref) => Future.value(userJourney),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Métriques techniques'), findsOneWidget);
      expect(find.text('Santé'), findsOneWidget);
      expect(find.text('ok'), findsOneWidget);
      expect(find.text('Crashs récents'), findsOneWidget);
      expect(find.text('2'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Analytics utilisateurs'),
        500,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Analytics utilisateurs'), findsOneWidget);
      expect(find.text('Utilisateurs actifs'), findsOneWidget);
      expect(find.text('15'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Taux de complétion'),
        500,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Taux de complétion'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Parcours utilisateur'),
        500,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Parcours utilisateur'), findsOneWidget);
      expect(find.text('Enquête démarrée'), findsOneWidget);
      expect(find.text('Enquête complétée'), findsOneWidget);
    },
  );

  testWidgets('DashboardScreen shows access denied for non-admin (403)', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardProvider.overrideWith(
            (ref) => Future.error(
              DashboardForbiddenException('Accès réservé aux administrateurs.'),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accès réservé aux administrateurs.'), findsOneWidget);
    expect(find.text('Retour à l\'accueil'), findsOneWidget);
  });

  testWidgets('DashboardScreen shows error card when technical metrics fail', (
    WidgetTester tester,
  ) async {
    const overview = DashboardOverview(
      investigationCount: 1,
      publishedCount: 1,
      draftCount: 0,
      enigmaCount: 1,
    );
    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardProvider.overrideWith((ref) => Future.value(overview)),
          adminTechnicalMetricsProvider.overrideWith(
            (ref) => Future.error(Exception('Erreur techniques')),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de charger les métriques techniques.'),
      findsOneWidget,
    );
  });

  testWidgets('DashboardScreen shows error card when user analytics fail', (
    WidgetTester tester,
  ) async {
    const overview = DashboardOverview(
      investigationCount: 1,
      publishedCount: 1,
      draftCount: 0,
      enigmaCount: 1,
    );
    const technicalMetrics = TechnicalMetrics(
      healthStatus: 'ok',
      apiLatencyAvgMs: null,
      apiLatencyP95Ms: null,
      errorRate: 0.0,
      crashCount: 0,
      sentryDashboardUrl: null,
    );
    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardProvider.overrideWith((ref) => Future.value(overview)),
          adminTechnicalMetricsProvider.overrideWith(
            (ref) => Future.value(technicalMetrics),
          ),
          adminUserAnalyticsProvider.overrideWith(
            (ref) => Future.error(Exception('Erreur analytics')),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Analytics utilisateurs'),
      500,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Impossible de charger les analytics.'), findsOneWidget);
  });

  testWidgets('DashboardScreen shows error card when completion rates fail', (
    WidgetTester tester,
  ) async {
    const overview = DashboardOverview(
      investigationCount: 1,
      publishedCount: 1,
      draftCount: 0,
      enigmaCount: 1,
    );
    const technicalMetrics = TechnicalMetrics(
      healthStatus: 'ok',
      apiLatencyAvgMs: null,
      apiLatencyP95Ms: null,
      errorRate: 0.0,
      crashCount: 0,
      sentryDashboardUrl: null,
    );
    const userAnalytics = UserAnalytics(
      activeUserCount: 1,
      totalCompletions: 0,
    );
    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminDashboardProvider.overrideWith((ref) => Future.value(overview)),
          adminTechnicalMetricsProvider.overrideWith(
            (ref) => Future.value(technicalMetrics),
          ),
          adminUserAnalyticsProvider.overrideWith(
            (ref) => Future.value(userAnalytics),
          ),
          adminCompletionRatesProvider.overrideWith(
            (ref) => Future.error(Exception('Erreur taux')),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Taux de complétion'),
      500,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text('Impossible de charger les taux de complétion.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'DashboardScreen shows error card when user journey analytics fail',
    (WidgetTester tester) async {
      const overview = DashboardOverview(
        investigationCount: 1,
        publishedCount: 1,
        draftCount: 0,
        enigmaCount: 1,
      );
      const technicalMetrics = TechnicalMetrics(
        healthStatus: 'ok',
        apiLatencyAvgMs: null,
        apiLatencyP95Ms: null,
        errorRate: 0.0,
        crashCount: 0,
        sentryDashboardUrl: null,
      );
      const userAnalytics = UserAnalytics(
        activeUserCount: 1,
        totalCompletions: 1,
      );
      const completionRates = <CompletionRateEntry>[
        CompletionRateEntry(
          investigationId: 'inv-1',
          investigationTitle: 'Enquête 1',
          startedCount: 1,
          completedCount: 1,
          completionRate: 1.0,
        ),
      ];
      final router = GoRouter(
        initialLocation: AppRouter.adminDashboard,
        routes: [
          GoRoute(
            path: AppRouter.adminDashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminDashboardProvider.overrideWith(
              (ref) => Future.value(overview),
            ),
            adminTechnicalMetricsProvider.overrideWith(
              (ref) => Future.value(technicalMetrics),
            ),
            adminUserAnalyticsProvider.overrideWith(
              (ref) => Future.value(userAnalytics),
            ),
            adminCompletionRatesProvider.overrideWith(
              (ref) => Future.value(completionRates),
            ),
            adminUserJourneyAnalyticsProvider.overrideWith(
              (ref) => Future.error(Exception('Erreur parcours')),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final verticalScrollable = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      );
      await tester.scrollUntilVisible(
        find.text('Parcours utilisateur'),
        500,
        scrollable: verticalScrollable,
      );
      await tester.pumpAndSettle();
      expect(find.text('Impossible de charger le parcours.'), findsOneWidget);
    },
  );
}
