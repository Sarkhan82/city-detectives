import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/repositories/dashboard_repository.dart';

/// Écran dashboard admin (Story 7.1 – FR61). Vue d'ensemble : enquêtes, énigmes, métriques de base.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard admin'),
        actions: [
          Semantics(
            label: 'Retour à l\'accueil',
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go(AppRouter.home),
              tooltip: 'Retour à l\'accueil',
            ),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (overview) => _DashboardContent(overview: overview),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) {
          final is403 = error is DashboardForbiddenException;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    is403 ? Icons.block : Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    is403
                        ? 'Accès réservé aux administrateurs.'
                        : 'Erreur lors du chargement du dashboard.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (is403) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.go(AppRouter.home),
                      icon: const Icon(Icons.home),
                      label: const Text('Retour à l\'accueil'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.overview});

  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Vue d\'ensemble',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        _MetricCard(
          label: 'Enquêtes (total)',
          value: overview.investigationCount.toString(),
          icon: Icons.assignment,
          semanticLabel:
              'Nombre total d\'enquêtes : ${overview.investigationCount}',
        ),
        const SizedBox(height: 12),
        _MetricCard(
          label: 'Enquêtes publiées',
          value: overview.publishedCount.toString(),
          icon: Icons.public,
          semanticLabel: 'Enquêtes publiées : ${overview.publishedCount}',
        ),
        const SizedBox(height: 12),
        _MetricCard(
          label: 'Brouillons',
          value: overview.draftCount.toString(),
          icon: Icons.edit_note,
          semanticLabel: 'Enquêtes brouillon : ${overview.draftCount}',
        ),
        const SizedBox(height: 12),
        _MetricCard(
          label: 'Énigmes',
          value: overview.enigmaCount.toString(),
          icon: Icons.extension,
          semanticLabel: 'Nombre total d\'énigmes : ${overview.enigmaCount}',
        ),
        const SizedBox(height: 24),
        Semantics(
          label:
              'Ouvrir la liste des enquêtes pour prévisualiser, publier ou dépublier',
          child: ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Liste des enquêtes'),
            subtitle: const Text('Prévisualiser, publier, rollback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRouter.adminInvestigationListPath()),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.semanticLabel,
  });

  final String label;
  final String value;
  final IconData icon;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
