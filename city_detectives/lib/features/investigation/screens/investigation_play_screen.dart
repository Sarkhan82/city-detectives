import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/providers/investigation_play_provider.dart';

/// Écran « enquête en cours » (Story 3.1) – première énigme ou intro, navigation Suivant/Précédent.
/// Affichage minimal par énigme : titre, ordre (ex. « Énigme 1/5 »), placeholder contenu.
class InvestigationPlayScreen extends ConsumerWidget {
  const InvestigationPlayScreen({super.key, required this.investigationId});

  final String investigationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(
      investigationWithEnigmasProvider(investigationId),
    );
    final currentIndex = ref.watch(currentEnigmaIndexProvider(investigationId));

    return asyncData.when(
      data: (data) => _buildContent(context, ref, data, currentIndex),
      loading: () => Semantics(
        label: 'Chargement de l\'enquête en cours',
        child: Scaffold(
          appBar: AppBar(title: const Text('Enquête en cours')),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => Semantics(
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
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
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
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InvestigationWithEnigmas? data,
    int currentIndex,
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

    return Semantics(
      label:
          'Enquête en cours ${inv.titre}. Énigme ${safeIndex + 1} sur $total. Navigation précédent suivant.',
      child: Scaffold(
        appBar: AppBar(
          title: Text(inv.titre),
          leading: Semantics(
            label: 'Retour à l\'écran précédent',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
              tooltip: 'Retour',
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasEnigmas) ...[
                _EnigmaStepper(current: safeIndex + 1, total: total),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _EnigmaCard(enigma: currentEnigma!),
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
                    }
                  },
                  onNext: () {
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
