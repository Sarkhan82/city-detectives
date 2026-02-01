import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder « Démarrer » (Story 2.2). Story 3.1 implémentera l'écran de jeu.
class InvestigationStartPlaceholderScreen extends StatelessWidget {
  const InvestigationStartPlaceholderScreen({
    super.key,
    required this.investigationId,
  });

  final String investigationId;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Placeholder démarrage enquête $investigationId. L\'écran de jeu sera implémenté en Story 3.1. Bouton retour.',
      child: Scaffold(
        appBar: AppBar(title: const Text('Démarrer l\'enquête')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Enquête $investigationId',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'L\'écran de jeu sera implémenté en Story 3.1.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Semantics(
                  label: 'Retour à l\'écran précédent',
                  button: true,
                  child: FilledButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
