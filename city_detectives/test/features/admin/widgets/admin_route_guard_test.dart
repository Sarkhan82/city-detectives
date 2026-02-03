// Story 7.1 – Test de la garde admin : redirection vers home si l'utilisateur n'est pas admin.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/repositories/user_repository.dart';
import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/widgets/admin_route_guard.dart';

void main() {
  testWidgets('AdminRouteGuard redirects to home when user is not admin', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const AdminRouteGuard(),
        ),
        GoRoute(
          path: AppRouter.home,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => Future.value(null),
            // null = non connecté → pas admin
          ),
          adminDashboardProvider.overrideWith(
            (ref) => Future.value(
              const DashboardOverview(
                investigationCount: 0,
                publishedCount: 0,
                draftCount: 0,
                enigmaCount: 0,
              ),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Dashboard admin'), findsNothing);
  });

  testWidgets('AdminRouteGuard shows dashboard when user is admin', (
    WidgetTester tester,
  ) async {
    const overview = DashboardOverview(
      investigationCount: 2,
      publishedCount: 2,
      draftCount: 0,
      enigmaCount: 5,
    );
    final router = GoRouter(
      initialLocation: AppRouter.adminDashboard,
      routes: [
        GoRoute(
          path: AppRouter.adminDashboard,
          builder: (context, state) => const AdminRouteGuard(),
        ),
        GoRoute(
          path: AppRouter.home,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) =>
                Future.value(const CurrentUser(id: 'admin-1', isAdmin: true)),
          ),
          adminDashboardProvider.overrideWith((ref) => Future.value(overview)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard admin'), findsOneWidget);
    expect(find.text('Vue d\'ensemble'), findsOneWidget);
  });
}
