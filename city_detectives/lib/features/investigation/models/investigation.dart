/// Modèle Investigation (Story 2.1, 3.2, 6.1, 7.2, 7.3) – aligné sur le schéma GraphQL.
/// Champs : id, titre, description, durationEstimate, difficulte, isFree, priceAmount, priceCurrency, centerLat, centerLng, status (admin).
class Investigation {
  const Investigation({
    required this.id,
    required this.titre,
    required this.description,
    required this.durationEstimate,
    required this.difficulte,
    required this.isFree,
    this.priceAmount,
    this.priceCurrency,
    this.centerLat,
    this.centerLng,
    this.status,
  });

  final String id;
  final String titre;
  final String description;

  /// Durée estimée en minutes.
  final int durationEstimate;

  /// Niveau de difficulté (ex. "facile", "moyen", "difficile").
  final String difficulte;
  final bool isFree;

  /// Prix en centimes (ex. 299 = 2,99 €) ; null si isFree (FR47, FR49).
  final int? priceAmount;

  /// Code devise (ex. "EUR") ; null si isFree.
  final String? priceCurrency;

  /// Centre latitude pour la carte (Story 3.2, optionnel).
  final double? centerLat;

  /// Centre longitude pour la carte (Story 3.2, optionnel).
  final double? centerLng;

  /// Statut brouillon/publié (Story 7.2, 7.3 – présent pour les appels admin).
  final String? status;

  /// Formatte le prix pour affichage (ex. "2,99 €"). Retourne null si pas de prix.
  String? get formattedPrice {
    if (priceAmount == null || priceCurrency == null) return null;
    final units = priceAmount! ~/ 100;
    final cents = priceAmount! % 100;
    final symbol = priceCurrency == 'EUR' ? '€' : priceCurrency;
    final centsStr = cents.toString().padLeft(2, '0');
    return '$units,$centsStr $symbol';
  }

  /// Parse depuis la réponse GraphQL ; défensif : null/champs manquants → valeurs par défaut.
  factory Investigation.fromJson(Map<String, dynamic> json) {
    final rawDuration = json['durationEstimate'];
    final durationEstimate = rawDuration is int
        ? rawDuration
        : (rawDuration is num
              ? rawDuration.toInt()
              : int.tryParse(rawDuration?.toString() ?? '0') ?? 0);
    final rawPriceAmount = json['priceAmount'];
    final int? priceAmount = rawPriceAmount == null
        ? null
        : (rawPriceAmount is int
              ? rawPriceAmount
              : (rawPriceAmount is num
                    ? rawPriceAmount.toInt()
                    : int.tryParse(rawPriceAmount.toString())));
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
      priceAmount: priceAmount,
      priceCurrency: json['priceCurrency']?.toString(),
      centerLat: centerLat,
      centerLng: centerLng,
      status: json['status']?.toString(),
    );
  }
}
