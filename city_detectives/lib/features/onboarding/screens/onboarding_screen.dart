import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/core/router/app_router.dart';
import 'package:city_detectives/features/onboarding/providers/onboarding_provider.dart';

/// Écran onboarding (Story 1.3) : 3 étapes – première enquête gratuite, LORE, guidage.
/// Design « carnet de détective » ; WCAG 2.1 Level A.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _nextOrFinish() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingCompletedProvider.notifier).markCompleted();
    if (!mounted) return;
    context.go(AppRouter.investigations);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Onboarding City Detectives – présentation de la première enquête, LORE et guidage',
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _FirstEnquiryPage(key: ValueKey('page_0')),
                    _LorePage(key: ValueKey('page_1')),
                    _GuidePage(key: ValueKey('page_2')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentPage == _totalPages - 1) ...[
                      Semantics(
                        label: 'Voir la liste des enquêtes',
                        button: true,
                        child: TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text('Voir les enquêtes'),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PageIndicator(
                          current: _currentPage,
                          total: _totalPages,
                        ),
                        Semantics(
                          label: _currentPage < _totalPages - 1
                              ? 'Étape suivante'
                              : 'Démarrer l\'enquête – terminer l\'onboarding',
                          button: true,
                          child: FilledButton(
                            onPressed: _nextOrFinish,
                            child: Text(
                              _currentPage < _totalPages - 1
                                  ? 'Suivant'
                                  : 'Démarrer l\'enquête',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indicateur d'étapes (points).
class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key, required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Étape ${current + 1} sur $total',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) {
          final isActive = i == current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// Page 1 : Première enquête gratuite (titre, description, durée/difficulté).
class _FirstEnquiryPage extends StatelessWidget {
  const _FirstEnquiryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Présentation de la première enquête gratuite',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Semantics(
              label: 'Badge gratuit',
              child: Chip(
                label: const Text('Gratuit'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                'Votre première enquête',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le Mystère de la Place Centrale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Découvrez le patrimoine du centre-ville à travers une enquête '
              'de 45 minutes. Résolvez des énigmes, collectez des indices '
              'et débloquez l\'histoire cachée des lieux.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '~45 min',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 24),
                Icon(
                  Icons.signal_cellular_alt,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Facile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Page 2 : Concept City Detectives et LORE (carnet de détective).
class _LorePage extends StatelessWidget {
  const _LorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Concept City Detectives et univers des détectives',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                'City Detectives',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre carnet de détective',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Vous êtes un détective en herbe. Chaque enquête est une page '
              'de votre carnet : vous collectez des indices, résolvez des '
              'énigmes et révélez l\'histoire oubliée des lieux. Le LORE des '
              'City Detectives unit toutes les enquêtes en une grande aventure.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                '« Chaque lieu a une histoire. Votre mission : la découvrir. »',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page 3 : Guidage – navigation, objectif, CTA.
class _GuidePage extends StatelessWidget {
  const _GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Guidage d\'usage – comment naviguer et objectif d\'une enquête',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                'Comment jouer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _GuideItem(
              icon: Icons.map_outlined,
              title: 'Naviguer',
              text:
                  'Utilisez la carte et les indications pour vous déplacer '
                  'entre les points d\'énigmes.',
            ),
            const SizedBox(height: 16),
            _GuideItem(
              icon: Icons.extension_outlined,
              title: 'Résoudre les énigmes',
              text:
                  'Chaque énigme peut demander une photo, un lieu, des mots '
                  'ou un puzzle. Suivez les consignes à l\'écran.',
            ),
            const SizedBox(height: 16),
            _GuideItem(
              icon: Icons.auto_stories_outlined,
              title: 'Découvrir',
              text:
                  'En résolvant les énigmes, vous débloquez l\'histoire et '
                  'le patrimoine des lieux.',
            ),
            const SizedBox(height: 24),
            Text(
              'Vous pouvez démarrer votre première enquête ou consulter '
              'la liste des enquêtes disponibles.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title : $text',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
