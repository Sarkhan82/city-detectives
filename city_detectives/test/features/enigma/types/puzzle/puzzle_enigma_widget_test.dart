// Story 4.2 – Tests widget énigme puzzle : affichage, saisie, envoi, affichage résultat (API mockée).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';
import 'package:city_detectives/features/enigma/types/puzzle/puzzle_enigma_widget.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';

void main() {
  const enigma = Enigma(
    id: 'puzzle-1',
    orderIndex: 1,
    type: 'puzzle',
    titre: 'Entrez le code',
  );

  Widget wrapWithProviders(Widget child, EnigmaValidationRepository? repo) {
    final repository = repo ?? _FakePuzzleRepository();
    return ProviderScope(
      overrides: [
        enigmaValidationRepositoryProvider.overrideWith((ref) => repository),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('PuzzleEnigmaWidget shows title, consigne and submit button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        PuzzleEnigmaWidget(enigma: enigma, onValidated: () {}),
        null,
      ),
    );

    expect(find.text('Entrez le code'), findsOneWidget);
    expect(find.text('Valider le code'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
    'PuzzleEnigmaWidget submit shows result when API returns success',
    (WidgetTester tester) async {
      final fake = _FakePuzzleRepository(
        result: const ValidateEnigmaResult(
          validated: true,
          message: 'Code correct ! Enigme résolue.',
        ),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          PuzzleEnigmaWidget(enigma: enigma, onValidated: () {}),
          fake,
        ),
      );

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Valider le code'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Code correct ! Enigme résolue.'), findsOneWidget);
    },
  );

  testWidgets(
    'PuzzleEnigmaWidget submit shows error when API returns invalid',
    (WidgetTester tester) async {
      final fake = _FakePuzzleRepository(
        result: const ValidateEnigmaResult(
          validated: false,
          message: 'Code incorrect. Réessayez.',
        ),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          PuzzleEnigmaWidget(enigma: enigma, onValidated: () {}),
          fake,
        ),
      );

      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.text('Valider le code'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Code incorrect. Réessayez.'), findsOneWidget);
    },
  );
}

/// Repository factice pour tests – retourne un résultat configurable pour validatePuzzle.
class _FakePuzzleRepository extends EnigmaValidationRepository {
  _FakePuzzleRepository({ValidateEnigmaResult? result})
    : _result =
          result ??
          const ValidateEnigmaResult(
            validated: true,
            message: 'Code correct ! Enigme résolue.',
          ),
      super(_dummyClient);

  static final _dummyClient = GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: HttpLink('http://localhost:8080/graphql'),
  );

  final ValidateEnigmaResult _result;

  @override
  Future<ValidateEnigmaResult> validatePuzzle({
    required String enigmaId,
    required String codeAnswer,
  }) async => _result;
}
