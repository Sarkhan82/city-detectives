import 'package:flutter/material.dart';

/// Seuil de précision en mètres au-delà duquel on affiche l'indicateur (Story 3.4, FR72, FR81).
const double kPrecisionThresholdMeters = 10.0;

/// Indicateur de précision GPS (Story 3.4) – affiché lorsque la précision est >10 m ou instable.
/// Design system : indicateur discret avec message clair (FR81).
class PrecisionCircle extends StatelessWidget {
  const PrecisionCircle({
    super.key,
    required this.accuracyMeters,
    this.compact = false,
  });

  /// Précision en mètres (null = instable ou inconnue).
  final double? accuracyMeters;

  /// Si true, affiche uniquement l'icône/label court sans message détaillé.
  final bool compact;

  /// Retourne true si la position est considérée imprécise (>10 m ou inconnue).
  static bool isImprecise(double? accuracyMeters) {
    if (accuracyMeters == null) return true;
    return accuracyMeters > kPrecisionThresholdMeters;
  }

  @override
  Widget build(BuildContext context) {
    final imprecise = isImprecise(accuracyMeters);
    if (!imprecise && !compact) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final message = imprecise
        ? (accuracyMeters == null
              ? 'Position imprécise'
              : 'Position imprécise (environ ${accuracyMeters!.round()} m). Déplacez-vous pour améliorer la précision.')
        : null;

    return Semantics(
      label:
          message ??
          'Précision de la position : environ ${accuracyMeters!.round()} mètres',
      child: compact && !imprecise
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    imprecise ? Icons.gps_not_fixed : Icons.gps_fixed,
                    size: 18,
                    color: imprecise
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  if (message != null && !compact) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
