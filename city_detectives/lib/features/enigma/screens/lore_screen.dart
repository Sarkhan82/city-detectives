import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/investigation/models/lore_content.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';

/// Écran LORE (Story 4.4 – FR34, FR35, FR37) : contenu narratif (titre, texte, photos),
/// bouton « Sauter » pour passer à la suite. Design « carnet de détective », WCAG 2.1 Level A.
class LoreScreen extends ConsumerStatefulWidget {
  const LoreScreen({
    super.key,
    required this.investigationId,
    required this.sequenceIndex,
    required this.onContinue,
  });

  final String investigationId;
  final int sequenceIndex;
  final VoidCallback onContinue;

  @override
  ConsumerState<LoreScreen> createState() => _LoreScreenState();
}

class _LoreScreenState extends ConsumerState<LoreScreen> {
  AsyncValue<LoreContent?> _loreState = const AsyncValue.data(null);

  Future<void> _loadLore() async {
    setState(() => _loreState = const AsyncValue.loading());
    try {
      final repo = ref.read(investigationRepositoryProvider);
      final lore = await repo.getLoreContent(
        investigationId: widget.investigationId,
        sequenceIndex: widget.sequenceIndex,
      );
      if (mounted) {
        setState(() => _loreState = AsyncValue.data(lore));
      }
    } catch (e, st) {
      if (mounted) {
        setState(() => _loreState = AsyncValue.error(e, st));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLore());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contexte'),
        actions: [
          // Bouton Sauter visible et accessible (FR35) – Task 2.1
          Semantics(
            label: 'Sauter le contenu et aller à la suite',
            button: true,
            child: TextButton(
              onPressed: () => widget.onContinue(),
              child: const Text('Sauter'),
            ),
          ),
        ],
      ),
      body: _loreState.when(
        data: (lore) {
          if (lore == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Aucun contenu à cet emplacement.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: widget.onContinue,
                    child: const Text('Continuer'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Titre du récit : ${lore.title}',
                  child: Text(
                    lore.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Contenu narratif et contexte historique',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        lore.contentText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
                if (lore.mediaUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Photos et contexte des lieux',
                    child: _LoreMediaSection(urls: lore.mediaUrls),
                  ),
                ],
                const SizedBox(height: 24),
                Semantics(
                  label: 'Sauter et aller à la suite',
                  button: true,
                  child: FilledButton.tonalIcon(
                    onPressed: () => widget.onContinue(),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Sauter'),
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Continuer après avoir lu',
                  button: true,
                  child: FilledButton(
                    onPressed: widget.onContinue,
                    child: const Text('Continuer'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                err.toString().replaceFirst('Exception: ', ''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                label: 'Sauter malgré l\'erreur',
                button: true,
                child: FilledButton(
                  onPressed: widget.onContinue,
                  child: const Text('Sauter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hauteur fixe pour les médias LORE pour éviter le layout shift (review 4.4).
const double _kLoreMediaHeight = 200.0;

/// Affiche les médias LORE (photos/contexte des lieux – FR37). Cache réseau, hauteur fixe.
class _LoreMediaSection extends StatelessWidget {
  const _LoreMediaSection({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: urls
          .map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: _kLoreMediaHeight,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
