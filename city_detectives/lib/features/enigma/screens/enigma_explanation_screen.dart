import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';

/// Écran ou panneau « Explications » après résolution d'une énigme (Story 4.3 – FR31, FR32, FR37).
/// Affiche le texte historique et le contenu éducatif ; design « carnet de détective », WCAG 2.1 Level A.
class EnigmaExplanationScreen extends ConsumerStatefulWidget {
  const EnigmaExplanationScreen({
    super.key,
    required this.enigmaId,
    required this.onContinue,
  });

  final String enigmaId;
  final VoidCallback onContinue;

  @override
  ConsumerState<EnigmaExplanationScreen> createState() =>
      _EnigmaExplanationScreenState();
}

class _EnigmaExplanationScreenState
    extends ConsumerState<EnigmaExplanationScreen> {
  AsyncValue<EnigmaExplanation?> _explanationState = const AsyncValue.data(
    null,
  );

  Future<void> _loadExplanation() async {
    setState(() => _explanationState = const AsyncValue.loading());
    try {
      final repo = ref.read(enigmaValidationRepositoryProvider);
      final explanation = await repo.getEnigmaExplanation(
        enigmaId: widget.enigmaId,
      );
      if (mounted) {
        setState(() => _explanationState = AsyncValue.data(explanation));
      }
    } catch (e, st) {
      if (mounted) {
        setState(() => _explanationState = AsyncValue.error(e, st));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExplanation());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explications')),
      body: _explanationState.when(
        data: (explanation) {
          if (explanation == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  label: 'Explication historique',
                  child: _SectionCard(
                    title: 'Contexte historique',
                    body: explanation.historicalExplanation,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Contenu éducatif',
                  child: _SectionCard(
                    title: 'Pour en savoir plus',
                    body: explanation.educationalContent,
                  ),
                ),
                const SizedBox(height: 32),
                Semantics(
                  label: 'Continuer vers l\'énigme suivante',
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
              FilledButton(
                onPressed: widget.onContinue,
                child: const Text('Continuer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
