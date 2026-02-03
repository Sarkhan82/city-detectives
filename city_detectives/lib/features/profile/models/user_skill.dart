/// Modèle compétence détective (Story 5.2 – FR43). Aligné sur le schéma GraphQL.
class UserSkill {
  const UserSkill({
    required this.code,
    required this.label,
    required this.level,
    required this.progressPercent,
  });

  final String code;
  final String label;
  final int level;
  final double progressPercent;

  static UserSkill? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final code = json['code'] as String?;
    final label = json['label'] as String?;
    if (code == null || label == null) return null;
    final level = json['level'] as int? ?? 0;
    final progressPercent =
        (json['progressPercent'] as num?)?.toDouble() ?? 0.0;
    return UserSkill(
      code: code,
      label: label,
      level: level,
      progressPercent: progressPercent,
    );
  }
}
