import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';
import 'package:city_detectives/features/investigation/providers/payment_provider.dart';
import 'package:city_detectives/core/services/investigation_error_handler.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';
import 'package:city_detectives/shared/widgets/connectivity_status_indicator.dart';
import 'package:city_detectives/shared/widgets/price_chip.dart';

/// Écran liste des enquêtes (Story 2.1) – durée, difficulté, description.
/// Design « carnet de détective » ; WCAG 2.1 Level A.
class InvestigationListScreen extends ConsumerWidget {
  const InvestigationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(investigationListProvider);
    return Semantics(
      label:
          'Liste des enquêtes disponibles – durée, difficulté, description, gratuit ou payant',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enquêtes'),
          actions: [
            Semantics(
              label: 'Voir ma progression',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () => context.push(AppRouter.progression),
                tooltip: 'Ma progression',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: ConnectivityStatusIndicator(compact: true),
            ),
          ],
        ),
        body: SafeArea(
          child: asyncList.when(
            data: (list) {
              final purchasedIds =
                  ref.watch(userPurchasesProvider).valueOrNull ?? [];
              return _InvestigationListWithInProgress(
                list: list,
                inProgressIds: ref
                    .watch(investigationProgressRepositoryProvider)
                    .getInProgressInvestigationIds(),
                purchasedIds: purchasedIds,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userFriendlyInvestigationError(
                        err,
                        kInvestigationListLoadErrorMessage,
                      ),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.invalidate(investigationListProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
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

/// Liste avec section « Enquêtes en cours » en tête (Story 3.3, 6.2).
class _InvestigationListWithInProgress extends StatelessWidget {
  const _InvestigationListWithInProgress({
    required this.list,
    required this.inProgressIds,
    required this.purchasedIds,
  });

  final List<Investigation> list;
  final List<String> inProgressIds;
  final List<String> purchasedIds;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        if (inProgressIds.isNotEmpty) ...[
          Semantics(
            label: 'Enquêtes en cours – reprendre une enquête sauvegardée',
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Enquêtes en cours',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ...inProgressIds.map((id) {
            Investigation? inv;
            try {
              inv = list.firstWhere((e) => e.id == id);
            } catch (_) {
              inv = null;
            }
            final title = inv?.titre ?? 'Enquête en cours';
            return _InProgressCard(
              investigationId: id,
              title: title,
              onTap: () => context.push('/investigations/$id/start'),
            );
          }),
          const SizedBox(height: 16),
        ],
        if (list.isEmpty && inProgressIds.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aucune enquête disponible pour le moment.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...list.map(
            (inv) => _InvestigationCard(
              investigation: inv,
              isPurchased: purchasedIds.contains(inv.id),
              onTap: () => context.push(
                AppRouter.investigationDetailPath(inv.id),
                extra: inv,
              ),
            ),
          ),
      ],
    );
  }
}

/// Carte « Reprendre » pour une enquête en cours (Story 3.3).
class _InProgressCard extends StatelessWidget {
  const _InProgressCard({
    required this.investigationId,
    required this.title,
    required this.onTap,
  });

  final String investigationId;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Reprendre l\'enquête $title',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Reprendre',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte enquête – design carnet de détective (Story 2.1, 2.2, 6.2).
/// Affiche Gratuit/Payant/Achetée ; tap → détail (Story 2.2, 4.1).
class _InvestigationCard extends StatelessWidget {
  const _InvestigationCard({
    required this.investigation,
    required this.isPurchased,
    required this.onTap,
  });

  final Investigation investigation;
  final bool isPurchased;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inv = investigation;
    final priceLabel = inv.isFree
        ? 'Gratuit'
        : (isPurchased ? 'Achetée' : 'Payant');
    final priceText = isPurchased ? null : inv.formattedPrice;
    final semanticsPrice = priceText != null ? ' Prix $priceText.' : '';
    return Semantics(
      label:
          'Enquête ${inv.titre}. $priceLabel.$semanticsPrice ${inv.description}. Durée ${inv.durationEstimate} minutes. Difficulté ${inv.difficulte}. Bouton pour ouvrir le détail et démarrer.',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        inv.titre,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    isPurchased
                        ? Semantics(
                            label: 'Achetée',
                            child: Chip(
                              label: const Text('Achetée'),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.6),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        : PriceChip(isFree: inv.isFree, priceLabel: priceText),
                    if (priceText != null) ...[
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Prix $priceText',
                        child: Text(
                          priceText,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  inv.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '~${inv.durationEstimate} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inv.difficulte,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
