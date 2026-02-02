/// Service de gestion des permissions (Story 3.4) – GPS, caméra, stockage.
/// Fournit les messages de justification (FR75) et les demandes au moment approprié (FR74).
library;

import 'package:permission_handler/permission_handler.dart';

/// Messages de justification pour chaque type de permission (FR75).
abstract class PermissionRationale {
  /// Pour afficher la position sur la carte et les énigmes géolocalisées.
  static const String location =
      'Pour afficher votre position sur la carte et lors des énigmes géolocalisées, '
      'l\'accès à la localisation est nécessaire.';

  /// Pour les énigmes photo (Epic 4).
  static const String camera =
      'Pour prendre une photo lors des énigmes, l\'accès à la caméra est nécessaire. '
      'Vous pourrez choisir une photo de la galerie si vous refusez.';

  /// Pour enregistrer des données localement (cache, progression).
  static const String storage =
      'Pour enregistrer la progression et les données d\'enquête en local, '
      'l\'accès au stockage peut être demandé.';
}

/// Service centralisé pour demander les permissions (Story 3.4).
/// GPS : demandé via [GeolocationService.requestPermission] (geolocator) avant carte ;
/// caméra : avant première énigme photo (Epic 4) ; stockage : si écriture locale.
class PermissionService {
  /// Demande la permission caméra (à appeler avant première énigme photo, Epic 4).
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Demande la permission stockage / photos (si écriture locale).
  Future<bool> requestStorage() async {
    final status = await Permission.storage.request();
    return status.isGranted || status.isLimited;
  }
}
