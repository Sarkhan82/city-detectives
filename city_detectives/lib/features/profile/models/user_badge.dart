/// Modèle badge utilisateur (Story 5.2 – FR42). Aligné sur le schéma GraphQL.
class UserBadge {
  const UserBadge({
    required this.badgeId,
    required this.code,
    required this.label,
    required this.description,
    required this.iconRef,
    required this.unlockedAt,
  });

  final String badgeId;
  final String code;
  final String label;
  final String description;
  final String iconRef;
  final String unlockedAt;

  /// Parse depuis un map (réponse GraphQL).
  static UserBadge? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final badgeId = json['badgeId'] as String?;
    final code = json['code'] as String?;
    final label = json['label'] as String?;
    final description = json['description'] as String?;
    final iconRef = json['iconRef'] as String?;
    final unlockedAt = json['unlockedAt'] as String?;
    if (badgeId == null || code == null || label == null) return null;
    return UserBadge(
      badgeId: badgeId,
      code: code,
      label: label,
      description: description ?? '',
      iconRef: iconRef ?? '',
      unlockedAt: unlockedAt ?? '',
    );
  }
}
