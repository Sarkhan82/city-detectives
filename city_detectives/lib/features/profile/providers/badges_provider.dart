import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/core/graphql/graphql_client.dart';
import 'package:city_detectives/core/services/auth_provider.dart';
import 'package:city_detectives/features/profile/models/leaderboard_entry.dart';
import 'package:city_detectives/features/profile/models/user_badge.dart';
import 'package:city_detectives/features/profile/models/user_postcard.dart';
import 'package:city_detectives/features/profile/models/user_skill.dart';
import 'package:city_detectives/features/profile/repositories/gamification_repository.dart';

/// Token pour requêtes gamification (authentification requise – Story 5.2).
final _authTokenForGamificationProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return auth.getStoredToken();
});

/// Client GraphQL avec token pour les requêtes gamification.
final _gamificationGraphqlClientProvider = Provider<GraphQLClient>((ref) {
  final token = ref.watch(_authTokenForGamificationProvider).valueOrNull;
  return createGraphQLClient(authToken: token);
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final client = ref.watch(_gamificationGraphqlClientProvider);
  return GamificationRepository(client);
});

/// Badges débloqués par l'utilisateur (Story 5.2 – FR42). AsyncValue pour chargement/erreur.
final userBadgesProvider = FutureProvider<List<UserBadge>>((ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getUserBadges();
});

/// Compétences détective (Story 5.2 – FR43).
final userSkillsProvider = FutureProvider<List<UserSkill>>((ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getUserSkills();
});

/// Cartes postales virtuelles (Story 5.2 – FR44).
final userPostcardsProvider = FutureProvider<List<UserPostcard>>((ref) async {
  final repo = ref.watch(gamificationRepositoryProvider);
  return repo.getUserPostcards();
});

/// Leaderboard (Story 5.2 – FR45). Global si investigationId null.
final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String?>((
      ref,
      investigationId,
    ) async {
      final repo = ref.watch(gamificationRepositoryProvider);
      return repo.getLeaderboard(investigationId: investigationId);
    });
