// Story 8.1 – AC 4.2 : branchement navigation au tap sur notification (GoRouter).

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/push_provider.dart';

/// Routeur GoRouter unique, avec callback push branché pour ouvrir l'enquête ou la liste (Task 4.2).
final goRouterProvider = Provider<GoRouter>((ref) {
  final push = ref.read(pushServiceProvider);
  final router = AppRouter.createRouter();
  push.setOnNotificationOpened((RemoteMessage message) {
    final data = message.data;
    final invId = data['investigation_id'];
    if (invId != null && invId.isNotEmpty) {
      router.go(AppRouter.investigationDetailPath(invId));
    } else {
      router.go(AppRouter.investigations);
    }
  });
  return router;
});
