// Story 4.1 – Tests widget énigme géolocalisation : affichage, envoi position (geolocation_service et API mockés).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/services/geolocation_provider.dart';
import 'package:city_detectives/core/services/geolocation_service.dart';
import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';
import 'package:city_detectives/features/enigma/types/geolocation/geolocation_enigma_widget.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';

void main() {
  const enigma = Enigma(
    id: 'geo-1',
    orderIndex: 1,
    type: 'geolocation',
    titre: 'Rendez-vous au point indiqué',
  );

  final testClient = GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: HttpLink('http://localhost:8080/graphql'),
  );

  Widget wrapWithProviders(Widget child) {
    return ProviderScope(
      overrides: [
        geolocationServiceProvider.overrideWithValue(
          _FakeGeolocationService(
            position: const GeoPosition(
              latitude: 48.8566,
              longitude: 2.3522,
              accuracyMeters: 5.0,
            ),
          ),
        ),
        enigmaValidationRepositoryProvider.overrideWith(
          (ref) => EnigmaValidationRepository(testClient),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('GeolocationEnigmaWidget shows title and validate button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        GeolocationEnigmaWidget(enigma: enigma, onValidated: () {}),
      ),
    );

    expect(find.text('Rendez-vous au point indiqué'), findsOneWidget);
    expect(find.text('Valider ma position'), findsOneWidget);
    expect(
      find.textContaining(
        'Rendez-vous au point indiqué, puis validez votre position',
      ),
      findsOneWidget,
    );
  });
}

/// Fake géolocalisation pour tests – retourne une position fixe.
class _FakeGeolocationService implements GeolocationService {
  _FakeGeolocationService({this.position});

  final GeoPosition? position;

  @override
  Future<GeoPosition?> getCurrentPosition() async => position;

  @override
  Future<bool> requestPermission() async => true;
}
