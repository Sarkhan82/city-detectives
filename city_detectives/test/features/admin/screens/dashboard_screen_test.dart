// Story 7.1 – Tests widget écran dashboard admin (vue d'ensemble) et accès refusé.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
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
}
