/// Carte postale virtuelle (Story 5.2 – FR44). Aligné sur le schéma GraphQL.
class UserPostcard {
  const UserPostcard({
    required this.id,
    required this.placeName,
    this.imageUrl,
    required this.unlockedAt,
  });

  final String id;
  final String placeName;
  final String? imageUrl;
  final String unlockedAt;

  static UserPostcard? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'] as String?;
    final placeName = json['placeName'] as String?;
    if (id == null || placeName == null) return null;
    return UserPostcard(
      id: id,
      placeName: placeName,
      imageUrl: json['imageUrl'] as String?,
      unlockedAt: json['unlockedAt'] as String? ?? '',
    );
  }
}
