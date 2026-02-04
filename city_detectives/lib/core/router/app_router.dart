import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/screens/home_screen.dart';
import 'package:city_detectives/features/admin/screens/admin_investigation_detail_screen.dart';
import 'package:city_detectives/features/admin/screens/admin_investigation_list_screen.dart';
import 'package:city_detectives/features/admin/screens/dashboard_screen.dart';
import 'package:city_detectives/features/admin/screens/investigation_preview_screen.dart';
import 'package:city_detectives/features/admin/widgets/admin_route_guard.dart';
import 'package:city_detectives/features/admin/screens/enigma_edit_screen.dart';
import 'package:city_detectives/features/admin/screens/investigation_edit_screen.dart';
import 'package:city_detectives/features/enigma/screens/enigma_explanation_screen.dart';
import 'package:city_detectives/features/enigma/screens/lore_screen.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/screens/investigation_detail_screen.dart';
import 'package:city_detectives/features/investigation/screens/investigation_list_screen.dart';
import 'package:city_detectives/features/investigation/screens/investigation_play_screen.dart';
import 'package:city_detectives/features/investigation/screens/purchase_simulation_screen.dart';
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

  /// Simulation achat (Story 6.2 – FR53).
  static const String investigationPurchase = '/investigations/:id/purchase';

  /// Écran Profil / Progression (Story 5.1, FR39, FR40, FR41).
  static const String progression = '/progression';

  /// Écran Gamification (Story 5.2 – badges, compétences, cartes postales, leaderboard).
  static const String gamification = '/profile/gamification';

  /// Dashboard admin (Story 7.1 – FR61). Accès réservé aux admins.
  static const String adminDashboard = '/admin/dashboard';

  /// Liste des enquêtes admin (Story 7.3 – prévisualisation, publication, rollback).
  static const String adminInvestigationList = '/admin/investigations';
  static const String adminInvestigationDetail = '/admin/investigations/:id';
  static const String adminInvestigationPreview =
      '/admin/investigations/:id/preview';
  static const String adminInvestigationCreate = '/admin/investigations/new';
  static const String adminInvestigationEdit = '/admin/investigations/:id/edit';
  static const String adminEnigmaEdit =
      '/admin/investigations/:id/enigmas/:enigmaId/edit';

  static const String home = '/home';

  /// Chemins avec paramètre :id (évite les routes en dur dans les écrans).
  static String investigationDetailPath(String id) => '/investigations/$id';
  static String investigationStartPath(String id) =>
      '/investigations/$id/start';
  static String investigationPurchasePath(String id) =>
      '/investigations/$id/purchase';

  static String adminInvestigationListPath() => adminInvestigationList;
  static String adminInvestigationDetailPath(String id) =>
      '/admin/investigations/$id';
  static String adminInvestigationPreviewPath(String id) =>
      '/admin/investigations/$id/preview';
  static String adminInvestigationCreatePath() => adminInvestigationCreate;
  static String adminInvestigationEditPath(String id) =>
      '/admin/investigations/$id/edit';
  static String adminEnigmaEditPath(String investigationId, String enigmaId) =>
      '/admin/investigations/$investigationId/enigmas/$enigmaId/edit';

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
          path: investigationPurchase,
          builder: (context, state) {
            final extra = state.extra;
            final inv = extra is Investigation ? extra : null;
            if (inv == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Achat')),
                body: const Center(child: Text('Enquête introuvable.')),
              );
            }
            return PurchaseSimulationScreen(investigation: inv);
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
        ShellRoute(
          builder: (context, state, child) => AdminRouteGuard(child: child),
          routes: [
            GoRoute(
              path: '/admin',
              redirect: (context, state) => adminDashboard,
              routes: [
                GoRoute(
                  path: 'dashboard',
                  builder: (context, _) => const DashboardScreen(),
                ),
                GoRoute(
                  path: 'investigations',
                  builder: (context, _) => const AdminInvestigationListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, _) => const InvestigationEditScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final extra = state.extra;
                        final inv = extra is Investigation ? extra : null;
                        if (inv == null) {
                          return Scaffold(
                            appBar: AppBar(title: const Text('Enquête')),
                            body: const Center(
                              child: Text('Enquête introuvable.'),
                            ),
                          );
                        }
                        return AdminInvestigationDetailScreen(
                          investigation: inv,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'preview',
                          builder: (context, state) {
                            final id = state.pathParameters['id'] ?? '';
                            if (id.isEmpty) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: const Text('Prévisualisation'),
                                ),
                                body: const Center(
                                  child: Text('ID enquête manquant.'),
                                ),
                              );
                            }
                            return InvestigationPreviewScreen(
                              investigationId: id,
                            );
                          },
                        ),
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final extra = state.extra;
                            final inv = extra is Investigation ? extra : null;
                            if (inv == null) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: const Text('Éditer enquête'),
                                ),
                                body: const Center(
                                  child: Text('Enquête introuvable.'),
                                ),
                              );
                            }
                            return InvestigationEditScreen(investigation: inv);
                          },
                        ),
                        GoRoute(
                          path: 'enigmas/:enigmaId/edit',
                          builder: (context, state) {
                            final investigationId =
                                state.pathParameters['id'] ?? '';
                            final extra = state.extra;
                            final Enigma? enigma = extra is Enigma
                                ? extra
                                : null;
                            if (investigationId.isEmpty) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: const Text('Éditer l’énigme'),
                                ),
                                body: const Center(
                                  child: Text('ID enquête manquant.'),
                                ),
                              );
                            }
                            return EnigmaEditScreen(
                              investigationId: investigationId,
                              enigma: enigma,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: home, builder: (context, _) => const HomeScreen()),
      ],
    );
  }
}
