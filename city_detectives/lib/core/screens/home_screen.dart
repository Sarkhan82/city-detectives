import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';

/// Écran d'accueil après connexion (Story 1.2, 7.1). Affiche lien Dashboard admin si isAdmin (FR61).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
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
          currentUserAsync.when(
            data: (user) {
              if (user?.isAdmin != true) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Dashboard admin'),
                subtitle: const Text('Gestion du contenu et métriques'),
                onTap: () {
                  if (!context.mounted) return;
                  GoRouter.of(context).push(AppRouter.adminDashboard);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
