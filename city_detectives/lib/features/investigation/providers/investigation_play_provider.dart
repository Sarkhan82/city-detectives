import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/features/investigation/models/investigation_with_enigmas.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';

/// Enquête par id avec liste ordonnée d'énigmes (Story 3.1) – AsyncValue pour écran « enquête en cours ».
final investigationWithEnigmasProvider =
    FutureProvider.family<InvestigationWithEnigmas?, String>((
      ref,
      investigationId,
    ) async {
      final repo = ref.watch(investigationRepositoryProvider);
      return repo.getInvestigationById(investigationId);
    });

/// Index de l'énigme courante (Story 3.1) – état immuable, mise à jour via notifier.
/// Family par investigationId pour isoler l'état par enquête.
final currentEnigmaIndexProvider = StateProvider.family<int, String>(
  (ref, investigationId) => 0,
);
