// Story 2.2 – Tests widget PriceChip (Gratuit / Payant).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/shared/widgets/price_chip.dart';

void main() {
  testWidgets('PriceChip shows Gratuit when isFree is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PriceChip(isFree: true))),
    );

    expect(find.text('Gratuit'), findsOneWidget);
    expect(find.text('Payant'), findsNothing);
  });

  testWidgets('PriceChip shows Payant when isFree is false', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: PriceChip(isFree: false))),
    );

    expect(find.text('Payant'), findsOneWidget);
    expect(find.text('Gratuit'), findsNothing);
  });
}
