// Story 3.4 – Tests indicateur statut connexion (mock connectivity).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_detectives/core/services/connectivity_provider.dart';
import 'package:city_detectives/core/services/connectivity_service.dart';
import 'package:city_detectives/shared/widgets/connectivity_status_indicator.dart';

void main() {
  testWidgets(
    'ConnectivityStatusIndicator shows offline icon when status is offline',
    (WidgetTester tester) async {
      final controller = StreamController<ConnectivityStatus>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const ConnectivityStatusIndicator(compact: true),
            ),
          ),
        ),
      );

      controller.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsNothing);
    },
  );

  testWidgets(
    'ConnectivityStatusIndicator shows online icon when status is online',
    (WidgetTester tester) async {
      final controller = StreamController<ConnectivityStatus>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const ConnectivityStatusIndicator(compact: true),
            ),
          ),
        ),
      );

      controller.add(ConnectivityStatus.online);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsNothing);
    },
  );

  testWidgets(
    'ConnectivityStatusIndicator shows degraded icon when status is degraded',
    (WidgetTester tester) async {
      final controller = StreamController<ConnectivityStatus>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const ConnectivityStatusIndicator(compact: true),
            ),
          ),
        ),
      );

      controller.add(ConnectivityStatus.degraded);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.signal_cellular_alt), findsOneWidget);
    },
  );

  testWidgets(
    'ConnectivityStatusIndicator has semantics label for accessibility',
    (WidgetTester tester) async {
      final controller = StreamController<ConnectivityStatus>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const ConnectivityStatusIndicator(compact: true),
            ),
          ),
        ),
      );

      controller.add(ConnectivityStatus.offline);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Hors ligne'), findsOneWidget);
    },
  );
}
