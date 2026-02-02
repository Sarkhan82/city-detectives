import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'package:city_detectives/core/services/geolocation_service.dart';

/// Implémentation du service de géolocalisation via le package [geolocator] (Story 3.2).
class GeolocatorServiceImpl implements GeolocationService {
  @override
  Future<GeoPosition?> getCurrentPosition() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return GeoPosition(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('GeolocatorServiceImpl.getCurrentPosition failed: $e\n$st');
      }
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }
}
