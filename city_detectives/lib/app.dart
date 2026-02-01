import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:city_detectives/core/router/app_router.dart';

/// Point d'entrée City Detectives (Story 1.1 + 1.2).
/// GoRouter pour welcome / register / home.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'City Detectives',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.createRouter(),
      ),
    );
  }
}
