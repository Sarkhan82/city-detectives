import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/features/onboarding/screens/onboarding_screen.dart';
import 'package:city_detectives/features/onboarding/screens/register_screen.dart';
import 'package:city_detectives/features/onboarding/screens/welcome_screen.dart';

/// Routes (Story 1.2 + 1.3) – welcome, register, onboarding, home post-login.
class AppRouter {
  AppRouter._();

  static const String welcome = '/';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: welcome,
      routes: [
        GoRoute(path: welcome, builder: (context, _) => const WelcomeScreen()),
        GoRoute(
          path: register,
          builder: (context, _) => const RegisterScreen(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: home,
          builder: (context, _) => Scaffold(
            appBar: AppBar(title: const Text('City Detectives')),
            body: const Center(child: Text('Bienvenue – vous êtes connecté.')),
          ),
        ),
      ],
    );
  }
}
