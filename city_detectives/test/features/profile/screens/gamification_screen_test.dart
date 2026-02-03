// Story 5.2 – Tests widget écran gamification (badges, compétences, cartes postales, leaderboard).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/profile/models/leaderboard_entry.dart';
import 'package:city_detectives/features/profile/models/user_badge.dart';
import 'package:city_detectives/features/profile/models/user_postcard.dart';
import 'package:city_detectives/features/profile/models/user_skill.dart';
import 'package:city_detectives/features/profile/providers/badges_provider.dart';
import 'package:city_detectives/features/profile/screens/gamification_screen.dart';

void main() {
  testWidgets('GamificationScreen shows section titles', (
    WidgetTester tester,
  ) async {
    final mockBadges = [
      const UserBadge(
        badgeId: 'b1',
        code: 'first',
        label: 'Première enquête',
        description: 'Desc',
        iconRef: 'icon',
        unlockedAt: '2026-02-03T12:00:00Z',
      ),
    ];
    final mockSkills = [
      const UserSkill(
        code: 'exploration',
        label: 'Exploration',
        level: 2,
        progressPercent: 0.6,
      ),
    ];
    final mockPostcards = [
      const UserPostcard(
        id: 'p1',
        placeName: 'Place du centre',
        imageUrl: null,
        unlockedAt: '2026-02-03T12:00:00Z',
      ),
    ];
    final mockLeaderboard = [
      const LeaderboardEntry(
        rank: 1,
        userId: 'u1',
        score: 100,
        displayName: 'Détective A',
      ),
    ];

    final router = GoRouter(
      initialLocation: AppRouter.gamification,
      routes: [
        GoRoute(
          path: AppRouter.gamification,
          builder: (context, state) => const GamificationScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userBadgesProvider.overrideWith((ref) => Future.value(mockBadges)),
          userSkillsProvider.overrideWith((ref) => Future.value(mockSkills)),
          userPostcardsProvider.overrideWith(
            (ref) => Future.value(mockPostcards),
          ),
          leaderboardProvider(
            null,
          ).overrideWith((ref) => Future.value(mockLeaderboard)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GamificationScreen), findsOneWidget);
    expect(find.text('Gamification'), findsOneWidget);
    expect(find.text('Badges et accomplissements'), findsOneWidget);
    expect(find.text('Première enquête'), findsOneWidget);
    expect(find.text('Compétences'), findsOneWidget);
    expect(find.text('Exploration'), findsOneWidget);
    // Faire défiler pour rendre visibles Cartes postales et Classement (Task 6.2 – présence des 4 sections)
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Cartes postales'), findsOneWidget);
    expect(find.text('Place du centre'), findsOneWidget);
    expect(find.text('Classement'), findsOneWidget);
  });

  testWidgets('GamificationScreen has semantics for accessibility', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userBadgesProvider.overrideWith((ref) => Future.value(<UserBadge>[])),
          userSkillsProvider.overrideWith((ref) => Future.value(<UserSkill>[])),
          userPostcardsProvider.overrideWith(
            (ref) => Future.value(<UserPostcard>[]),
          ),
          leaderboardProvider(
            null,
          ).overrideWith((ref) => Future.value(<LeaderboardEntry>[])),
        ],
        child: MaterialApp(home: Scaffold(body: const GamificationScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GamificationScreen), findsOneWidget);
    expect(find.text('Badges et accomplissements'), findsOneWidget);
    final semantics = find.bySemanticsLabel(
      'Gamification – badges, compétences, cartes postales et classement',
    );
    expect(semantics, findsOneWidget);
  });
}
