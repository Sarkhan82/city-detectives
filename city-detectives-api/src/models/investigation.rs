//! Modèle Investigation (Story 2.1, 3.1, 6.1) – catalogue enquêtes ; prix et première gratuite (FR46, FR47, FR49).

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
    /// Première enquête gratuite si true ; sinon payante avec priceAmount/priceCurrency (FR46, FR47).
    #[graphql(name = "isFree")]
    pub is_free: bool,
    /// Prix en centimes (ex. 299 = 2,99 €) ; null si is_free (FR47, FR49). u32 pour éviter montants négatifs.
    #[graphql(name = "priceAmount")]
    pub price_amount: Option<u32>,
    /// Code devise (ex. "EUR") ; null si is_free.
    #[graphql(name = "priceCurrency")]
    pub price_currency: Option<String>,
    /// Centre latitude pour la carte (Story 3.2, optionnel).
    #[graphql(name = "centerLat")]
    pub center_lat: Option<f64>,
    /// Centre longitude pour la carte (Story 3.2, optionnel).
    #[graphql(name = "centerLng")]
    pub center_lng: Option<f64>,
}

impl Investigation {
    /// Construit une Investigation depuis des champs (id en Uuid, converti en string pour l'API).
    /// Pour les enquêtes payantes : price_amount en centimes, price_currency ex. "EUR" (FR47, FR49).
    #[allow(clippy::too_many_arguments)]
    pub fn from_parts(
        id: Uuid,
        titre: String,
        description: String,
        duration_estimate: u32,
        difficulte: String,
        is_free: bool,
        price_amount: Option<u32>,
        price_currency: Option<String>,
    ) -> Self {
        Self {
            id: id.to_string(),
            titre,
            description,
            duration_estimate,
            difficulte,
            is_free,
            price_amount,
            price_currency,
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
