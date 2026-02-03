import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/features/enigma/screens/enigma_explanation_screen.dart';
import 'package:city_detectives/features/enigma/screens/lore_screen.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/screens/investigation_detail_screen.dart';
import 'package:city_detectives/features/investigation/screens/investigation_list_screen.dart';
import 'package:city_detectives/features/investigation/screens/investigation_play_screen.dart';
import 'package:city_detectives/features/onboarding/screens/onboarding_screen.dart';
import 'package:city_detectives/features/onboarding/screens/register_screen.dart';
import 'package:city_detectives/features/onboarding/screens/welcome_screen.dart';
import 'package:city_detectives/features/profile/screens/gamification_screen.dart';
import 'package:city_detectives/features/profile/screens/progression_screen.dart';

/// Routes (Story 1.2 + 1.3 + 2.1 + 2.2 + 5.1) – welcome, register, onboarding, investigations, détail, start, progression, home.
class AppRouter {
  AppRouter._();

  static const String welcome = '/';
  static const String register = '/register';
  static const String onboarding = '/onboarding';

  /// Écran liste des enquêtes (Story 2.1).
  static const String investigations = '/investigations';

  /// Détail d'une enquête (Story 2.2) – path avec :id.
  static const String investigationDetail = '/investigations/:id';

  /// Démarrer une enquête (Story 2.2 placeholder ; Story 3.1 = écran de jeu).
  static const String investigationStart = '/investigations/:id/start';

  /// Écran Profil / Progression (Story 5.1, FR39, FR40, FR41).
  static const String progression = '/progression';

  /// Écran Gamification (Story 5.2 – badges, compétences, cartes postales, leaderboard).
  static const String gamification = '/profile/gamification';

  static const String home = '/home';

  /// Chemins avec paramètre :id (évite les routes en dur dans les écrans).
  static String investigationDetailPath(String id) => '/investigations/$id';
  static String investigationStartPath(String id) =>
      '/investigations/$id/start';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: welcome,
      routes: [
        GoRoute(path: welcome, builder: (context, _) => const WelcomeScreen()),
        GoRoute(
          path: register,
          builder: (context, _) => const RegisterScreen(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: investigations,
          builder: (context, _) => const InvestigationListScreen(),
        ),
        GoRoute(
          path: investigationDetail,
          builder: (context, state) {
            final extra = state.extra;
            final inv = extra is Investigation ? extra : null;
            if (inv == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Enquête')),
                body: const Center(child: Text('Enquête introuvable.')),
              );
            }
            return InvestigationDetailScreen(investigation: inv);
          },
        ),
        GoRoute(
          path: investigationStart,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return InvestigationPlayScreen(investigationId: id);
          },
          routes: [
            GoRoute(
              path: 'explanation',
              builder: (context, state) {
                final enigmaId = state.extra as String?;
                if (enigmaId == null || enigmaId.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Explications')),
                    body: const Center(child: Text('Paramètre manquant.')),
                  );
                }
                return EnigmaExplanationScreen(
                  enigmaId: enigmaId,
                  onContinue: () => context.pop(true),
                );
              },
            ),
            GoRoute(
              path: 'lore',
              builder: (context, state) {
                final id = state.pathParameters['id'] ?? '';
                final extra = state.extra;
                int sequenceIndex = 0;
                if (extra is int) {
                  sequenceIndex = extra;
                } else if (extra is Map<String, dynamic>) {
                  final v = extra['sequenceIndex'];
                  if (v is int) sequenceIndex = v;
                }
                if (id.isEmpty) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('Contexte')),
                    body: const Center(child: Text('Paramètre manquant.')),
                  );
                }
                return LoreScreen(
                  investigationId: id,
                  sequenceIndex: sequenceIndex,
                  onContinue: () => context.pop(true),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: progression,
          builder: (context, _) => const ProgressionScreen(),
        ),
        GoRoute(
          path: gamification,
          builder: (context, _) => const GamificationScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, _) => Scaffold(
            appBar: AppBar(title: const Text('City Detectives')),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text('Bienvenue – vous êtes connecté.'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('Ma progression'),
                  subtitle: const Text('Statut des enquêtes et historique'),
                  onTap: () {
                    if (!context.mounted) return;
                    GoRouter.of(context).push(AppRouter.progression);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Enquêtes'),
                  subtitle: const Text('Parcourir et démarrer les enquêtes'),
                  onTap: () {
                    if (!context.mounted) return;
                    GoRouter.of(context).go(AppRouter.investigations);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
