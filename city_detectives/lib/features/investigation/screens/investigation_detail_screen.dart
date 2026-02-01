import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/shared/widgets/price_chip.dart';

/// Écran détail d'une enquête (Story 2.2) – infos + CTA « Démarrer l'enquête ».
/// Story 3.1 gérera l'écran de jeu ; ici navigation vers placeholder ou entrée du flux.
class InvestigationDetailScreen extends StatelessWidget {
  const InvestigationDetailScreen({super.key, required this.investigation});

  final Investigation investigation;

  @override
  Widget build(BuildContext context) {
    final inv = investigation;
    return Semantics(
      label:
          'Détail enquête ${inv.titre}. ${inv.description}. ${inv.isFree ? "Gratuit" : "Payant"}. Bouton démarrer l\'enquête.',
      child: Scaffold(
        appBar: AppBar(title: Text(inv.titre)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: PriceChip(isFree: inv.isFree),
                ),
                const SizedBox(height: 16),
                Text(
                  inv.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '~${inv.durationEstimate} min',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      inv.difficulte,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _onStartInvestigation(context, inv),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Démarrer l\'enquête'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStartInvestigation(BuildContext context, Investigation inv) {
    // Story 3.1 gérera l'écran de jeu ; pour 2.2 on navigue vers un placeholder.
    context.push('/investigations/${inv.id}/start');
  }
}
