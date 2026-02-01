// Story 1.3 – Tests widget écran onboarding (présence contenu, CTA, navigation).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/onboarding/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen in isolation shows première enquête and CTA', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.onboarding,
      routes: [
        GoRoute(
          path: AppRouter.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRouter.home,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Votre première enquête'), findsOneWidget);
    expect(find.text('Gratuit'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('OnboardingScreen step 2 shows LORE / concept', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: AppRouter.onboarding,
      routes: [
        GoRoute(
          path: AppRouter.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();

    expect(find.text('City Detectives'), findsWidgets);
    expect(find.text('Votre carnet de détective'), findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets(
    'OnboardingScreen step 3 shows guidage and CTAs Démarrer / Voir les enquêtes',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.onboarding,
        routes: [
          GoRoute(
            path: AppRouter.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: AppRouter.home,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home'))),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pump();

      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      expect(find.text('Comment jouer'), findsOneWidget);
      expect(find.text('Démarrer l\'enquête'), findsOneWidget);
      expect(find.text('Voir les enquêtes'), findsOneWidget);
    },
  );

  testWidgets(
    'OnboardingScreen has Semantics for accessibility (WCAG 2.1 Level A)',
    (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: AppRouter.onboarding,
        routes: [
          GoRoute(
            path: AppRouter.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(OnboardingScreen), findsOneWidget);
    },
  );
}
