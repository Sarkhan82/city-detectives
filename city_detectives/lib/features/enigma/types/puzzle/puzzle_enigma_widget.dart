import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';

/// Widget énigme puzzle (Story 4.2 – FR26, FR28, FR29).
/// Titre, consigne, saisie code (champ texte) ; envoi au backend pour validation.
/// UI adaptée au type puzzle (code texte par défaut ; extensible pour logique/boutons).
class PuzzleEnigmaWidget extends ConsumerStatefulWidget {
  const PuzzleEnigmaWidget({
    super.key,
    required this.enigma,
    required this.onValidated,
    this.consigne,
  });

  final Enigma enigma;
  final VoidCallback onValidated;

  /// Consigne affichée (optionnel).
  final String? consigne;

  @override
  ConsumerState<PuzzleEnigmaWidget> createState() => _PuzzleEnigmaWidgetState();
}

class _PuzzleEnigmaWidgetState extends ConsumerState<PuzzleEnigmaWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  AsyncValue<ValidateEnigmaResult?> _validationState = AsyncValue.data(null);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) return;
    if (_validationState.isLoading) return;
    setState(() => _validationState = AsyncValue.loading());

    try {
      final repo = ref.read(enigmaValidationRepositoryProvider);
      final result = await repo.validatePuzzle(
        enigmaId: widget.enigma.id,
        codeAnswer: code,
      );
      if (!mounted) return;
      setState(() => _validationState = AsyncValue.data(result));
      if (result.validated) {
        widget.onValidated();
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _validationState = AsyncValue.error(e, st));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _validationState.isLoading;
    final result = _validationState.valueOrNull;
    final error = _validationState.error;
    final consigne =
        widget.consigne ?? 'Saisissez le code ou la réponse logique demandée.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.enigma.titre,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              consigne,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Code ou réponse puzzle',
              textField: true,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'Votre code',
                  border: OutlineInputBorder(),
                ),
                maxLength: 256,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Envoyer le code pour validation',
              button: true,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open),
                label: Text(isLoading ? 'Vérification…' : 'Valider le code'),
              ),
            ),
            if (result != null || error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: result != null
                      ? (result.validated
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.errorContainer)
                      : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      result != null && result.validated
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: result != null && result.validated
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result?.message ??
                            error.toString().replaceFirst('Exception: ', ''),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
