import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/admin/screens/dashboard_screen.dart';

/// Garde de route admin (Story 7.1 – FR61, 7.3). Redirige vers home si l'utilisateur n'est pas admin.
/// Quand [child] est fourni (ShellRoute), affiche l'enfant ; sinon le dashboard.
class AdminRouteGuard extends ConsumerWidget {
  const AdminRouteGuard({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user?.isAdmin != true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRouter.home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child ?? const DashboardScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(AppRouter.home);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
