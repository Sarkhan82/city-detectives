import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';

/// Panneau d'indices progressifs (Story 4.3 – FR30).
/// Affiche suggestion → indice → solution ; l'utilisateur débloque le niveau suivant à chaque demande.
class EnigmaHintsPanel extends ConsumerStatefulWidget {
  const EnigmaHintsPanel({super.key, required this.enigmaId, this.onClose});

  final String enigmaId;
  final VoidCallback? onClose;

  @override
  ConsumerState<EnigmaHintsPanel> createState() => _EnigmaHintsPanelState();
}

class _EnigmaHintsPanelState extends ConsumerState<EnigmaHintsPanel> {
  AsyncValue<EnigmaHints?> _hintsState = const AsyncValue.data(null);
  int _currentLevel = 0; // 0 = suggestion, 1 = hint, 2 = solution

  Future<void> _loadHints() async {
    if (_hintsState.valueOrNull != null) return;
    setState(() => _hintsState = const AsyncValue.loading());
    try {
      final repo = ref.read(enigmaValidationRepositoryProvider);
      final hints = await repo.getEnigmaHints(enigmaId: widget.enigmaId);
      if (mounted) {
        setState(() {
          _hintsState = AsyncValue.data(hints);
          _currentLevel = 0;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() => _hintsState = AsyncValue.error(e, st));
      }
    }
  }

  void _showNextHint() {
    if (_currentLevel < 2) {
      setState(() => _currentLevel++);
    } else {
      widget.onClose?.call();
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHints());
  }

  @override
  Widget build(BuildContext context) {
    return _hintsState.when(
      data: (hints) {
        if (hints == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final text = hints.getLevel(_currentLevel);
        final isSolution = _currentLevel == 2;
        final nextLabel = isSolution ? 'Fermer' : 'Voir l\'indice suivant';
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isSolution ? 'Solution' : 'Indice ${_currentLevel + 1}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: 'Contenu de l\'indice : $text',
                child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: 24),
              Semantics(
                label: nextLabel,
                button: true,
                child: FilledButton(
                  onPressed: () => _showNextHint(),
                  child: Text(nextLabel),
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
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
