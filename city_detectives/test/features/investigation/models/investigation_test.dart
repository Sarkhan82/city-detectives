// TU Investigation.fromJson – cas valide, champs manquants, types inattendus.

import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/features/investigation/models/investigation.dart';

void main() {
  group('Investigation.fromJson', () {
    test('parse valid GraphQL-style JSON', () {
      final json = {
        'id': 'uuid-1',
        'titre': 'Le mystère du parc',
        'description': 'Une enquête familiale.',
        'durationEstimate': 45,
        'difficulte': 'facile',
        'isFree': true,
      };
      final inv = Investigation.fromJson(json);
      expect(inv.id, 'uuid-1');
      expect(inv.titre, 'Le mystère du parc');
      expect(inv.description, 'Une enquête familiale.');
      expect(inv.durationEstimate, 45);
      expect(inv.difficulte, 'facile');
      expect(inv.isFree, true);
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final inv = Investigation.fromJson(json);
      expect(inv.id, '');
      expect(inv.titre, '');
      expect(inv.description, '');
      expect(inv.durationEstimate, 0);
      expect(inv.difficulte, '');
      expect(inv.isFree, false);
    });

    test('handles null values with defaults', () {
      final json = {
        'id': null,
        'titre': null,
        'description': null,
        'durationEstimate': null,
        'difficulte': null,
        'isFree': null,
      };
      final inv = Investigation.fromJson(json);
      expect(inv.id, '');
      expect(inv.titre, '');
      expect(inv.description, '');
      expect(inv.durationEstimate, 0);
      expect(inv.difficulte, '');
      expect(inv.isFree, false);
    });

    test('durationEstimate from double is converted to int', () {
      final json = {
        'id': 'x',
        'titre': 'x',
        'description': 'x',
        'durationEstimate': 30.0,
        'difficulte': 'x',
        'isFree': false,
      };
      final inv = Investigation.fromJson(json);
      expect(inv.durationEstimate, 30);
    });

    test('durationEstimate from string is parsed or defaults to 0', () {
      final json = {
        'id': 'x',
        'titre': 'x',
        'description': 'x',
        'durationEstimate': '60',
        'difficulte': 'x',
        'isFree': false,
      };
      final inv = Investigation.fromJson(json);
      expect(inv.durationEstimate, 60);
    });

    test('durationEstimate invalid string defaults to 0', () {
      final json = {
        'id': 'x',
        'titre': 'x',
        'description': 'x',
        'durationEstimate': 'nope',
        'difficulte': 'x',
        'isFree': false,
      };
      final inv = Investigation.fromJson(json);
      expect(inv.durationEstimate, 0);
    });

    test('isFree only true when value is true', () {
      expect(Investigation.fromJson({'isFree': true}).isFree, true);
      expect(Investigation.fromJson({'isFree': false}).isFree, false);
      expect(Investigation.fromJson({'isFree': null}).isFree, false);
      expect(Investigation.fromJson({'isFree': 'true'}).isFree, false);
      expect(Investigation.fromJson({'isFree': 1}).isFree, false);
    });

    test('string fields convert non-string to string', () {
      final json = {
        'id': 12345,
        'titre': 42,
        'description': 99,
        'durationEstimate': 0,
        'difficulte': 'moyen',
        'isFree': false,
      };
      final inv = Investigation.fromJson(json);
      expect(inv.id, '12345');
      expect(inv.titre, '42');
      expect(inv.description, '99');
      expect(inv.difficulte, 'moyen');
    });
  });
}
