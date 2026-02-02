// Story 3.4 – Tests PrecisionCircle (indicateur précision GPS).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/shared/widgets/precision_circle.dart';

void main() {
  testWidgets('PrecisionCircle hides when precision <= 10m and not compact', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrecisionCircle(accuracyMeters: 8.0, compact: false),
        ),
      ),
    );
    expect(find.byType(PrecisionCircle), findsOneWidget);
    expect(find.text('Position imprécise'), findsNothing);
  });

  testWidgets('PrecisionCircle shows message when precision > 10m', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrecisionCircle(accuracyMeters: 25.0, compact: false),
        ),
      ),
    );
    expect(find.textContaining('Position imprécise'), findsOneWidget);
    expect(find.textContaining('25'), findsOneWidget);
  });

  testWidgets(
    'PrecisionCircle shows message when accuracy is null (unstable)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrecisionCircle(accuracyMeters: null, compact: false),
          ),
        ),
      );
      expect(find.text('Position imprécise'), findsOneWidget);
    },
  );

  test('PrecisionCircle.isImprecise returns true when > 10m', () {
    expect(PrecisionCircle.isImprecise(15.0), isTrue);
    expect(PrecisionCircle.isImprecise(null), isTrue);
  });

  test('PrecisionCircle.isImprecise returns false when <= 10m', () {
    expect(PrecisionCircle.isImprecise(10.0), isFalse);
    expect(PrecisionCircle.isImprecise(5.0), isFalse);
  });
}
