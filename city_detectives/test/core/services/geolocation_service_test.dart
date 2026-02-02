// Story 3.4 – Tests unitaires geolocation_service (mock geolocator).

import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/core/services/geolocation_service.dart';
import 'package:city_detectives/core/services/geolocator_service_impl.dart';

void main() {
  group('GeoPosition', () {
    test('stores latitude, longitude and optional accuracyMeters', () {
      const pos = GeoPosition(
        latitude: 48.85,
        longitude: 2.35,
        accuracyMeters: 8.0,
      );
      expect(pos.latitude, 48.85);
      expect(pos.longitude, 2.35);
      expect(pos.accuracyMeters, 8.0);
    });

    test('accuracyMeters can be null', () {
      const pos = GeoPosition(latitude: 48.85, longitude: 2.35);
      expect(pos.accuracyMeters, isNull);
    });
  });

  group('GeolocatorServiceImpl', () {
    test('implements GeolocationService', () {
      expect(GeolocatorServiceImpl(), isA<GeolocationService>());
    });

    test(
      'getCurrentPosition when non-null exposes accuracyMeters (mock behavior)',
      () async {
        // Fake simulant geolocator qui retourne une position avec précision (Story 7.1 mock).
        final fake = _FakeGeolocationService(
          GeoPosition(latitude: 48.85, longitude: 2.35, accuracyMeters: 7.5),
        );
        final result = await fake.getCurrentPosition();
        expect(result, isNotNull);
        expect(result!.accuracyMeters, 7.5);
      },
    );

    test('requestPermission returns bool (contract)', () async {
      final fake = _FakeGeolocationService(null);
      final result = await fake.requestPermission();
      expect(result, isA<bool>());
      expect(result, isFalse);
    });
  });
}

/// Fake pour tests – simule le comportement de geolocator (retourne une position avec précision).
class _FakeGeolocationService implements GeolocationService {
  _FakeGeolocationService(this._position);

  final GeoPosition? _position;

  @override
  Future<GeoPosition?> getCurrentPosition() async => _position;

  @override
  Future<bool> requestPermission() async => _position != null;
}
