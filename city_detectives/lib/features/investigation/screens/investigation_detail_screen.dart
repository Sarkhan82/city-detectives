import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/payment_provider.dart';
import 'package:city_detectives/shared/widgets/price_chip.dart';

/// Écran détail d'une enquête (Story 2.2, 6.1, 6.2) – infos + CTA « Démarrer » ou « Acheter ».
/// Si payante et non achetée : bouton Acheter (flux simulé) ; sinon accès direct Démarrer (FR48).
class InvestigationDetailScreen extends ConsumerWidget {
  const InvestigationDetailScreen({super.key, required this.investigation});

  final Investigation investigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = investigation;
    final purchasesAsync = ref.watch(userPurchasesProvider);
    final purchasedIds = purchasesAsync.valueOrNull ?? [];
    final isPurchased = purchasedIds.contains(inv.id);
    final canStartDirect = inv.isFree || isPurchased;

    final priceText = inv.formattedPrice;
    final semanticsPrice = priceText != null ? ' Prix $priceText.' : '';
    final semanticsActions = canStartDirect
        ? 'Bouton démarrer l\'enquête.'
        : 'Bouton acheter.$semanticsPrice Bouton démarrer l\'enquête après achat.';
    return Semantics(
      label:
          'Détail enquête ${inv.titre}. ${inv.description}. ${inv.isFree
              ? "Gratuit"
              : isPurchased
              ? "Achetée"
              : "Payant"}.$semanticsPrice $semanticsActions',
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
                    PriceChip(
                      isFree: inv.isFree,
                      priceLabel: isPurchased ? 'Achetée' : priceText,
                    ),
                    if (priceText != null && !isPurchased) ...[
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
                if (canStartDirect)
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
                      onPressed: () => _onPurchase(context, ref, inv),
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
    context.push(AppRouter.investigationStartPath(inv.id));
  }

  /// Ouvre le flux de simulation achat (Story 6.2 – FR53).
  /// Enregistre l'intention d'achat au clic « Acheter » (FR52) puis navigue.
  void _onPurchase(BuildContext context, WidgetRef ref, Investigation inv) {
    Future<void> run() async {
      try {
        final payment = ref.read(paymentServiceProvider);
        await payment.recordPurchaseIntent(inv.id);
        if (!context.mounted) return;
        context.push(AppRouter.investigationPurchasePath(inv.id), extra: inv);
      } catch (e) {
        if (!context.mounted) return;
        final msg =
            e.toString().toLowerCase().contains('authentification') ||
                e.toString().toLowerCase().contains('token')
            ? 'Veuillez vous connecter pour acheter.'
            : e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    }

    run();
  }
}
