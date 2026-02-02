import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:city_detectives/core/services/geolocation_provider.dart';
import 'package:city_detectives/core/services/geolocation_service.dart';
import 'package:city_detectives/core/services/permission_service.dart';
import 'package:city_detectives/features/investigation/providers/investigation_play_provider.dart';
import 'package:city_detectives/shared/widgets/precision_circle.dart';

/// Centre par défaut (Paris) si l'enquête n'a pas de zone (Story 3.2).
const LatLng _defaultMapCenter = LatLng(48.8566, 2.3522);
const double _defaultZoom = 13.0;

/// Bottom sheet « Voir la carte » (Story 3.2) – carte interactive, position utilisateur.
class InvestigationMapSheet extends ConsumerWidget {
  const InvestigationMapSheet({super.key, required this.investigationId});

  final String investigationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invAsync = ref.watch(
      investigationWithEnigmasProvider(investigationId),
    );
    final positionAsync = ref.watch(
      currentPositionForMapProvider(investigationId),
    );

    final center =
        invAsync.valueOrNull?.investigation.centerLat != null &&
            invAsync.valueOrNull?.investigation.centerLng != null
        ? LatLng(
            invAsync.valueOrNull!.investigation.centerLat!,
            invAsync.valueOrNull!.investigation.centerLng!,
          )
        : _defaultMapCenter;

    return Semantics(
      label:
          'Carte interactive de l\'enquête. Position actuelle affichée si disponible.',
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Carte'),
              trailing: Semantics(
                label: 'Fermer la carte',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Flexible(
              child: positionAsync.when(
                data: (position) => _MapContent(
                  center: center,
                  userPosition: position,
                  showLocationUnavailableMessage: position == null,
                  showLocationRationale: false,
                ),
                loading: () => _MapContent(
                  center: center,
                  userPosition: null,
                  showLocationUnavailableMessage: false,
                  showLocationRationale: true,
                ),
                error: (_, _) => _MapContent(
                  center: center,
                  userPosition: null,
                  showLocationUnavailableMessage: true,
                  showLocationRationale: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapContent extends StatelessWidget {
  const _MapContent({
    required this.center,
    required this.userPosition,
    this.showLocationUnavailableMessage = false,
    this.showLocationRationale = false,
  });

  final LatLng center;
  final GeoPosition? userPosition;
  final bool showLocationUnavailableMessage;
  final bool showLocationRationale;

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    if (userPosition != null) {
      markers.add(
        Marker(
          point: LatLng(userPosition!.latitude, userPosition!.longitude),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Semantics(
            label: 'Position actuelle',
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
        ),
      );
    }

    final showPrecisionIndicator =
        userPosition != null &&
        PrecisionCircle.isImprecise(userPosition!.accuracyMeters);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLocationRationale)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              liveRegion: true,
              label: 'Justification de la permission de localisation',
              child: Text(
                PermissionRationale.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (showLocationUnavailableMessage)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                'Localisation refusée ou indisponible – la carte s\'affiche sans votre position.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (showPrecisionIndicator)
          PrecisionCircle(accuracyMeters: userPosition!.accuracyMeters),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: _defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.citydetectives.app',
              ),
              if (markers.isNotEmpty) MarkerLayer(markers: markers),
            ],
          ),
        ),
      ],
    );
  }
}
