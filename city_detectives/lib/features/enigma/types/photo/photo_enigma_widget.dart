import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';

/// Taille max photo en octets (3 Mo) – évite saturation mémoire / requête (code review).
const _kMaxPhotoBytes = 3 * 1024 * 1024;

/// Widget énigme photo (Story 4.1 – FR23, FR28, FR29, FR33).
/// Titre, consigne, bouton « Prendre une photo » ; fallback galerie si caméra refusée.
/// État d'envoi via AsyncValue (project-context).
class PhotoEnigmaWidget extends ConsumerStatefulWidget {
  const PhotoEnigmaWidget({
    super.key,
    required this.enigma,
    required this.onValidated,
  });

  final Enigma enigma;
  final VoidCallback onValidated;

  @override
  ConsumerState<PhotoEnigmaWidget> createState() => _PhotoEnigmaWidgetState();
}

class _PhotoEnigmaWidgetState extends ConsumerState<PhotoEnigmaWidget> {
  AsyncValue<ValidateEnigmaResult?> _validationState = AsyncValue.data(null);

  Future<void> _pickAndValidate() async {
    if (_validationState.isLoading) return;
    setState(() => _validationState = AsyncValue.loading());

    final picker = ImagePicker();
    XFile? file;

    try {
      file = await picker.pickImage(source: ImageSource.camera);
      if (file == null && mounted) {
        file = await picker.pickImage(source: ImageSource.gallery);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _validationState = AsyncValue.data(
            ValidateEnigmaResult(
              validated: false,
              message:
                  'Impossible d\'accéder à la caméra. Utilisez la galerie.',
            ),
          );
        });
      }
      return;
    }

    if (!mounted || file == null) {
      if (mounted) setState(() => _validationState = AsyncValue.data(null));
      return;
    }

    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > _kMaxPhotoBytes && mounted) {
        setState(() {
          _validationState = AsyncValue.data(
            ValidateEnigmaResult(
              validated: false,
              message:
                  'Photo trop volumineuse (max 3 Mo). Prenez une photo plus légère ou réduisez la qualité.',
            ),
          );
        });
        return;
      }
      final base64 = base64Encode(bytes);
      final repo = ref.read(enigmaValidationRepositoryProvider);
      final result = await repo.validatePhoto(
        enigmaId: widget.enigma.id,
        photoBase64: base64,
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
              'Prenez une photo du point indiqué.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Prendre une photo pour valider cette énigme',
              button: true,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _pickAndValidate,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt),
                label: Text(isLoading ? 'Envoi…' : 'Prendre une photo'),
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
