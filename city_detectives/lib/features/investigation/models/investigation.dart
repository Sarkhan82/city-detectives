/// Modèle Investigation (Story 2.1) – aligné sur le schéma GraphQL.
/// Champs : id, titre, description, durationEstimate, difficulte, isFree.
class Investigation {
  const Investigation({
    required this.id,
    required this.titre,
    required this.description,
    required this.durationEstimate,
    required this.difficulte,
    required this.isFree,
  });

  final String id;
  final String titre;
  final String description;

  /// Durée estimée en minutes.
  final int durationEstimate;

  /// Niveau de difficulté (ex. "facile", "moyen", "difficile").
  final String difficulte;
  final bool isFree;

  /// Parse depuis la réponse GraphQL ; défensif : null/champs manquants → valeurs par défaut.
  factory Investigation.fromJson(Map<String, dynamic> json) {
    final rawDuration = json['durationEstimate'];
    final durationEstimate = rawDuration is int
        ? rawDuration
        : (rawDuration is num
              ? rawDuration.toInt()
              : int.tryParse(rawDuration?.toString() ?? '0') ?? 0);
    return Investigation(
      id: json['id']?.toString() ?? '',
      titre: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      durationEstimate: durationEstimate,
      difficulte: json['difficulte']?.toString() ?? '',
      isFree: json['isFree'] == true,
    );
  }
}
