// Story 4.4 (Task 5.2) – Tests écran LORE : affichage titre/texte, bouton Sauter, action saut (API mockée).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/investigation/models/lore_content.dart';
import 'package:city_detectives/features/investigation/providers/investigation_list_provider.dart';
import 'package:city_detectives/features/investigation/repositories/investigation_repository.dart';
import 'package:city_detectives/features/enigma/screens/lore_screen.dart';

void main() {
  Widget wrapWithProviders(Widget child, InvestigationRepository repo) {
    return ProviderScope(
      overrides: [investigationRepositoryProvider.overrideWith((ref) => repo)],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('LoreScreen shows loading then LORE content and Sauter button', (
    WidgetTester tester,
  ) async {
    final fake = _FakeLoreRepository();
    await tester.pumpWidget(
      wrapWithProviders(
        LoreScreen(
          investigationId: 'inv-1',
          sequenceIndex: 0,
          onContinue: () {},
        ),
        fake,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('Contexte'), findsOneWidget);
    expect(find.text('Titre LORE mock'), findsOneWidget);
    expect(find.textContaining('Texte narratif mock'), findsOneWidget);
    expect(find.text('Sauter'), findsAtLeastNWidgets(1));
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('LoreScreen Sauter button calls onContinue', (
    WidgetTester tester,
  ) async {
    var continueCalled = false;
    final fake = _FakeLoreRepository();
    await tester.pumpWidget(
      wrapWithProviders(
        LoreScreen(
          investigationId: 'inv-1',
          sequenceIndex: 0,
          onContinue: () => continueCalled = true,
        ),
        fake,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Sauter').first);
    await tester.pumpAndSettle();

    expect(continueCalled, isTrue);
  });

  testWidgets('LoreScreen Continuer button calls onContinue', (
    WidgetTester tester,
  ) async {
    var continueCalled = false;
    final fake = _FakeLoreRepository();
    await tester.pumpWidget(
      wrapWithProviders(
        LoreScreen(
          investigationId: 'inv-1',
          sequenceIndex: 0,
          onContinue: () => continueCalled = true,
        ),
        fake,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(continueCalled, isTrue);
  });

  testWidgets('LoreScreen shows empty state when getLoreContent returns null', (
    WidgetTester tester,
  ) async {
    final fake = _FakeLoreRepositoryNull();
    await tester.pumpWidget(
      wrapWithProviders(
        LoreScreen(
          investigationId: 'inv-1',
          sequenceIndex: 99,
          onContinue: () {},
        ),
        fake,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Aucun contenu à cet emplacement.'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('LoreScreen shows media section when mediaUrls is not empty', (
    WidgetTester tester,
  ) async {
    final fake = _FakeLoreRepositoryWithMedia();
    await tester.pumpWidget(
      wrapWithProviders(
        LoreScreen(
          investigationId: 'inv-1',
          sequenceIndex: 0,
          onContinue: () {},
        ),
        fake,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Titre LORE mock'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}

class _FakeLoreRepository extends InvestigationRepository {
  _FakeLoreRepository()
    : super(
        GraphQLClient(
          cache: GraphQLCache(store: InMemoryStore()),
          link: HttpLink('http://localhost:8080/graphql'),
        ),
      );

  @override
  Future<LoreContent?> getLoreContent({
    required String investigationId,
    required int sequenceIndex,
  }) async {
    return const LoreContent(
      sequenceIndex: 0,
      title: 'Titre LORE mock',
      contentText: 'Texte narratif mock pour le test.',
      mediaUrls: [],
    );
  }
}

class _FakeLoreRepositoryNull extends InvestigationRepository {
  _FakeLoreRepositoryNull()
    : super(
        GraphQLClient(
          cache: GraphQLCache(store: InMemoryStore()),
          link: HttpLink('http://localhost:8080/graphql'),
        ),
      );

  @override
  Future<LoreContent?> getLoreContent({
    required String investigationId,
    required int sequenceIndex,
  }) async {
    return null;
  }
}

class _FakeLoreRepositoryWithMedia extends InvestigationRepository {
  _FakeLoreRepositoryWithMedia()
    : super(
        GraphQLClient(
          cache: GraphQLCache(store: InMemoryStore()),
          link: HttpLink('http://localhost:8080/graphql'),
        ),
      );

  @override
  Future<LoreContent?> getLoreContent({
    required String investigationId,
    required int sequenceIndex,
  }) async {
    return const LoreContent(
      sequenceIndex: 0,
      title: 'Titre LORE mock',
      contentText: 'Texte avec média.',
      mediaUrls: ['https://example.com/lore.jpg'],
    );
  }
}
