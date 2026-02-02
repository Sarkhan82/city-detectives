import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/services/geolocation_service.dart';
import 'package:city_detectives/core/services/geolocator_service_impl.dart';

/// Service de géolocalisation (Story 3.2) – override en test avec un mock.
final geolocationServiceProvider = Provider<GeolocationService>(
  (ref) => GeolocatorServiceImpl(),
);

/// Position actuelle pour la carte (Story 3.2) – demande permission puis récupère la position.
/// Auto-dispose pour ne pas garder en mémoire ; family par investigationId pour isoler.
final currentPositionForMapProvider = FutureProvider.autoDispose
    .family<GeoPosition?, String>((ref, investigationId) async {
      final svc = ref.watch(geolocationServiceProvider);
      await svc.requestPermission();
      return svc.getCurrentPosition();
    });
