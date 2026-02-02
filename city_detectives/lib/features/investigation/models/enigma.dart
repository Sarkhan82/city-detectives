/// Modèle Enigma (Story 3.1) – aligné sur le schéma GraphQL.
/// Champs : id, orderIndex, type, titre.
class Enigma {
  const Enigma({
    required this.id,
    required this.orderIndex,
    required this.type,
    required this.titre,
  });

  final String id;
  final int orderIndex;
  final String type;
  final String titre;

  factory Enigma.fromJson(Map<String, dynamic> json) {
    final rawOrder = json['orderIndex'];
    final orderIndex = rawOrder is int
        ? rawOrder
        : (rawOrder is num
              ? rawOrder.toInt()
              : int.tryParse(rawOrder?.toString() ?? '0') ?? 0);
    return Enigma(
      id: json['id']?.toString() ?? '',
      orderIndex: orderIndex,
      type: json['type']?.toString() ?? 'text',
      titre: json['titre']?.toString() ?? '',
    );
  }
}
