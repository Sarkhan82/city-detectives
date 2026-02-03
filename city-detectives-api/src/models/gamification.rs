//! Modèles gamification (Story 5.2 – FR42–FR45) – badges, compétences, cartes postales, leaderboard.

use async_graphql::*;
use serde::{Deserialize, Serialize};

/// Badge débloqué par un utilisateur – Story 5.2 FR42. Exposé en GraphQL (camelCase).
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct UserBadge {
    #[graphql(name = "badgeId")]
    pub badge_id: String,
    pub code: String,
    pub label: String,
    pub description: String,
    #[graphql(name = "iconRef")]
    pub icon_ref: String,
    #[graphql(name = "unlockedAt")]
    pub unlocked_at: String,
}

/// Compétence détective avec niveau / XP – Story 5.2 FR43. Exposé en GraphQL (camelCase).
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct UserSkill {
    pub code: String,
    pub label: String,
    /// Niveau (entier, ex. 1–5).
    pub level: i32,
    /// Progression vers le niveau suivant (0.0–1.0) ou XP actuel selon UX.
    #[graphql(name = "progressPercent")]
    pub progress_percent: f64,
}

/// Carte postale virtuelle (lieu découvert) – Story 5.2 FR44. Exposé en GraphQL (camelCase).
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct UserPostcard {
    pub id: String,
    #[graphql(name = "placeName")]
    pub place_name: String,
    #[graphql(name = "imageUrl")]
    pub image_url: Option<String>,
    #[graphql(name = "unlockedAt")]
    pub unlocked_at: String,
}

/// Entrée leaderboard – Story 5.2 FR45. Exposé en GraphQL (camelCase).
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct LeaderboardEntry {
    pub rank: i32,
    #[graphql(name = "userId")]
    pub user_id: String,
    pub score: i64,
    #[graphql(name = "displayName")]
    pub display_name: Option<String>,
}
