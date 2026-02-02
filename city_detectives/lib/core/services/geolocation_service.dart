/// Service de géolocalisation (Story 3.2) – architecture centralisée.
/// Obtient la position actuelle via [geolocator] ; mockable pour les tests.
abstract class GeolocationService {
  /// Position actuelle (lat, lng) ou null si indisponible / refusée.
  Future<GeoPosition?> getCurrentPosition();

  /// Demande les permissions de localisation si nécessaire.
  /// Retourne true si autorisé (ou déjà accordé), false si refusé.
  Future<bool> requestPermission();
}

/// Position géographique (lat/lng) et précision optionnelle (Story 3.2).
class GeoPosition {
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}
