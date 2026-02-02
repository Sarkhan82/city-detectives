import 'package:hive/hive.dart';

/// Progression d'une enquête en cours (Story 3.3) – persistance Hive offline-first.
/// investigationId, index énigme courante, énigmes complétées, timestamp.
part 'investigation_progress.g.dart';

@HiveType(typeId: 0)
class InvestigationProgress {
  InvestigationProgress({
    required this.investigationId,
    required this.currentEnigmaIndex,
    required this.completedEnigmaIds,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String investigationId;

  @HiveField(1)
  final int currentEnigmaIndex;

  @HiveField(2)
  final List<String> completedEnigmaIds;

  @HiveField(3)
  final int updatedAtMs;

  DateTime get updatedAt => DateTime.fromMillisecondsSinceEpoch(updatedAtMs);
}
