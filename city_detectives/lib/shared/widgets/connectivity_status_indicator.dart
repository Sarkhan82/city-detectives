import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/services/connectivity_provider.dart';
import 'package:city_detectives/core/services/connectivity_service.dart';

/// Indicateur discret du statut de connexion (Story 3.4, FR82).
/// Design : indicateur discret (UX) ; pas de popup intrusif sauf si action requise.
class ConnectivityStatusIndicator extends ConsumerWidget {
  const ConnectivityStatusIndicator({super.key, this.compact = true});

  /// Si true, affiche uniquement l'icône (pour barre d'app ou coin).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(connectivityStatusProvider);
    return statusAsync.when(
      data: (status) => _Indicator(status: status, compact: compact),
      loading: () =>
          _Indicator(status: ConnectivityStatus.online, compact: compact),
      error: (_, _) =>
          _Indicator(status: ConnectivityStatus.offline, compact: compact),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.status, required this.compact});

  final ConnectivityStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label) = switch (status) {
      ConnectivityStatus.online => (Icons.wifi, 'Connexion disponible'),
      ConnectivityStatus.offline => (Icons.wifi_off, 'Hors ligne'),
      ConnectivityStatus.degraded => (
        Icons.signal_cellular_alt,
        'Connexion dégradée',
      ),
    };
    final color = switch (status) {
      ConnectivityStatus.online => theme.colorScheme.primary,
      ConnectivityStatus.offline => theme.colorScheme.error,
      ConnectivityStatus.degraded => theme.colorScheme.tertiary,
    };
    return Semantics(
      label: label,
      child: compact
          ? Icon(icon, size: 18, color: color)
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ],
              ),
            ),
    );
  }
}
