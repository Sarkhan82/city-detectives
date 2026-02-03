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
    final priceText = inv.formattedPrice;
    final semanticsPrice = priceText != null ? ' Prix $priceText.' : '';
    final semanticsActions = inv.isFree
        ? 'Bouton démarrer l\'enquête.'
        : 'Bouton acheter.$semanticsPrice Bouton démarrer l\'enquête après achat.';
    return Semantics(
      label:
          'Détail enquête ${inv.titre}. ${inv.description}. ${inv.isFree ? "Gratuit" : "Payant"}.$semanticsPrice $semanticsActions',
      child: Scaffold(
        appBar: AppBar(title: Text(inv.titre)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PriceChip(isFree: inv.isFree, priceLabel: priceText),
                    if (priceText != null) ...[
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Prix $priceText',
                        child: Text(
                          priceText,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
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
                if (inv.isFree)
                  Semantics(
                    label: 'Démarrer l\'enquête',
                    button: true,
                    child: FilledButton.icon(
                      onPressed: () => _onStartInvestigation(context, inv),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Démarrer l\'enquête'),
                    ),
                  )
                else ...[
                  Semantics(
                    label: priceText != null
                        ? 'Acheter – $priceText'
                        : 'Acheter',
                    button: true,
                    child: FilledButton.icon(
                      onPressed: () => _onPurchase(context, inv),
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        priceText != null ? 'Acheter – $priceText' : 'Acheter',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Démarrer l\'enquête après achat',
                    button: true,
                    child: OutlinedButton.icon(
                      onPressed: () => _onStartInvestigation(context, inv),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Démarrer l\'enquête (après achat)'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStartInvestigation(BuildContext context, Investigation inv) {
    // Enquête gratuite : accès direct (FR46). Payante : flux achat en 6.2.
    context.push('/investigations/${inv.id}/start');
  }

  /// Préparation 6.2 – pas de flux d'achat dans 6.1 (Story 6.1 Task 3.2).
  void _onPurchase(BuildContext context, Investigation inv) {
    // TODO Story 6.2 : implémenter achat / simulation paiement.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Achat de « ${inv.titre} » – bientôt disponible (Story 6.2)',
        ),
      ),
    );
  }
}
