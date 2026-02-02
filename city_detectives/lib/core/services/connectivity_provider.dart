/// Providers pour le statut de connexion (Story 3.4, FR82).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/services/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);

/// Statut de connexion actuel (stream) – pour indicateur discret dans l'UI.
final connectivityStatusProvider =
    StreamProvider.autoDispose<ConnectivityStatus>((ref) {
      final service = ref.watch(connectivityServiceProvider);
      return service.onConnectivityChanged;
    });
