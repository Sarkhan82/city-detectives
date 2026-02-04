import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';

/// Écran de prévisualisation d'une enquête (Story 7.3 – FR65).
/// Affiche l'enquête et la liste des énigmes comme un utilisateur les verrait.
class InvestigationPreviewScreen extends ConsumerWidget {
  const InvestigationPreviewScreen({super.key, required this.investigationId});

  final String investigationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(investigationPreviewProvider(investigationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévisualisation'),
        leading: Semantics(
          label: 'Retour à l\'enquête',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Retour',
          ),
        ),
      ),
      body: asyncData.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Enquête introuvable.'));
          }
          final inv = data.investigation;
          final enigmas = data.enigmas;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                inv.titre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                inv.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Énigmes (${enigmas.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...enigmas.map(
                (e) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        '${e.orderIndex + 1}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    title: Text(e.titre),
                    subtitle: Text('Type: ${e.type}'),
                  ),
                ),
              ),
            ],
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
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: 'Retour au dashboard admin',
                  child: FilledButton.icon(
                    onPressed: () => context.go(AppRouter.adminDashboard),
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Retour au dashboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
