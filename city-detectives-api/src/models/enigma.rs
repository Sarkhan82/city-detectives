//! Modèle Enigma (Story 3.1) – énigme pour une enquête : id, ordre, type, titre.

use async_graphql::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Énigme exposée en GraphQL (champs camelCase en API).
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct Enigma {
    /// ID opaque (UUID) en string pour l'API.
    pub id: String,
    /// Index d'ordre dans l'enquête (1-based pour affichage).
    #[graphql(name = "orderIndex")]
    pub order_index: u32,
    /// Type d'énigme (ex. "text", "photo", "geolocation") – résolution réelle = Epic 4.
    #[graphql(name = "type")]
    pub enigma_type: String,
    /// Titre ou description minimale pour l'affichage.
    pub titre: String,
}

impl Enigma {
    pub fn from_parts(id: Uuid, order_index: u32, enigma_type: String, titre: String) -> Self {
        Self {
            id: id.to_string(),
            order_index,
            enigma_type,
            titre,
        }
    }
}
