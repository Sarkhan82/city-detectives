import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:city_detectives/features/profile/models/leaderboard_entry.dart';
import 'package:city_detectives/features/profile/models/user_badge.dart';
import 'package:city_detectives/features/profile/models/user_postcard.dart';
import 'package:city_detectives/features/profile/models/user_skill.dart';

/// Repository gamification (Story 5.2 – FR42) – badges, compétences, cartes postales, leaderboard.
class GamificationRepository {
  GamificationRepository(this._client);

  final GraphQLClient _client;

  static const String _getUserBadgesQuery = r'''
    query GetUserBadges {
      getUserBadges {
        badgeId
        code
        label
        description
        iconRef
        unlockedAt
      }
    }
  ''';

  static const String _getUserSkillsQuery = r'''
    query GetUserSkills {
      getUserSkills {
        code
        label
        level
        progressPercent
      }
    }
  ''';

  static const String _getUserPostcardsQuery = r'''
    query GetUserPostcards {
      getUserPostcards {
        id
        placeName
        imageUrl
        unlockedAt
      }
    }
  ''';

  static const String _getLeaderboardQuery = r'''
    query GetLeaderboard($investigationId: String) {
      getLeaderboard(investigationId: $investigationId) {
        rank
        userId
        score
        displayName
      }
    }
  ''';

  /// Liste des badges débloqués pour l'utilisateur courant (requiert authentification).
  Future<List<UserBadge>> getUserBadges() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getUserBadgesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) {
      throw result.exception!;
    }
    final data = result.data;
    if (data == null) return [];
    final list = data['getUserBadges'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => UserBadge.fromJson(e as Map<String, dynamic>))
        .whereType<UserBadge>()
        .toList();
  }

  /// Compétences détective pour l'utilisateur courant (FR43).
  Future<List<UserSkill>> getUserSkills() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getUserSkillsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final list = result.data?['getUserSkills'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => UserSkill.fromJson(e as Map<String, dynamic>))
        .whereType<UserSkill>()
        .toList();
  }

  /// Cartes postales pour l'utilisateur courant (FR44).
  Future<List<UserPostcard>> getUserPostcards() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getUserPostcardsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final list = result.data?['getUserPostcards'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => UserPostcard.fromJson(e as Map<String, dynamic>))
        .whereType<UserPostcard>()
        .toList();
  }

  /// Leaderboard global ou par enquête (FR45). investigationId optionnel.
  Future<List<LeaderboardEntry>> getLeaderboard({
    String? investigationId,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getLeaderboardQuery),
        variables: {'investigationId': investigationId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final list = result.data?['getLeaderboard'] as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .whereType<LeaderboardEntry>()
        .toList();
  }
}
