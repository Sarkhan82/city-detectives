// Story 1.3 – Tests unitaires OnboardingNotifier avec stockage injecté.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/onboarding/providers/onboarding_storage.dart';
import 'package:city_detectives/features/onboarding/providers/onboarding_provider.dart';

/// Stockage en mémoire pour les tests.
class FakeOnboardingStorage implements OnboardingStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }
}

void main() {
  group('OnboardingNotifier', () {
    test('build() returns false when key is missing', () async {
      final container = ProviderContainer(
        overrides: [
          onboardingStorageProvider.overrideWithValue(FakeOnboardingStorage()),
        ],
      );
      addTearDown(container.dispose);

      final completed = await container.read(
        onboardingCompletedProvider.future,
      );

      expect(completed, isFalse);
    });

    test('build() returns false when value is not "true"', () async {
      final storage = FakeOnboardingStorage();
      await storage.write('onboarding_completed', 'false');
      final container = ProviderContainer(
        overrides: [onboardingStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final completed = await container.read(
        onboardingCompletedProvider.future,
      );

      expect(completed, isFalse);
    });

    test('build() returns true when value is "true"', () async {
      final storage = FakeOnboardingStorage();
      await storage.write('onboarding_completed', 'true');
      final container = ProviderContainer(
        overrides: [onboardingStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final completed = await container.read(
        onboardingCompletedProvider.future,
      );

      expect(completed, isTrue);
    });

    test('markCompleted() writes "true" and state becomes true', () async {
      final storage = FakeOnboardingStorage();
      final container = ProviderContainer(
        overrides: [onboardingStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await container.read(onboardingCompletedProvider.future);
      await container
          .read(onboardingCompletedProvider.notifier)
          .markCompleted();

      expect(
        container.read(onboardingCompletedProvider),
        const AsyncValue.data(true),
      );
      expect(await storage.read('onboarding_completed'), 'true');
    });

    test(
      'markCompleted() then build() returns true after container refresh',
      () async {
        final storage = FakeOnboardingStorage();
        final container = ProviderContainer(
          overrides: [onboardingStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        await container
            .read(onboardingCompletedProvider.notifier)
            .markCompleted();
        container.invalidate(onboardingCompletedProvider);
        final completed = await container.read(
          onboardingCompletedProvider.future,
        );

        expect(completed, isTrue);
      },
    );
  });
}
