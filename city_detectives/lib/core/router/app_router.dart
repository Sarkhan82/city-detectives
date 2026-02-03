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

/// Routes (Story 1.2 + 1.3 + 2.1 + 2.2) – welcome, register, onboarding, investigations, détail, start, home.
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
  static const String home = '/home';

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
          path: home,
          builder: (context, _) => Scaffold(
            appBar: AppBar(title: const Text('City Detectives')),
            body: const Center(child: Text('Bienvenue – vous êtes connecté.')),
          ),
        ),
      ],
    );
  }
}
