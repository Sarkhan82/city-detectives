/// Analytics utilisateurs pour le dashboard admin (Story 7.4 – FR69).
class UserAnalytics {
  const UserAnalytics({
    required this.activeUserCount,
    required this.totalCompletions,
  });

  final int activeUserCount;
  final int totalCompletions;

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      activeUserCount: (json['activeUserCount'] as num?)?.toInt() ?? 0,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
    );
  }
}
