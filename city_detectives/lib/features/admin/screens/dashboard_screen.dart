import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/admin/models/completion_rate_entry.dart';
import 'package:city_detectives/features/admin/models/dashboard_overview.dart';
import 'package:city_detectives/features/admin/models/technical_metrics.dart';
import 'package:city_detectives/features/admin/models/user_analytics.dart';
import 'package:city_detectives/features/admin/models/user_journey_analytics.dart';
import 'package:city_detectives/features/admin/providers/dashboard_provider.dart';
import 'package:city_detectives/features/admin/repositories/dashboard_repository.dart';

/// Écran dashboard admin (Story 7.1 – FR61). Vue d'ensemble : enquêtes, énigmes, métriques de base.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);
    final technicalMetricsAsync = ref.watch(adminTechnicalMetricsProvider);
    final userAnalyticsAsync = ref.watch(adminUserAnalyticsProvider);
    final completionRatesAsync = ref.watch(adminCompletionRatesProvider);
    final userJourneyAsync = ref.watch(adminUserJourneyAnalyticsProvider);

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
        data: (overview) => _DashboardContent(
          overview: overview,
          technicalMetricsAsync: technicalMetricsAsync,
          userAnalyticsAsync: userAnalyticsAsync,
          completionRatesAsync: completionRatesAsync,
          userJourneyAsync: userJourneyAsync,
        ),
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
  const _DashboardContent({
    required this.overview,
    required this.technicalMetricsAsync,
    required this.userAnalyticsAsync,
    required this.completionRatesAsync,
    required this.userJourneyAsync,
  });

  final DashboardOverview overview;
  final AsyncValue<TechnicalMetrics> technicalMetricsAsync;
  final AsyncValue<UserAnalytics> userAnalyticsAsync;
  final AsyncValue<List<CompletionRateEntry>> completionRatesAsync;
  final AsyncValue<UserJourneyAnalytics> userJourneyAsync;

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
        Text(
          'Métriques techniques',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        technicalMetricsAsync.when(
          data: (metrics) => _TechnicalMetricsSection(metrics: metrics),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Semantics(
            label: 'Erreur chargement des métriques techniques',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Impossible de charger les métriques techniques.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Analytics utilisateurs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        userAnalyticsAsync.when(
          data: (analytics) => _UserAnalyticsSection(analytics: analytics),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Semantics(
            label: 'Erreur chargement des analytics utilisateurs',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Impossible de charger les analytics.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Taux de complétion',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        completionRatesAsync.when(
          data: (rates) => _CompletionRatesSection(rates: rates),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Semantics(
            label: 'Erreur chargement des taux de complétion',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Impossible de charger les taux de complétion.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Parcours utilisateur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        userJourneyAsync.when(
          data: (journey) => _UserJourneySection(journey: journey),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Semantics(
            label: 'Erreur chargement du parcours utilisateur',
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Impossible de charger le parcours.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
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

/// Section métriques techniques (Story 7.4 – FR68). Labels accessibles WCAG 2.1 Level A.
class _TechnicalMetricsSection extends StatelessWidget {
  const _TechnicalMetricsSection({required this.metrics});

  final TechnicalMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Métriques techniques : santé, latence API, crashs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MetricCard(
            label: 'Santé',
            value: metrics.healthStatus,
            icon: Icons.health_and_safety,
            semanticLabel: 'Statut santé : ${metrics.healthStatus}',
          ),
          if (metrics.apiLatencyAvgMs != null) ...[
            const SizedBox(height: 12),
            _MetricCard(
              label: 'Latence API (moy.)',
              value: '${metrics.apiLatencyAvgMs!.toStringAsFixed(0)} ms',
              icon: Icons.speed,
              semanticLabel:
                  'Latence API moyenne : ${metrics.apiLatencyAvgMs!.toStringAsFixed(0)} millisecondes',
            ),
          ],
          const SizedBox(height: 12),
          _MetricCard(
            label: 'Taux d\'erreur',
            value: '${(metrics.errorRate * 100).toStringAsFixed(1)} %',
            icon: Icons.warning_amber,
            semanticLabel:
                'Taux d\'erreur : ${(metrics.errorRate * 100).toStringAsFixed(1)} pour cent',
          ),
          const SizedBox(height: 12),
          _MetricCard(
            label: 'Crashs récents',
            value: metrics.crashCount.toString(),
            icon: Icons.bug_report,
            semanticLabel: 'Nombre de crashs récents : ${metrics.crashCount}',
          ),
          if (metrics.sentryDashboardUrl != null &&
              metrics.sentryDashboardUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Semantics(
              label: 'Ouvrir le tableau de bord Sentry pour les crashs',
              child: ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Voir Sentry'),
                subtitle: const Text('Détails des crashs'),
                onTap: () {
                  // Lien externe : en production utiliser url_launcher
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section analytics utilisateurs (Story 7.4 – FR69, FR70). Labels accessibles WCAG 2.1 Level A.
class _UserAnalyticsSection extends StatelessWidget {
  const _UserAnalyticsSection({required this.analytics});

  final UserAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Analytics utilisateurs : utilisateurs actifs et complétions totales',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MetricCard(
            label: 'Utilisateurs actifs',
            value: analytics.activeUserCount.toString(),
            icon: Icons.people,
            semanticLabel:
                'Nombre d\'utilisateurs actifs : ${analytics.activeUserCount}',
          ),
          const SizedBox(height: 12),
          _MetricCard(
            label: 'Complétions totales',
            value: analytics.totalCompletions.toString(),
            icon: Icons.check_circle,
            semanticLabel:
                'Nombre total de complétions d\'enquêtes : ${analytics.totalCompletions}',
          ),
        ],
      ),
    );
  }
}

/// Section taux de complétion par enquête (Story 7.4 – FR70). Tableau avec labels accessibles.
class _CompletionRatesSection extends StatelessWidget {
  const _CompletionRatesSection({required this.rates});

  final List<CompletionRateEntry> rates;

  @override
  Widget build(BuildContext context) {
    if (rates.isEmpty) {
      return Semantics(
        label: 'Aucun taux de complétion disponible',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aucune donnée pour le moment.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Tableau des taux de complétion par enquête',
      child: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Enquête')),
              DataColumn(label: Text('Démarrées')),
              DataColumn(label: Text('Complétées')),
              DataColumn(label: Text('Taux %')),
            ],
            rows: rates.map((r) {
              final ratePercent = (r.completionRate * 100).toStringAsFixed(1);
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      r.investigationTitle.isNotEmpty
                          ? r.investigationTitle
                          : r.investigationId,
                    ),
                  ),
                  DataCell(Text(r.startedCount.toString())),
                  DataCell(Text(r.completedCount.toString())),
                  DataCell(Text('$ratePercent %')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Section parcours utilisateur / funnel (Story 7.4 – FR71). Labels accessibles WCAG 2.1 Level A.
class _UserJourneySection extends StatelessWidget {
  const _UserJourneySection({required this.journey});

  final UserJourneyAnalytics journey;

  @override
  Widget build(BuildContext context) {
    if (journey.funnelSteps.isEmpty) {
      return Semantics(
        label: 'Aucune donnée de parcours disponible',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aucune donnée pour le moment.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Parcours utilisateur : funnel par étape',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: journey.funnelSteps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MetricCard(
              label: step.label,
              value: step.userCount.toString(),
              icon: Icons.trending_up,
              semanticLabel: '${step.label} : ${step.userCount} utilisateurs',
            ),
          );
        }).toList(),
      ),
    );
  }
}
