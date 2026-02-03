// Story 4.1 – Tests widget énigme photo : affichage, bouton prise photo (API mockée via provider).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/enigma/providers/enigma_validation_provider.dart';
import 'package:city_detectives/features/enigma/repositories/enigma_validation_repository.dart';
import 'package:city_detectives/features/enigma/types/photo/photo_enigma_widget.dart';
import 'package:city_detectives/features/investigation/models/enigma.dart';

void main() {
  const enigma = Enigma(
    id: 'photo-1',
    orderIndex: 1,
    type: 'photo',
    titre: 'Prenez la photo du monument',
  );

  // Client factice pour tests d'affichage (pas d'appel API).
  final testClient = GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: HttpLink('http://localhost:8080/graphql'),
  );

  Widget wrapWithProviders(Widget child) {
    return ProviderScope(
      overrides: [
        enigmaValidationRepositoryProvider.overrideWith(
          (ref) => EnigmaValidationRepository(testClient),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('PhotoEnigmaWidget shows title and take photo button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(PhotoEnigmaWidget(enigma: enigma, onValidated: () {})),
    );

    expect(find.text('Prenez la photo du monument'), findsOneWidget);
    expect(find.text('Prendre une photo'), findsOneWidget);
    expect(find.text('Prenez une photo du point indiqué.'), findsOneWidget);
  });
}
