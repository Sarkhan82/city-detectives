/// Modèle contenu LORE (Story 4.4 – FR34, FR37) – séquence narrative par enquête.
class LoreContent {
  const LoreContent({
    required this.sequenceIndex,
    required this.title,
    required this.contentText,
    required this.mediaUrls,
  });

  final int sequenceIndex;
  final String title;
  final String contentText;
  final List<String> mediaUrls;

  factory LoreContent.fromJson(Map<String, dynamic> json) {
    final rawIndex = json['sequenceIndex'];
    final sequenceIndex = rawIndex is int
        ? rawIndex
        : (rawIndex is num
              ? rawIndex.toInt()
              : int.tryParse(rawIndex?.toString() ?? '0') ?? 0);
    final mediaRaw = json['mediaUrls'];
    final mediaUrls = mediaRaw is List
        ? mediaRaw
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];
    return LoreContent(
      sequenceIndex: sequenceIndex,
      title: json['title']?.toString() ?? '',
      contentText: json['contentText']?.toString() ?? '',
      mediaUrls: mediaUrls,
    );
  }
}
