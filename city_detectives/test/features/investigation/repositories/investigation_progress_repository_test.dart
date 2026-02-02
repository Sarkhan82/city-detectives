// Story 3.3 Task 5.1 – Tests unitaires repository progression (écriture/lecture avec test box).

import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/investigation/models/investigation_progress.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_progress_repository.dart';

void main() {
  group('InvestigationProgressRepository (forTest)', () {
    late InvestigationProgressRepository repo;

    setUp(() {
      repo = InvestigationProgressRepository.forTest();
    });

    test('getInProgressInvestigationIds returns empty when no progress', () {
      expect(repo.getInProgressInvestigationIds(), isEmpty);
    });

    test('getProgress returns null when no progress for id', () {
      expect(repo.getProgress('inv-1'), isNull);
    });

    test('saveProgress then getProgress returns same data', () async {
      final progress = InvestigationProgress(
        investigationId: 'inv-1',
        currentEnigmaIndex: 2,
        completedEnigmaIds: ['e1', 'e2'],
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      await repo.saveProgress(progress);

      final loaded = repo.getProgress('inv-1');
      expect(loaded, isNotNull);
      expect(loaded!.investigationId, 'inv-1');
      expect(loaded.currentEnigmaIndex, 2);
      expect(loaded.completedEnigmaIds, ['e1', 'e2']);
    });

    test('getInProgressInvestigationIds returns ids after save', () async {
      await repo.saveProgress(
        InvestigationProgress(
          investigationId: 'inv-a',
          currentEnigmaIndex: 0,
          completedEnigmaIds: [],
          updatedAtMs: 0,
        ),
      );
      await repo.saveProgress(
        InvestigationProgress(
          investigationId: 'inv-b',
          currentEnigmaIndex: 1,
          completedEnigmaIds: ['e1'],
          updatedAtMs: 0,
        ),
      );

      final ids = repo.getInProgressInvestigationIds();
      expect(ids, containsAll(['inv-a', 'inv-b']));
      expect(ids.length, 2);
    });

    test('saveProgress overwrites existing progress for same id', () async {
      await repo.saveProgress(
        InvestigationProgress(
          investigationId: 'inv-1',
          currentEnigmaIndex: 0,
          completedEnigmaIds: [],
          updatedAtMs: 0,
        ),
      );
      await repo.saveProgress(
        InvestigationProgress(
          investigationId: 'inv-1',
          currentEnigmaIndex: 3,
          completedEnigmaIds: ['e1', 'e2', 'e3'],
          updatedAtMs: 1000,
        ),
      );

      final loaded = repo.getProgress('inv-1');
      expect(loaded!.currentEnigmaIndex, 3);
      expect(loaded.completedEnigmaIds, ['e1', 'e2', 'e3']);
    });

    test('deleteProgress removes progress', () async {
      await repo.saveProgress(
        InvestigationProgress(
          investigationId: 'inv-1',
          currentEnigmaIndex: 0,
          completedEnigmaIds: [],
          updatedAtMs: 0,
        ),
      );
      expect(repo.getProgress('inv-1'), isNotNull);

      await repo.deleteProgress('inv-1');
      expect(repo.getProgress('inv-1'), isNull);
      expect(repo.getInProgressInvestigationIds(), isEmpty);
    });
  });
}
