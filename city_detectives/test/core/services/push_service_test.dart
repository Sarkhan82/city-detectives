// Story 8.1 – tests pour PushService (plateforme, enregistrement backend quand token vide).

import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/core/services/push_service.dart';

void main() {
  group('PushService', () {
    test('platform returns android, ios, or unknown', () {
      final p = PushService.platform;
      expect(p, isNotEmpty);
      expect(
        ['android', 'ios', 'unknown'].contains(p),
        isTrue,
        reason: 'platform should be android, ios, or unknown',
      );
    });

    test('registerWithBackend returns false when fcm token is empty', () async {
      final push = PushService();

      final ok = await push.registerWithBackend('jwt', '');

      expect(ok, isFalse);
    });

    test('registerWithBackend returns false when fcm token is null and getToken would return null', () async {
      final push = PushService();
      await push.ensureInitialized();
      final ok = await push.registerWithBackend('jwt');
      expect(ok, isFalse);
    });
  });
}
