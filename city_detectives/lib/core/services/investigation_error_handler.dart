/// Gestion des erreurs enquête (Story 3.4, FR84) – messages explicites utilisateur, log pour debug.
library;

import 'package:flutter/foundation.dart';

/// Message utilisateur pour erreur de chargement enquête (non technique).
const String kInvestigationLoadErrorMessage =
    'Impossible de charger l\'enquête. Vérifiez votre connexion.';

/// Message utilisateur pour erreur de chargement liste enquêtes.
const String kInvestigationListLoadErrorMessage =
    'Impossible de charger les enquêtes. Vérifiez votre connexion.';

/// Retourne un message lisible pour l'utilisateur (sans stack ni détail technique).
String userFriendlyInvestigationError(
  Object error, [
  String defaultMessage = kInvestigationLoadErrorMessage,
]) {
  final s = error.toString();
  final withoutException = s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  final firstLine = withoutException.split('\n').first.trim();
  if (firstLine.length > 200) return firstLine.substring(0, 200);
  if (firstLine.isEmpty) return defaultMessage;
  return firstLine;
}

/// Log l'erreur (stack, contexte) pour debug / Sentry ; ne pas exposer à l'utilisateur.
void logInvestigationError(Object error, [StackTrace? stackTrace]) {
  if (kDebugMode) {
    debugPrint(
      'InvestigationError: $error\n${stackTrace ?? StackTrace.current}',
    );
  }
}
