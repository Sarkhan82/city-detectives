// Story 3.2 – Tests widget carte (mock GeolocationService).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/core/services/geolocation_provider.dart';
import 'package:city_detectives/core/services/geolocation_service.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/providers/investigation_play_provider.dart';
import 'package:city_detectives/features/investigation/widgets/investigation_map_sheet.dart';

void main() {
  const investigationId = 'test-inv-id';

  final mockInvestigationData = InvestigationWithEnigmas(
    investigation: const Investigation(
      id: investigationId,
      titre: 'Test',
      description: 'Desc',
      durationEstimate: 30,
      difficulte: 'facile',
      isFree: true,
      centerLat: null,
      centerLng: null,
    ),
    enigmas: const [],
  );

  Widget buildTestWidget({required GeolocationService geolocationService}) {
    return ProviderScope(
      overrides: [
        geolocationServiceProvider.overrideWithValue(geolocationService),
        investigationWithEnigmasProvider(
          investigationId,
        ).overrideWith((ref) => Future.value(mockInvestigationData)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: InvestigationMapSheet(investigationId: investigationId),
        ),
      ),
    );
  }

  testWidgets('InvestigationMapSheet shows Carte title and map', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(geolocationService: _MockGeolocationService(null)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Carte'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  testWidgets('InvestigationMapSheet shows message when location unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(geolocationService: _MockGeolocationService(null)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Localisation refusée ou indisponible – la carte s\'affiche sans votre position.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'InvestigationMapSheet shows map with user position when available',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          geolocationService: _MockGeolocationService(
            const GeoPosition(latitude: 48.85, longitude: 2.35),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Carte'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(
        find.text(
          'Localisation refusée ou indisponible – la carte s\'affiche sans votre position.',
        ),
        findsNothing,
      );
    },
  );
}

class _MockGeolocationService implements GeolocationService {
  _MockGeolocationService(this._position);

  final GeoPosition? _position;

  @override
  Future<GeoPosition?> getCurrentPosition() async => _position;

  @override
  Future<bool> requestPermission() async => _position != null;
}
