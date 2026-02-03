import 'package:hive/hive.dart';

/// Enquête marquée comme complétée (Story 5.1) – persistance Hive pour historique.
/// Enregistré quand l'utilisateur valide la dernière énigme d'une enquête (FR41).
part 'completed_investigation.g.dart';

@HiveType(typeId: 1)
class CompletedInvestigation {
  CompletedInvestigation({
    required this.investigationId,
    required this.completedAtMs,
  });

  @HiveField(0)
  final String investigationId;

  @HiveField(1)
  final int completedAtMs;

  DateTime get completedAt =>
      DateTime.fromMillisecondsSinceEpoch(completedAtMs);
}
