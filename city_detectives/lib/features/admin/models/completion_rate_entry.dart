/// Taux de complétion par enquête pour le dashboard admin (Story 7.4 – FR70).
class CompletionRateEntry {
  const CompletionRateEntry({
    required this.investigationId,
    required this.investigationTitle,
    required this.startedCount,
    required this.completedCount,
    required this.completionRate,
  });

  final String investigationId;
  final String investigationTitle;
  final int startedCount;
  final int completedCount;
  final double completionRate;

  factory CompletionRateEntry.fromJson(Map<String, dynamic> json) {
    return CompletionRateEntry(
      investigationId: json['investigationId'] as String? ?? '',
      investigationTitle: json['investigationTitle'] as String? ?? '',
      startedCount: (json['startedCount'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
