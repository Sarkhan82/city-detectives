import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:city_detectives/core/services/geolocation_provider.dart';
import 'package:city_detectives/core/services/geolocation_service.dart';
import 'package:city_detectives/features/investigation/providers/investigation_play_provider.dart';

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
                ),
                loading: () => _MapContent(
                  center: center,
                  userPosition: null,
                  showLocationUnavailableMessage: false,
                ),
                error: (_, _) => _MapContent(
                  center: center,
                  userPosition: null,
                  showLocationUnavailableMessage: true,
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
  });

  final LatLng center;
  final GeoPosition? userPosition;
  final bool showLocationUnavailableMessage;

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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
