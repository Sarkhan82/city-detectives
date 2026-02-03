import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';
import 'package:city_detectives/features/investigation/repositories/completed_investigation_repository.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';

/// Statut d'une enquête pour l'écran progression (Story 5.1, FR39).
enum InvestigationStatus { notStarted, inProgress, completed }

/// Entrée « enquête + statut » pour la liste de l'écran progression (Story 5.1).
class InvestigationStatusEntry {
  const InvestigationStatusEntry({
    required this.investigation,
    required this.status,
  });

  final Investigation investigation;
  final InvestigationStatus status;
}

/// Entrée historique : enquête complétée avec date (Story 5.1, FR41).
class CompletedHistoryEntry {
  const CompletedHistoryEntry({
    required this.investigationId,
    required this.title,
    required this.completedAt,
    this.investigation,
  });

  final String investigationId;
  final String title;
  final DateTime completedAt;

  /// Enquête complète si encore dans la liste (pour navigation détail avec extra).
  final Investigation? investigation;
}

/// Données agrégées pour l'écran Profil / Progression (Story 5.1, FR39, FR40, FR41).
class UserProgressData {
  const UserProgressData({
    required this.entries,
    required this.completedCount,
    required this.totalCount,
    required this.history,
  });

  /// Liste des enquêtes avec statut (non démarrée / en cours / complétée).
  final List<InvestigationStatusEntry> entries;

  /// Nombre d'enquêtes complétées (FR40).
  final int completedCount;

  /// Nombre total d'enquêtes.
  final int totalCount;

  /// Historique des complétées, ordonné par date (plus récent en premier) (FR41).
  final List<CompletedHistoryEntry> history;
}

/// Provider qui agrège liste enquêtes + progression Hive + enquêtes complétées (Story 5.1).
final userProgressDataProvider = FutureProvider<UserProgressData>((ref) async {
  final list = await ref.watch(investigationListProvider.future);
  final progressRepo = ref.read(investigationProgressRepositoryProvider);
  final completedRepo = ref.read(completedInvestigationRepositoryProvider);

  final inProgressIds = progressRepo.getInProgressInvestigationIds().toSet();
  final completedIds = completedRepo.getCompletedInvestigationIds();
  final completedOrdered = completedRepo.getCompletedOrderedByDate();

  final entries = list.map((inv) {
    InvestigationStatus status;
    if (completedIds.contains(inv.id)) {
      status = InvestigationStatus.completed;
    } else if (inProgressIds.contains(inv.id)) {
      status = InvestigationStatus.inProgress;
    } else {
      status = InvestigationStatus.notStarted;
    }
    return InvestigationStatusEntry(investigation: inv, status: status);
  }).toList();

  final idToTitle = {for (final inv in list) inv.id: inv.titre};
  final idToInv = {for (final inv in list) inv.id: inv};
  final history = completedOrdered
      .map(
        (c) => CompletedHistoryEntry(
          investigationId: c.investigationId,
          title: idToTitle[c.investigationId] ?? c.investigationId,
          completedAt: c.completedAt,
          investigation: idToInv[c.investigationId],
        ),
      )
      .toList();

  return UserProgressData(
    entries: entries,
    completedCount: completedIds.length,
    totalCount: list.length,
    history: history,
  );
});
