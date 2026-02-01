import 'package:flutter/material.dart';

import 'package:city_detectives/features/onboarding/screens/welcome_screen.dart';

/// Point d'entrée de l'application City Detectives.
/// Story 1.1 – App shell : premier écran = accueil/connexion placeholder.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Detectives',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
