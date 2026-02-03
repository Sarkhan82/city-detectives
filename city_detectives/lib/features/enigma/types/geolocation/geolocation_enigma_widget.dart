import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/services/geolocation_provider.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';

/// Widget énigme géolocalisation (Story 4.1 – FR24, FR28, FR29, FR72, FR73).
/// Titre, consigne, bouton « Valider ma position » ; précision <10 m (Story 3.4).
/// État d'envoi via AsyncValue (project-context).
class GeolocationEnigmaWidget extends ConsumerStatefulWidget {
  const GeolocationEnigmaWidget({
    super.key,
    required this.enigma,
    required this.onValidated,
  });

  final Enigma enigma;
  final VoidCallback onValidated;

  @override
  ConsumerState<GeolocationEnigmaWidget> createState() =>
      _GeolocationEnigmaWidgetState();
}

class _GeolocationEnigmaWidgetState
    extends ConsumerState<GeolocationEnigmaWidget> {
  AsyncValue<ValidateEnigmaResult?> _validationState = AsyncValue.data(null);

  Future<void> _validatePosition() async {
    if (_validationState.isLoading) return;
    setState(() => _validationState = AsyncValue.loading());

    try {
      final geo = ref.read(geolocationServiceProvider);
      final granted = await geo.requestPermission();
      if (!granted && mounted) {
        setState(() {
          _validationState = AsyncValue.data(
            ValidateEnigmaResult(
              validated: false,
              message: 'Autorisez la localisation pour valider cette énigme.',
            ),
          );
        });
        return;
      }
      final position = await geo.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        setState(() {
          _validationState = AsyncValue.data(
            ValidateEnigmaResult(
              validated: false,
              message: 'Position introuvable. Vérifiez le GPS et réessayez.',
            ),
          );
        });
        return;
      }
      final repo = ref.read(enigmaValidationRepositoryProvider);
      final result = await repo.validateGeolocation(
        enigmaId: widget.enigma.id,
        userLat: position.latitude,
        userLng: position.longitude,
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
              'Rendez-vous au point indiqué, puis validez votre position pour vérifier si vous y êtes (message « Vous y êtes ! » en cas de succès).',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Valider ma position pour cette énigme',
              button: true,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _validatePosition,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(
                  isLoading ? 'Vérification…' : 'Valider ma position',
                ),
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
