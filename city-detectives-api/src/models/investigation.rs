//! Modèle Investigation (Story 2.1, 3.1) – catalogue enquêtes ; InvestigationWithEnigmas pour query par id.

use async_graphql::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::models::enigma::Enigma;

/// Enquête exposée en GraphQL (champs camelCase en API ; id en UUID string).
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct Investigation {
    /// ID opaque (UUID) en string pour l'API.
    pub id: String,
    pub titre: String,
    pub description: String,
    /// Durée estimée en minutes.
    #[graphql(name = "durationEstimate")]
    pub duration_estimate: u32,
    /// Niveau de difficulté (ex. "facile", "moyen", "difficile").
    pub difficulte: String,
    #[graphql(name = "isFree")]
    pub is_free: bool,
    /// Centre latitude pour la carte (Story 3.2, optionnel).
    #[graphql(name = "centerLat")]
    pub center_lat: Option<f64>,
    /// Centre longitude pour la carte (Story 3.2, optionnel).
    #[graphql(name = "centerLng")]
    pub center_lng: Option<f64>,
}

impl Investigation {
    /// Construit une Investigation depuis des champs (id en Uuid, converti en string pour l'API).
    pub fn from_parts(
        id: Uuid,
        titre: String,
        description: String,
        duration_estimate: u32,
        difficulte: String,
        is_free: bool,
    ) -> Self {
        Self {
            id: id.to_string(),
            titre,
            description,
            duration_estimate,
            difficulte,
            is_free,
            center_lat: None,
            center_lng: None,
        }
    }
}

/// Enquête avec liste ordonnée d'énigmes (Story 3.1) – retour de getInvestigationById.
#[derive(Debug, Clone, SimpleObject)]
pub struct InvestigationWithEnigmas {
    pub investigation: Investigation,
    pub enigmas: Vec<Enigma>,
}
