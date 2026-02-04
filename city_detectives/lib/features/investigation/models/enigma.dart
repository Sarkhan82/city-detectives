/// Modèle Enigma (Story 3.1, 4.1, 4.3, 7.2) – aligné sur le schéma GraphQL.
/// Champs principaux : id, orderIndex, type, titre.
/// Champs optionnels pour l’édition admin (Story 7.2 – FR63, FR64) :
/// investigationId, coordonnées cibles, tolérance, consigne, explications
/// historiques/éducatives, état de validation du contenu historique.
class Enigma {
  const Enigma({
    required this.id,
    required this.orderIndex,
    required this.type,
    required this.titre,
    this.investigationId,
    this.targetLat,
    this.targetLng,
    this.toleranceMeters,
    this.referencePhotoUrl,
    this.consigne,
    this.hintSuggestion,
    this.hintHint,
    this.hintSolution,
    this.historicalExplanation,
    this.educationalContent,
    this.historicalContentValidated,
  });

  final String id;
  final int orderIndex;
  final String type;
  final String titre;
  final String? investigationId;
  final double? targetLat;
  final double? targetLng;
  final double? toleranceMeters;
  final String? referencePhotoUrl;
  final String? consigne;
  final String? hintSuggestion;
  final String? hintHint;
  final String? hintSolution;
  final String? historicalExplanation;
  final String? educationalContent;
  final bool? historicalContentValidated;

  factory Enigma.fromJson(Map<String, dynamic> json) {
    final rawOrder = json['orderIndex'];
    final orderIndex = rawOrder is int
        ? rawOrder
        : (rawOrder is num
              ? rawOrder.toInt()
              : int.tryParse(rawOrder?.toString() ?? '0') ?? 0);
    final rawTargetLat = json['targetLat'];
    final targetLat = rawTargetLat is num
        ? rawTargetLat.toDouble()
        : (rawTargetLat != null
              ? double.tryParse(rawTargetLat.toString())
              : null);
    final rawTargetLng = json['targetLng'];
    final targetLng = rawTargetLng is num
        ? rawTargetLng.toDouble()
        : (rawTargetLng != null
              ? double.tryParse(rawTargetLng.toString())
              : null);
    final rawTolerance = json['toleranceMeters'];
    final toleranceMeters = rawTolerance is num
        ? rawTolerance.toDouble()
        : (rawTolerance != null
              ? double.tryParse(rawTolerance.toString())
              : null);

    return Enigma(
      id: json['id']?.toString() ?? '',
      orderIndex: orderIndex,
      type: json['type']?.toString() ?? 'text',
      titre: json['titre']?.toString() ?? '',
      investigationId: json['investigationId']?.toString(),
      targetLat: targetLat,
      targetLng: targetLng,
      toleranceMeters: toleranceMeters,
      referencePhotoUrl: json['referencePhotoUrl']?.toString(),
      consigne: json['consigne']?.toString(),
      hintSuggestion: json['hintSuggestion']?.toString(),
      hintHint: json['hintHint']?.toString(),
      hintSolution: json['hintSolution']?.toString(),
      historicalExplanation: json['historicalExplanation']?.toString(),
      educationalContent: json['educationalContent']?.toString(),
      historicalContentValidated:
          json['historicalContentValidated'] as bool? ?? null,
    );
  }
}
