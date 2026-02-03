import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/profile/providers/user_progress_provider.dart';

/// Écran Profil / Progression (Story 5.1, FR39, FR40, FR41).
/// Affiche statut par enquête, progression globale et historique des complétées.
class ProgressionScreen extends ConsumerWidget {
  const ProgressionScreen({super.key});

  static String _statusLabel(InvestigationStatus status) {
    switch (status) {
      case InvestigationStatus.notStarted:
        return 'Non démarrée';
      case InvestigationStatus.inProgress:
        return 'En cours';
      case InvestigationStatus.completed:
        return 'Complétée';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(userProgressDataProvider);

    return Semantics(
      label:
          'Progression – statut des enquêtes, progression globale et historique',
      child: Scaffold(
        appBar: AppBar(title: const Text('Ma progression')),
        body: SafeArea(
          child: asyncData.when(
            data: (data) => _ProgressionContent(data: data),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Impossible de charger la progression.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      label: 'Réessayer le chargement de la progression',
                      button: true,
                      child: FilledButton.icon(
                        onPressed: () =>
                            ref.invalidate(userProgressDataProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressionContent extends StatelessWidget {
  const _ProgressionContent({required this.data});

  final UserProgressData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Accès Gamification (Story 5.2 – FR42–FR45)
        Semantics(
          label:
              'Ouvrir la section Gamification : badges, compétences, cartes postales et classement',
          button: true,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                Icons.emoji_events,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Gamification'),
              subtitle: const Text(
                'Badges, compétences, cartes postales et classement',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRouter.gamification),
            ),
          ),
        ),
        // Progression globale (FR40) – design carnet de détective
        Semantics(
          label:
              'Progression globale : ${data.completedCount} enquêtes complétées sur ${data.totalCount}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${data.completedCount} / ${data.totalCount} enquêtes complétées',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: data.totalCount > 0
                        ? data.completedCount / data.totalCount
                        : 0.0,
                    minHeight: 8,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Statut par enquête (FR39)
        Semantics(
          label: 'Statut de chaque enquête',
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Statut par enquête',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ...data.entries.map(
          (e) => _StatusCard(
            title: e.investigation.titre,
            status: e.status,
            investigationId: e.investigation.id,
          ),
        ),
        const SizedBox(height: 24),
        // Historique (FR41)
        Semantics(
          label: 'Historique des enquêtes complétées',
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Enquêtes complétées',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (data.history.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Aucune enquête complétée pour le moment.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...data.history.map(
            (h) => _HistoryTile(
              title: h.title,
              completedAt: h.completedAt,
              investigationId: h.investigationId,
              investigation: h.investigation,
            ),
          ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.status,
    required this.investigationId,
  });

  final String title;
  final InvestigationStatus status;
  final String investigationId;

  @override
  Widget build(BuildContext context) {
    final label = ProgressionScreen._statusLabel(status);
    IconData icon;
    Color? color;
    switch (status) {
      case InvestigationStatus.notStarted:
        icon = Icons.radio_button_unchecked;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        break;
      case InvestigationStatus.inProgress:
        icon = Icons.play_circle_outline;
        color = Theme.of(context).colorScheme.primary;
        break;
      case InvestigationStatus.completed:
        icon = Icons.check_circle;
        color = Theme.of(context).colorScheme.primary;
        break;
    }

    return Semantics(
      label: 'Enquête $title – statut : $label',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            if (status == InvestigationStatus.completed) return;
            context.push(AppRouter.investigationStartPath(investigationId));
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                if (status != InvestigationStatus.completed)
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.completedAt,
    required this.investigationId,
    this.investigation,
  });

  final String title;
  final DateTime completedAt;
  final String investigationId;
  final Investigation? investigation;

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) {
      return 'Aujourd\'hui à ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Enquête complétée : $title, le ${_formatDate(completedAt)}',
      child: ListTile(
        leading: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(_formatDate(completedAt)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (investigation != null) {
            context.push(
              AppRouter.investigationDetailPath(investigationId),
              extra: investigation,
            );
          } else {
            context.push(AppRouter.investigationDetailPath(investigationId));
          }
        },
      ),
    );
  }
}
