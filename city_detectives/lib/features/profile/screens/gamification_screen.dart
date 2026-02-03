import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:city_detectives/features/profile/models/leaderboard_entry.dart';
import 'package:city_detectives/features/profile/models/user_badge.dart';
import 'package:city_detectives/features/profile/models/user_postcard.dart';
import 'package:city_detectives/features/profile/models/user_skill.dart';
import 'package:city_detectives/features/profile/providers/badges_provider.dart';

/// Écran Gamification (Story 5.2 – FR42–FR45) – badges, compétences, cartes postales, leaderboard.
/// Accessible depuis l'écran progression (route /profile/gamification).
class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBadges = ref.watch(userBadgesProvider);

    return Semantics(
      label:
          'Gamification – badges, compétences, cartes postales et classement',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gamification'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Retour à la progression',
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Section Badges (FR42)
              Semantics(
                label: 'Section Badges et accomplissements',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Badges et accomplissements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              asyncBadges.when(
                data: (badges) => _BadgesSection(badges: badges),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Impossible de charger les badges.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Semantics(
                          label: 'Réessayer le chargement des badges',
                          button: true,
                          child: FilledButton.icon(
                            onPressed: () => ref.invalidate(userBadgesProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Réessayer'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Section Compétences (FR43)
              Semantics(
                label: 'Section Compétences détective',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Compétences',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ref
                  .watch(userSkillsProvider)
                  .when(
                    data: (skills) => _SkillsSection(skills: skills),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => _SectionError(
                      message: 'Impossible de charger les compétences.',
                      onRetry: () => ref.invalidate(userSkillsProvider),
                    ),
                  ),
              const SizedBox(height: 24),
              // Section Cartes postales (FR44)
              Semantics(
                label: 'Section Cartes postales virtuelles',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Cartes postales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ref
                  .watch(userPostcardsProvider)
                  .when(
                    data: (postcards) =>
                        _PostcardsSection(postcards: postcards),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => _SectionError(
                      message: 'Impossible de charger les cartes postales.',
                      onRetry: () => ref.invalidate(userPostcardsProvider),
                    ),
                  ),
              const SizedBox(height: 24),
              // Section Leaderboard (FR45)
              Semantics(
                label: 'Section Classement leaderboard',
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Classement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ref
                  .watch(leaderboardProvider(null))
                  .when(
                    data: (entries) => _LeaderboardSection(entries: entries),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => _SectionError(
                      message: 'Impossible de charger le classement.',
                      onRetry: () => ref.invalidate(leaderboardProvider(null)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.badges});

  final List<UserBadge> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return Semantics(
        label: 'Aucun badge débloqué pour le moment',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Aucun badge débloqué pour le moment. Complétez des enquêtes et des énigmes pour en gagner.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Grille de ${badges.length} badges débloqués',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _BadgeCard(badge: badge);
        },
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});

  final UserBadge badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Badge ${badge.label} : ${badge.description}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForRef(badge.iconRef),
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                badge.label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  badge.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconForRef(String ref) {
    switch (ref) {
      case 'first_investigation':
        return Icons.emoji_events;
      case 'five_enigmas':
        return Icons.extension;
      case 'city_explorer':
        return Icons.explore;
      default:
        return Icons.star;
    }
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});

  final List<UserSkill> skills;

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Semantics(
        label: 'Aucune compétence enregistrée',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Aucune compétence pour le moment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Progression des compétences détective',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: skills
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SkillTile(skill: s),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.skill});

  final UserSkill skill;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${skill.label}, niveau ${skill.level}, ${(skill.progressPercent * 100).round()}% vers le niveau suivant',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    skill.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Niveau ${skill.level}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: skill.progressPercent.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostcardsSection extends StatelessWidget {
  const _PostcardsSection({required this.postcards});

  final List<UserPostcard> postcards;

  @override
  Widget build(BuildContext context) {
    if (postcards.isEmpty) {
      return Semantics(
        label: 'Aucune carte postale débloquée',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Aucune carte postale pour le moment. Découvrez des lieux lors des enquêtes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Grille de ${postcards.length} cartes postales',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: postcards.length,
        itemBuilder: (context, index) {
          final p = postcards[index];
          return Semantics(
            label:
                'Carte postale : ${p.placeName}, débloquée le ${p.unlockedAt}',
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                        ? Image.network(
                            p.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: Icon(
                                  Icons.place,
                                  size: 48,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                              );
                            },
                            errorBuilder: (_, _, _) => Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        : Icon(
                            Icons.place,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      p.placeName,
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Semantics(
        label: 'Classement vide',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Aucun classement pour le moment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Semantics(
      label: 'Tableau des rangs du classement',
      child: Card(
        child: Column(
          children: entries.map((e) {
            final isCurrentUser = e.displayName == 'Vous';
            return Semantics(
              label:
                  'Rang ${e.rank}, ${e.displayName ?? e.userId}, ${e.score} points'
                  '${isCurrentUser ? ', c’est vous' : ''}',
              child: ListTile(
                tileColor: isCurrentUser
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                shape: isCurrentUser
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      )
                    : null,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    '${e.rank}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  e.displayName ?? e.userId,
                  style: isCurrentUser
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                trailing: Text(
                  '${e.score}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Message d'erreur avec bouton Réessayer pour une section gamification (WCAG 2.1 Level A).
class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Erreur. $message. Bouton Réessayer.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Réessayer',
              button: true,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
