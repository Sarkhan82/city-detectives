//! Service gamification (Story 5.2 – FR42, FR43, FR44, FR45) – badges, compétences, cartes postales, leaderboard.
//! Données mock / dérivées de la progression pour V1.0.

use crate::models::gamification::{LeaderboardEntry, UserBadge, UserPostcard, UserSkill};
use uuid::Uuid;

/// Service gamification – badges, compétences, cartes postales, leaderboard (Story 5.2).
pub struct GamificationService;

impl GamificationService {
    pub fn new() -> Self {
        Self
    }

    /// Badges débloqués par l'utilisateur (FR42). Pour V1.0 : données mock dérivées de la progression.
    /// En production : déblocage basé sur enquêtes complétées, énigmes résolues, etc.
    pub fn get_user_badges(&self, _user_id: Uuid) -> Vec<UserBadge> {
        // Mock : badges débloqués pour démo (V1.0). À remplacer par logique basée sur progression.
        const UNLOCKED_AT: &str = "2026-02-03T12:00:00Z";
        vec![
            UserBadge {
                badge_id: Uuid::nil().to_string(),
                code: "first_investigation".to_string(),
                label: "Première enquête".to_string(),
                description: "Vous avez complété votre première enquête.".to_string(),
                icon_ref: "first_investigation".to_string(),
                unlocked_at: UNLOCKED_AT.to_string(),
            },
            UserBadge {
                badge_id: Uuid::nil().to_string(),
                code: "five_enigmas".to_string(),
                label: "5 énigmes résolues".to_string(),
                description: "Vous avez résolu 5 énigmes.".to_string(),
                icon_ref: "five_enigmas".to_string(),
                unlocked_at: UNLOCKED_AT.to_string(),
            },
            UserBadge {
                badge_id: Uuid::nil().to_string(),
                code: "city_explorer".to_string(),
                label: "Ville explorée".to_string(),
                description: "Vous avez exploré une ville lors d'une enquête.".to_string(),
                icon_ref: "city_explorer".to_string(),
                unlocked_at: UNLOCKED_AT.to_string(),
            },
        ]
    }

    /// Compétences détective par utilisateur (FR43). Pour V1.0 : données mock.
    pub fn get_user_skills(&self, _user_id: Uuid) -> Vec<UserSkill> {
        vec![
            UserSkill {
                code: "exploration".to_string(),
                label: "Exploration".to_string(),
                level: 2,
                progress_percent: 0.6,
            },
            UserSkill {
                code: "resolution".to_string(),
                label: "Résolution".to_string(),
                level: 3,
                progress_percent: 0.2,
            },
            UserSkill {
                code: "speed".to_string(),
                label: "Rapidité".to_string(),
                level: 1,
                progress_percent: 0.8,
            },
        ]
    }

    /// Cartes postales virtuelles par utilisateur (FR44). Pour V1.0 : mock (IDs fixes pour déterministe).
    pub fn get_user_postcards(&self, _user_id: Uuid) -> Vec<UserPostcard> {
        const POSTCARD_1_ID: &str = "a0000001-0000-0000-0000-000000000001";
        const POSTCARD_2_ID: &str = "a0000002-0000-0000-0000-000000000002";
        vec![
            UserPostcard {
                id: POSTCARD_1_ID.to_string(),
                place_name: "Place du centre".to_string(),
                image_url: None,
                unlocked_at: "2026-02-03T12:00:00Z".to_string(),
            },
            UserPostcard {
                id: POSTCARD_2_ID.to_string(),
                place_name: "Monument historique".to_string(),
                image_url: None,
                unlocked_at: "2026-02-03T14:30:00Z".to_string(),
            },
        ]
    }

    /// Leaderboard global (FR45). Pour V1.0 : mock (IDs fixes pour déterministe). investigation_id optionnel pour filtre par enquête.
    pub fn get_leaderboard(
        &self,
        _user_id: Uuid,
        _investigation_id: Option<Uuid>,
    ) -> Vec<LeaderboardEntry> {
        const USER_1_ID: &str = "b0000001-0000-0000-0000-000000000001";
        const USER_2_ID: &str = "b0000002-0000-0000-0000-000000000002";
        vec![
            LeaderboardEntry {
                rank: 1,
                user_id: USER_1_ID.to_string(),
                score: 1250,
                display_name: Some("Détective A".to_string()),
            },
            LeaderboardEntry {
                rank: 2,
                user_id: USER_2_ID.to_string(),
                score: 980,
                display_name: Some("Explorateur B".to_string()),
            },
            LeaderboardEntry {
                rank: 3,
                user_id: _user_id.to_string(),
                score: 750,
                display_name: Some("Vous".to_string()),
            },
        ]
    }
}

impl Default for GamificationService {
    fn default() -> Self {
        Self::new()
    }
}
