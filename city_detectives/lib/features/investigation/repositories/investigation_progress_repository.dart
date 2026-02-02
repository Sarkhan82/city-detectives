import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:city_detectives/features/investigation/models/investigation_progress.dart';

/// Nom de la box Hive pour la progression des enquêtes (Story 3.3).
const String kInvestigationProgressBoxName = 'investigation_progress';

/// Repository de persistance de la progression d'enquête (Story 3.3).
/// Lecture/écriture Hive ; pas de dépendance backend obligatoire pour 3.3.
class InvestigationProgressRepository {
  InvestigationProgressRepository(this._box) : _testMap = null;

  /// Pour les tests : repository en mémoire sans Hive (Story 3.3 Task 5.1).
  InvestigationProgressRepository.forTest()
    : _box = null,
      _testMap = <String, InvestigationProgress>{};

  final Box<InvestigationProgress>? _box;
  final Map<String, InvestigationProgress>? _testMap;

  /// Récupère la progression sauvegardée pour une enquête, ou null.
  InvestigationProgress? getProgress(String investigationId) {
    if (_box != null) return _box.get(investigationId);
    return _testMap![investigationId];
  }

  /// Sauvegarde la progression (écrase si existante).
  Future<void> saveProgress(InvestigationProgress progress) async {
    if (_box != null) {
      await _box.put(progress.investigationId, progress);
    } else {
      _testMap![progress.investigationId] = progress;
    }
  }

  /// Liste des ids d'enquêtes ayant une progression sauvegardée (en cours).
  List<String> getInProgressInvestigationIds() {
    if (_box != null) {
      return _box.keys.whereType<String>().toList();
    }
    return _testMap!.keys.toList();
  }

  /// Supprime la progression d'une enquête (optionnel, ex. après complétion).
  Future<void> deleteProgress(String investigationId) async {
    if (_box != null) {
      await _box.delete(investigationId);
    } else {
      _testMap!.remove(investigationId);
    }
  }
}

final investigationProgressRepositoryProvider =
    Provider<InvestigationProgressRepository>((ref) {
      final box = Hive.box<InvestigationProgress>(
        kInvestigationProgressBoxName,
      );
      return InvestigationProgressRepository(box);
    });
