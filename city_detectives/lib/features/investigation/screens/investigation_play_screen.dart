import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/services/investigation_error_handler.dart';
import 'package:city_detectives/features/enigma/types/geolocation/geolocation_enigma_widget.dart';
import 'package:city_detectives/features/enigma/types/photo/photo_enigma_widget.dart';
import 'package:city_detectives/features/enigma/types/puzzle/puzzle_enigma_widget.dart';
import 'package:city_detectives/features/enigma/types/words/words_enigma_widget.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation_progress.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/providers/investigation_play_provider.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';
import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/investigation/widgets/investigation_map_sheet.dart';
import 'package:city_detectives/shared/widgets/connectivity_status_indicator.dart';

/// Sauvegarde la progression courante en Hive (Story 3.3). Attendre la fin avant de naviguer.
Future<void> _saveProgress(WidgetRef ref, String investigationId) async {
  final repo = ref.read(investigationProgressRepositoryProvider);
  final index = ref.read(currentEnigmaIndexProvider(investigationId));
  final completed = ref.read(completedEnigmaIdsProvider(investigationId));
  await repo.saveProgress(
    InvestigationProgress(
      investigationId: investigationId,
      currentEnigmaIndex: index,
      completedEnigmaIds: completed.toList(),
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    ),
  );
}

/// Écran « enquête en cours » (Story 3.1 + 3.3) – navigation, pause, abandon, sauvegarde.
class InvestigationPlayScreen extends ConsumerStatefulWidget {
  const InvestigationPlayScreen({super.key, required this.investigationId});

  final String investigationId;

  @override
  ConsumerState<InvestigationPlayScreen> createState() =>
      _InvestigationPlayScreenState();
}

class _InvestigationPlayScreenState
    extends ConsumerState<InvestigationPlayScreen> {
  bool _progressRestored = false;

  @override
  Widget build(BuildContext context) {
    final investigationId = widget.investigationId;
    final asyncData = ref.watch(
      investigationWithEnigmasProvider(investigationId),
    );
    final currentIndex = ref.watch(currentEnigmaIndexProvider(investigationId));

    return asyncData.when(
      data: (data) {
        // Story 3.3 : restaurer une fois la progression sauvegardée depuis Hive.
        if (data != null && !_progressRestored) {
          final repo = ref.read(investigationProgressRepositoryProvider);
          final progress = repo.getProgress(investigationId);
          if (progress != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ref
                  .read(currentEnigmaIndexProvider(investigationId).notifier)
                  .state = progress
                  .currentEnigmaIndex;
              final completedNotifier = ref.read(
                completedEnigmaIdsProvider(investigationId).notifier,
              );
              completedNotifier.clear();
              for (final eid in progress.completedEnigmaIds) {
                completedNotifier.markCompleted(eid);
              }
              setState(() => _progressRestored = true);
            });
            return Semantics(
              label: 'Reprise de l\'enquête en cours',
              child: Scaffold(
                appBar: AppBar(title: const Text('Enquête en cours')),
                body: const Center(child: CircularProgressIndicator()),
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() => _progressRestored = true);
          });
        }
        return _buildContent(context, ref, data, currentIndex, investigationId);
      },
      loading: () => Semantics(
        label: 'Chargement de l\'enquête en cours',
        child: Scaffold(
          appBar: AppBar(title: const Text('Enquête en cours')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stackTrace) {
        logInvestigationError(err, stackTrace);
        return Semantics(
          label: 'Erreur lors du chargement de l\'enquête',
          child: Scaffold(
            appBar: AppBar(title: const Text('Enquête en cours')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userFriendlyInvestigationError(err),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(
                        investigationWithEnigmasProvider(investigationId),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InvestigationWithEnigmas? data,
    int currentIndex,
    String investigationId,
  ) {
    if (data == null) {
      return Semantics(
        label: 'Enquête introuvable',
        child: Scaffold(
          appBar: AppBar(title: const Text('Enquête en cours')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enquête introuvable.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final inv = data.investigation;
    final enigmas = data.enigmas;
    final total = enigmas.length;
    final hasEnigmas = total > 0;
    // Clamp index to avoid crash if state is stale (e.g. hot reload, fewer enigmas after refresh).
    final safeIndex = hasEnigmas ? (currentIndex.clamp(0, total - 1)) : 0;
    final currentEnigma = hasEnigmas ? enigmas[safeIndex] : null;
    final completedIds = ref.watch(completedEnigmaIdsProvider(investigationId));
    final completedCount = enigmas
        .where((e) => completedIds.contains(e.id))
        .length;

    return Semantics(
      label:
          'Enquête en cours ${inv.titre}. Énigme ${safeIndex + 1} sur $total. $completedCount énigmes complétées sur $total. Navigation précédent suivant.',
      child: Scaffold(
        appBar: AppBar(
          title: Text(inv.titre),
          leading: Semantics(
            label: 'Retour à l\'écran précédent',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await _saveProgress(ref, investigationId);
                if (!context.mounted) return;
                context.pop();
              },
              tooltip: 'Retour',
            ),
          ),
          actions: [
            Semantics(
              label: 'Mettre en pause – sauvegarde et retour à la liste',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () async {
                  await _saveProgress(ref, investigationId);
                  if (!context.mounted) return;
                  context.go(AppRouter.investigations);
                },
                tooltip: 'Mettre en pause',
              ),
            ),
            Semantics(
              label:
                  'Abandonner l\'enquête – sauvegarde et quitter (reprise possible plus tard)',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  await _saveProgress(ref, investigationId);
                  if (!context.mounted) return;
                  context.go(AppRouter.investigations);
                },
                tooltip: 'Abandonner',
              ),
            ),
            Semantics(
              label: 'Voir la carte',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _showMap(context, ref, investigationId),
                tooltip: 'Voir la carte',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: ConnectivityStatusIndicator(compact: true),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasEnigmas) ...[
                _ProgressIndicator(
                  completedCount: completedCount,
                  total: total,
                ),
                _EnigmaStepper(current: safeIndex + 1, total: total),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _EnigmaContent(
                      enigma: currentEnigma!,
                      onValidated: () {
                        ref
                            .read(
                              completedEnigmaIdsProvider(
                                investigationId,
                              ).notifier,
                            )
                            .markCompleted(currentEnigma.id);
                        if (safeIndex < total - 1) {
                          ref
                                  .read(
                                    currentEnigmaIndexProvider(
                                      investigationId,
                                    ).notifier,
                                  )
                                  .state =
                              safeIndex + 1;
                        }
                        _saveProgress(ref, investigationId);
                      },
                    ),
                  ),
                ),
                _NavigationBar(
                  currentIndex: safeIndex,
                  total: total,
                  onPrevious: () {
                    if (safeIndex > 0) {
                      ref
                              .read(
                                currentEnigmaIndexProvider(
                                  investigationId,
                                ).notifier,
                              )
                              .state =
                          safeIndex - 1;
                      _saveProgress(ref, investigationId);
                    }
                  },
                  onNext: () {
                    if (safeIndex < total - 1) {
                      ref
                          .read(
                            completedEnigmaIdsProvider(
                              investigationId,
                            ).notifier,
                          )
                          .markCompleted(currentEnigma.id);
                      ref
                              .read(
                                currentEnigmaIndexProvider(
                                  investigationId,
                                ).notifier,
                              )
                              .state =
                          safeIndex + 1;
                      _saveProgress(ref, investigationId);
                    }
                  },
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Aucune énigme pour cette enquête.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicateur de progression (Story 3.2) – énigmes complétées vs restantes, design « carnet de détective ».
class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.completedCount, required this.total});

  final int completedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completedCount / total : 0.0;
    return Semantics(
      label: 'Progression : $completedCount énigmes complétées sur $total',
      value: '$completedCount',
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$completedCount / $total énigmes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showMap(BuildContext context, WidgetRef ref, String investigationId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) =>
          InvestigationMapSheet(investigationId: investigationId),
    ),
  );
}

class _EnigmaStepper extends StatelessWidget {
  const _EnigmaStepper({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        'Énigme $current / $total',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Contenu de l'énigme selon le type (Story 4.1 – Task 4.1) : photo, géolocalisation ou placeholder.
class _EnigmaContent extends StatelessWidget {
  const _EnigmaContent({required this.enigma, required this.onValidated});

  final Enigma enigma;
  final VoidCallback onValidated;

  @override
  Widget build(BuildContext context) {
    switch (enigma.type) {
      case 'photo':
        return PhotoEnigmaWidget(enigma: enigma, onValidated: onValidated);
      case 'geolocation':
        return GeolocationEnigmaWidget(
          enigma: enigma,
          onValidated: onValidated,
        );
      case 'words':
        return WordsEnigmaWidget(enigma: enigma, onValidated: onValidated);
      case 'puzzle':
        return PuzzleEnigmaWidget(enigma: enigma, onValidated: onValidated);
      default:
        return _EnigmaCard(enigma: enigma);
    }
  }
}

class _EnigmaCard extends StatelessWidget {
  const _EnigmaCard({required this.enigma});

  final Enigma enigma;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(enigma.titre, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Type : ${enigma.type}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Contenu de l\'énigme (Epic 4)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    required this.currentIndex,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentIndex;
  final int total;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = currentIndex > 0;
    final canGoNext = currentIndex < total - 1;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            label: canGoPrevious
                ? 'Énigme précédente'
                : 'Pas d\'énigme précédente',
            button: true,
            child: FilledButton.tonalIcon(
              onPressed: canGoPrevious ? onPrevious : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Précédent'),
            ),
          ),
          Semantics(
            label: canGoNext ? 'Énigme suivante' : 'Pas d\'énigme suivante',
            button: true,
            child: FilledButton.icon(
              onPressed: canGoNext ? onNext : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}
