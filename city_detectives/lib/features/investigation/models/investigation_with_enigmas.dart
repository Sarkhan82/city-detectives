import 'package:city_detectives/features/investigation/models/enigma.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';

/// Enquête avec liste ordonnée d'énigmes (Story 3.1) – retour de getInvestigationById.
class InvestigationWithEnigmas {
  const InvestigationWithEnigmas({
    required this.investigation,
    required this.enigmas,
  });

  final Investigation investigation;
  final List<Enigma> enigmas;
}
