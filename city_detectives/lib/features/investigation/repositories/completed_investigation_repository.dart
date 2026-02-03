import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:city_detectives/features/investigation/models/completed_investigation.dart';

/// Nom de la box Hive pour les enquêtes complétées (Story 5.1, FR41).
const String kCompletedInvestigationBoxName = 'completed_investigations';

/// Repository de persistance des enquêtes complétées (Story 5.1).
/// Enregistré quand la dernière énigme est validée ; utilisé pour statut et historique.
class CompletedInvestigationRepository {
  CompletedInvestigationRepository(this._box) : _testList = null;

  /// Pour les tests : repository en mémoire sans Hive.
  CompletedInvestigationRepository.forTest() : _box = null, _testList = [];

  final Box<CompletedInvestigation>? _box;
  final List<CompletedInvestigation>? _testList;

  List<CompletedInvestigation> _getAll() {
    final box = _box;
    if (box != null) {
      return box.values.toList();
    }
    return List<CompletedInvestigation>.from(_testList ?? []);
  }

  /// Enregistre une enquête comme complétée (date de complétion = maintenant).
  Future<void> markCompleted(String investigationId) async {
    final record = CompletedInvestigation(
      investigationId: investigationId,
      completedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    final box = _box;
    if (box != null) {
      await box.put(investigationId, record);
    } else {
      // Mode forTest() uniquement : _testList est toujours [] (non null).
      // Si _testList était null, la liste mutée ne serait pas persistée.
      final list = _testList ?? [];
      list.removeWhere((e) => e.investigationId == investigationId);
      list.add(record);
    }
  }

  /// Indique si l'enquête est marquée complétée.
  bool isCompleted(String investigationId) {
    final box = _box;
    if (box != null) return box.containsKey(investigationId);
    return (_testList ?? []).any((e) => e.investigationId == investigationId);
  }

  /// Historique des enquêtes complétées, ordonné par date de complétion (plus récent en premier).
  List<CompletedInvestigation> getCompletedOrderedByDate() {
    final list = _getAll();
    list.sort((a, b) => b.completedAtMs.compareTo(a.completedAtMs));
    return list;
  }

  /// Ids des enquêtes complétées (pour filtre statut).
  Set<String> getCompletedInvestigationIds() {
    return _getAll().map((e) => e.investigationId).toSet();
  }
}

final completedInvestigationRepositoryProvider =
    Provider<CompletedInvestigationRepository>((ref) {
      final box = Hive.box<CompletedInvestigation>(
        kCompletedInvestigationBoxName,
      );
      return CompletedInvestigationRepository(box);
    });
