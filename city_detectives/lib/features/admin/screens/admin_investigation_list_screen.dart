import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';

/// Liste des enquêtes (admin) – brouillons et publiées (Story 7.3 – accès édition / prévisualisation).
class AdminInvestigationListScreen extends ConsumerWidget {
  const AdminInvestigationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(adminInvestigationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquêtes (admin)'),
        leading: Semantics(
          label: 'Retour au dashboard',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRouter.adminDashboard),
            tooltip: 'Retour',
          ),
        ),
      ),
      body: asyncList.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aucune enquête.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final inv = list[index];
              final isDraft = inv.status == 'draft';
              return Card(
                child: ListTile(
                  title: Text(inv.titre),
                  subtitle: Text(
                    (inv.status == null || inv.status!.isEmpty)
                        ? '—'
                        : (isDraft ? 'Brouillon' : 'Publiée'),
                    style: TextStyle(
                      color: isDraft
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    AppRouter.adminInvestigationDetailPath(inv.id),
                    extra: inv,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(err.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go(AppRouter.adminDashboard),
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Retour au dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
