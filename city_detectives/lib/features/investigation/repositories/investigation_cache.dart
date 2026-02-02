/// Cache local des données d'enquête (Story 3.4, FR78) – Hive, chargement <2s.
library;

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Clé de la box Hive pour le cache des enquêtes (liste et détails).
const String kInvestigationCacheBoxName = 'investigation_cache';

/// Clé pour la liste des enquêtes dans la box.
const String kCacheKeyList = 'list';

/// TTL du cache en millisecondes (1 heure) – évite de servir des données trop anciennes.
const int kInvestigationCacheTtlMs = 60 * 60 * 1000;

String _detailKey(String id) => 'inv_$id';
String _listTsKey() => '${kCacheKeyList}_ts';
String _detailTsKey(String id) => 'inv_${id}_ts';

/// Cache Hive pour liste et détails d'enquêtes (Story 3.4).
/// Chargement depuis cache en priorité (<2s) ; TTL 1h ; rafraîchissement en arrière-plan si réseau disponible.
class InvestigationCache {
  InvestigationCache(this._box, {int? ttlMs})
    : _ttlMs = ttlMs ?? kInvestigationCacheTtlMs;

  final Box<String> _box;
  final int _ttlMs;

  bool _isExpired(int? storedAtMs) {
    if (storedAtMs == null) return true;
    return DateTime.now().millisecondsSinceEpoch - storedAtMs > _ttlMs;
  }

  /// Liste des enquêtes (raw list of maps from GraphQL), ou null si absent/expiré.
  List<Map<String, dynamic>>? getCachedList() {
    final tsRaw = _box.get(_listTsKey());
    final ts = tsRaw != null ? int.tryParse(tsRaw) : null;
    if (_isExpired(ts)) return null;
    final raw = _box.get(kCacheKeyList);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return null;
    }
  }

  /// Enregistre la liste (raw from API) avec horodatage.
  Future<void> putList(List<Map<String, dynamic>> list) async {
    await _box.put(kCacheKeyList, jsonEncode(list));
    await _box.put(
      _listTsKey(),
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Détail enquête + énigmes (raw map from GraphQL investigation(id)), ou null si absent/expiré.
  Map<String, dynamic>? getCachedDetail(String investigationId) {
    final tsRaw = _box.get(_detailTsKey(investigationId));
    final ts = tsRaw != null ? int.tryParse(tsRaw) : null;
    if (_isExpired(ts)) return null;
    final raw = _box.get(_detailKey(investigationId));
    if (raw == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  /// Enregistre le détail (raw from API) avec horodatage.
  Future<void> putDetail(
    String investigationId,
    Map<String, dynamic> data,
  ) async {
    await _box.put(_detailKey(investigationId), jsonEncode(data));
    await _box.put(
      _detailTsKey(investigationId),
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }
}
