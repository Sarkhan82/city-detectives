import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';

/// Message d'erreur utilisateur (sans stack ni détail technique).
String _userFriendlyErrorMessage(Object err) {
  final s = err.toString();
  final withoutException = s.replaceFirst('Exception: ', '');
  final firstLine = withoutException.split('\n').first.trim();
  if (firstLine.length > 200) return firstLine.substring(0, 200);
  return firstLine.isEmpty ? 'Une erreur est survenue.' : firstLine;
}

/// Écran liste des enquêtes (Story 2.1) – durée, difficulté, description.
/// Design « carnet de détective » ; WCAG 2.1 Level A.
class InvestigationListScreen extends ConsumerWidget {
  const InvestigationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(investigationListProvider);
    return Semantics(
      label: 'Liste des enquêtes disponibles – durée, difficulté, description',
      child: Scaffold(
        appBar: AppBar(title: const Text('Enquêtes')),
        body: SafeArea(
          child: asyncList.when(
            data: (list) => _InvestigationList(list: list),
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
                      _userFriendlyErrorMessage(err),
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
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

class _InvestigationList extends StatelessWidget {
  const _InvestigationList({required this.list});

  final List<Investigation> list;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          'Aucune enquête disponible pour le moment.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final inv = list[index];
        return _InvestigationCard(investigation: inv);
      },
    );
  }
}

/// Carte enquête – design carnet de détective (Story 2.1).
/// Affiche durée, difficulté, description ; accessibilité Semantics.
class _InvestigationCard extends StatelessWidget {
  const _InvestigationCard({required this.investigation});

  final Investigation investigation;

  @override
  Widget build(BuildContext context) {
    final inv = investigation;
    return Semantics(
      label:
          'Enquête ${inv.titre}. ${inv.description}. Durée ${inv.durationEstimate} minutes. Difficulté ${inv.difficulte}.',
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (inv.isFree)
                    Chip(
                      label: const Text('Gratuit'),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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
    );
  }
}
