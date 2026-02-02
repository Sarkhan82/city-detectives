/// Modèle Investigation (Story 2.1, 3.2) – aligné sur le schéma GraphQL.
/// Champs : id, titre, description, durationEstimate, difficulte, isFree, centerLat, centerLng.
class Investigation {
  const Investigation({
    required this.id,
    required this.titre,
    required this.description,
    required this.durationEstimate,
    required this.difficulte,
    required this.isFree,
    this.centerLat,
    this.centerLng,
  });

  final String id;
  final String titre;
  final String description;

  /// Durée estimée en minutes.
  final int durationEstimate;

  /// Niveau de difficulté (ex. "facile", "moyen", "difficile").
  final String difficulte;
  final bool isFree;

  /// Centre latitude pour la carte (Story 3.2, optionnel).
  final double? centerLat;

  /// Centre longitude pour la carte (Story 3.2, optionnel).
  final double? centerLng;

  /// Parse depuis la réponse GraphQL ; défensif : null/champs manquants → valeurs par défaut.
  factory Investigation.fromJson(Map<String, dynamic> json) {
    final rawDuration = json['durationEstimate'];
    final durationEstimate = rawDuration is int
        ? rawDuration
        : (rawDuration is num
              ? rawDuration.toInt()
              : int.tryParse(rawDuration?.toString() ?? '0') ?? 0);
    final rawCenterLat = json['centerLat'];
    final centerLat = rawCenterLat is num
        ? rawCenterLat.toDouble()
        : (rawCenterLat != null
              ? double.tryParse(rawCenterLat.toString())
              : null);
    final rawCenterLng = json['centerLng'];
    final centerLng = rawCenterLng is num
        ? rawCenterLng.toDouble()
        : (rawCenterLng != null
              ? double.tryParse(rawCenterLng.toString())
              : null);
    return Investigation(
      id: json['id']?.toString() ?? '',
      titre: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      durationEstimate: durationEstimate,
      difficulte: json['difficulte']?.toString() ?? '',
      isFree: json['isFree'] == true,
      centerLat: centerLat,
      centerLng: centerLng,
    );
  }
}
