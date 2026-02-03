/// Entrée leaderboard (Story 5.2 – FR45). Aligné sur le schéma GraphQL.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.score,
    this.displayName,
  });

  final int rank;
  final String userId;
  final int score;
  final String? displayName;

  static LeaderboardEntry? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final rank = json['rank'] as int?;
    final userId = json['userId'] as String?;
    final score = json['score'] as int?;
    if (rank == null || userId == null || score == null) return null;
    return LeaderboardEntry(
      rank: rank,
      userId: userId,
      score: score,
      displayName: json['displayName'] as String?,
    );
  }
}
