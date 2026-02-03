// Story 5.1 – Tests unitaires repository enquêtes complétées (FR41).

import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/investigation/repositories/completed_investigation_repository.dart';

void main() {
  group('CompletedInvestigationRepository (forTest)', () {
    late CompletedInvestigationRepository repo;

    setUp(() {
      repo = CompletedInvestigationRepository.forTest();
    });

    test('isCompleted returns false when none completed', () {
      expect(repo.isCompleted('inv-1'), isFalse);
    });

    test('getCompletedOrderedByDate returns empty when none', () {
      expect(repo.getCompletedOrderedByDate(), isEmpty);
    });

    test('getCompletedInvestigationIds returns empty when none', () {
      expect(repo.getCompletedInvestigationIds(), isEmpty);
    });

    test('markCompleted then isCompleted returns true', () async {
      await repo.markCompleted('inv-1');
      expect(repo.isCompleted('inv-1'), isTrue);
    });

    test(
      'markCompleted then getCompletedOrderedByDate returns one entry',
      () async {
        await repo.markCompleted('inv-1');
        final list = repo.getCompletedOrderedByDate();
        expect(list.length, 1);
        expect(list.first.investigationId, 'inv-1');
        expect(list.first.completedAtMs, greaterThan(0));
      },
    );

    test('markCompleted twice for same id overwrites (single entry)', () async {
      await repo.markCompleted('inv-1');
      await Future.delayed(const Duration(milliseconds: 2));
      await repo.markCompleted('inv-1');
      final list = repo.getCompletedOrderedByDate();
      expect(list.length, 1);
      expect(list.first.investigationId, 'inv-1');
    });

    test('getCompletedOrderedByDate returns most recent first', () async {
      await repo.markCompleted('inv-first');
      await Future.delayed(const Duration(milliseconds: 2));
      await repo.markCompleted('inv-second');
      final list = repo.getCompletedOrderedByDate();
      expect(list.length, 2);
      expect(list[0].investigationId, 'inv-second');
      expect(list[1].investigationId, 'inv-first');
    });

    test('getCompletedInvestigationIds returns all completed ids', () async {
      await repo.markCompleted('inv-a');
      await repo.markCompleted('inv-b');
      final ids = repo.getCompletedInvestigationIds();
      expect(ids, containsAll(['inv-a', 'inv-b']));
      expect(ids.length, 2);
    });
  });
}
