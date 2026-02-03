// Story 4.2 – Tests widget énigme mots : affichage, saisie, envoi, affichage résultat (API mockée).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';
import 'package:city_detectives/features/enigma/types/words/words_enigma_widget.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';

void main() {
  const enigma = Enigma(
    id: 'words-1',
    orderIndex: 1,
    type: 'words',
    titre: 'Quel mot est lié à la ville ?',
  );

  Widget wrapWithProviders(Widget child, EnigmaValidationRepository? repo) {
    final repository = repo ?? _FakeWordsRepository();
    return ProviderScope(
      overrides: [
        enigmaValidationRepositoryProvider.overrideWith((ref) => repository),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('WordsEnigmaWidget shows title, consigne and submit button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        WordsEnigmaWidget(enigma: enigma, onValidated: () {}),
        null,
      ),
    );

    expect(find.text('Quel mot est lié à la ville ?'), findsOneWidget);
    expect(find.text('Valider ma réponse'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets(
    'WordsEnigmaWidget submit shows result when API returns success',
    (WidgetTester tester) async {
      final fake = _FakeWordsRepository(
        result: const ValidateEnigmaResult(
          validated: true,
          message: 'Bravo, c\'est la bonne réponse !',
        ),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          WordsEnigmaWidget(enigma: enigma, onValidated: () {}),
          fake,
        ),
      );

      await tester.enterText(find.byType(TextField), 'paris');
      await tester.tap(find.text('Valider ma réponse'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Bravo, c\'est la bonne réponse !'), findsOneWidget);
    },
  );

  testWidgets(
    'WordsEnigmaWidget submit shows error message when API returns invalid',
    (WidgetTester tester) async {
      final fake = _FakeWordsRepository(
        result: const ValidateEnigmaResult(
          validated: false,
          message: 'Ce n\'est pas la bonne réponse. Réessayez.',
        ),
      );
      await tester.pumpWidget(
        wrapWithProviders(
          WordsEnigmaWidget(enigma: enigma, onValidated: () {}),
          fake,
        ),
      );

      await tester.enterText(find.byType(TextField), 'lyon');
      await tester.tap(find.text('Valider ma réponse'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Ce n\'est pas la bonne réponse. Réessayez.'),
        findsOneWidget,
      );
    },
  );
}

/// Repository factice pour tests – retourne un résultat configurable pour validateWords.
class _FakeWordsRepository extends EnigmaValidationRepository {
  _FakeWordsRepository({ValidateEnigmaResult? result})
    : _result =
          result ??
          const ValidateEnigmaResult(
            validated: true,
            message: 'Bravo, c\'est la bonne réponse !',
          ),
      super(_dummyClient);

  static final _dummyClient = GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: HttpLink('http://localhost:8080/graphql'),
  );

  final ValidateEnigmaResult _result;

  @override
  Future<ValidateEnigmaResult> validateWords({
    required String enigmaId,
    required String textAnswer,
  }) async => _result;
}
