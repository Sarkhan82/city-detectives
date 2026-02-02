/// Service de statut de connexion (Story 3.4, FR82) – connectivity_plus.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Statut de connexion simplifié pour l'UI (Story 3.4).
enum ConnectivityStatus {
  /// Réseau disponible (wifi, ethernet, mobile).
  online,

  /// Aucun réseau.
  offline,

  /// Connexion dégradée (ex. uniquement mobile, VPN).
  degraded,
}

/// Service centralisé pour le statut réseau (Story 3.4).
/// Utilise [connectivity_plus] ; met à jour l'affichage quand l'état change (FR82).
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Statut actuel (une seule lecture).
  Future<ConnectivityStatus> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return _toStatus(result);
  }

  /// Stream des changements de connectivité (pour mettre à jour l'UI).
  Stream<ConnectivityStatus> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_toStatus);

  static ConnectivityStatus _toStatus(List<ConnectivityResult> result) {
    if (result.isEmpty || result.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    final hasWifi =
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
    if (hasWifi) return ConnectivityStatus.online;
    if (result.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.degraded;
    }
    return ConnectivityStatus.online;
  }
}
