// Story 6.2 – Tests widget flux simulation achat (récap, confirmation, succès).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/core/services/payment_service.dart';
import 'package:city_detectives/features/investigation/models/investigation.dart';
import 'package:city_detectives/features/investigation/providers/payment_provider.dart';
import 'package:city_detectives/features/investigation/screens/purchase_simulation_screen.dart';

/// Mock du service paiement pour le test du flux complet (Story 5.2).
class MockPaymentService implements PaymentServiceInterface {
  @override
  Future<void> recordPurchaseIntent(String investigationId) async {}

  @override
  Future<void> simulatePurchase(String investigationId) async {}

  @override
  Future<List<String>> getUserPurchases() async => [];
}

void main() {
  testWidgets(
    'PurchaseSimulationScreen step 0 shows recap, price and Payer button',
    (WidgetTester tester) async {
      const inv = Investigation(
        id: 'inv-1',
        titre: 'Enquête payante',
        description: 'Description.',
        durationEstimate: 30,
        difficulte: 'facile',
        isFree: false,
        priceAmount: 299,
        priceCurrency: 'EUR',
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PurchaseSimulationScreen(investigation: inv),
          ),
        ),
      );

      expect(find.text('Simulation achat'), findsOneWidget);
      expect(find.text('Enquête payante'), findsOneWidget);
      expect(find.text('2,99 €'), findsOneWidget);
      expect(find.text('Payer'), findsOneWidget);
    },
  );

  testWidgets(
    'PurchaseSimulationScreen full flow: recap → confirmation → success (Story 5.2)',
    (WidgetTester tester) async {
      const inv = Investigation(
        id: 'inv-1',
        titre: 'Enquête payante',
        description: 'Description.',
        durationEstimate: 30,
        difficulte: 'facile',
        isFree: false,
        priceAmount: 299,
        priceCurrency: 'EUR',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentServiceProvider.overrideWith((ref) => MockPaymentService()),
          ],
          child: const MaterialApp(
            home: PurchaseSimulationScreen(investigation: inv),
          ),
        ),
      );

      expect(find.text('Simulation achat'), findsOneWidget);
      expect(find.text('Payer'), findsOneWidget);

      await tester.tap(find.text('Payer'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmation'), findsOneWidget);
      expect(find.text('Payer (simulé)'), findsOneWidget);

      await tester.tap(find.text('Payer (simulé)'));
      await tester.pumpAndSettle();

      expect(find.text('Achat réussi'), findsAtLeastNWidgets(1));
      expect(find.text('Fermer'), findsOneWidget);
    },
  );
}
