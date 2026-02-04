import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/router/app_router_provider.dart';
import 'package:city_detectives/core/services/push_provider.dart';

/// Point d'entrée City Detectives (Story 1.1 + 1.2).
/// GoRouter pour welcome / register / home.
/// Story 8.1 : enregistrement du token push quand l'utilisateur est connecté ; navigation au tap (AC 4.2) via goRouterProvider.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          ref.watch(pushRegistrationProvider);
          return MaterialApp.router(
            title: 'City Detectives',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
              useMaterial3: true,
            ),
            routerConfig: ref.watch(goRouterProvider),
          );
        },
      ),
    );
  }
}
