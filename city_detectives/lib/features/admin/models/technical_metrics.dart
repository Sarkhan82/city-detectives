/// Métriques techniques pour le dashboard admin (Story 7.4 – FR68).
class TechnicalMetrics {
  const TechnicalMetrics({
    required this.healthStatus,
    this.apiLatencyAvgMs,
    this.apiLatencyP95Ms,
    required this.errorRate,
    required this.crashCount,
    this.sentryDashboardUrl,
  });

  final String healthStatus;
  final double? apiLatencyAvgMs;
  final double? apiLatencyP95Ms;
  final double errorRate;
  final int crashCount;
  final String? sentryDashboardUrl;

  factory TechnicalMetrics.fromJson(Map<String, dynamic> json) {
    return TechnicalMetrics(
      healthStatus: json['healthStatus'] as String? ?? 'unknown',
      apiLatencyAvgMs: (json['apiLatencyAvgMs'] as num?)?.toDouble(),
      apiLatencyP95Ms: (json['apiLatencyP95Ms'] as num?)?.toDouble(),
      errorRate: (json['errorRate'] as num?)?.toDouble() ?? 0.0,
      crashCount: (json['crashCount'] as num?)?.toInt() ?? 0,
      sentryDashboardUrl: json['sentryDashboardUrl'] as String?,
    );
  }
}
