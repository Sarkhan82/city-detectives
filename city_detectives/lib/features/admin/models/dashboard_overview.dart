/// Vue d'ensemble du dashboard admin (Story 7.1 – FR61). Aligné avec le type GraphQL DashboardOverview.
class DashboardOverview {
  const DashboardOverview({
    required this.investigationCount,
    required this.publishedCount,
    required this.draftCount,
    required this.enigmaCount,
  });

  final int investigationCount;
  final int publishedCount;
  final int draftCount;
  final int enigmaCount;

  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    return DashboardOverview(
      investigationCount: (json['investigationCount'] as num?)?.toInt() ?? 0,
      publishedCount: (json['publishedCount'] as num?)?.toInt() ?? 0,
      draftCount: (json['draftCount'] as num?)?.toInt() ?? 0,
      enigmaCount: (json['enigmaCount'] as num?)?.toInt() ?? 0,
    );
  }
}
