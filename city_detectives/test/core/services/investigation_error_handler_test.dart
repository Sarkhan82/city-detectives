// Story 3.4 – Tests gestion erreurs enquête (messages utilisateur).

import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/core/services/investigation_error_handler.dart';

void main() {
  group('userFriendlyInvestigationError', () {
    test('returns default message when error string is empty', () {
      expect(
        userFriendlyInvestigationError(Exception('')),
        kInvestigationLoadErrorMessage,
      );
      expect(
        userFriendlyInvestigationError(
          Exception(''),
          kInvestigationListLoadErrorMessage,
        ),
        kInvestigationListLoadErrorMessage,
      );
    });

    test('strips Exception prefix and returns first line', () {
      expect(
        userFriendlyInvestigationError(Exception('API indisponible')),
        'API indisponible',
      );
    });

    test('truncates long messages to 200 chars', () {
      final long = 'x' * 300;
      final result = userFriendlyInvestigationError(Exception(long));
      expect(result.length, 200);
    });
  });
}
