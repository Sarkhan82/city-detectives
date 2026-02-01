import 'package:flutter/material.dart';

/// Écran d'accueil placeholder – Story 1.1 (FR1).
/// Affiche un premier écran au lancement (accueil ou connexion).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Semantics(
          label:
              'Écran d\'accueil City Detectives. L\'expérience d\'enquête urbaine.',
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'City Detectives',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'L\'expérience d\'enquête urbaine',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'Continuer vers la connexion ou l\'onboarding',
                    button: true,
                    child: FilledButton(
                      onPressed: () {
                        // Placeholder – navigation vers connexion/onboarding en Story 1.2/1.3
                      },
                      child: const Text('Continuer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
