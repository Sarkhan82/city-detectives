//! Modèle Investigation (Story 2.1, 3.1, 6.1, 7.2) – catalogue enquêtes ; prix, première gratuite, statut draft/publié.

use async_graphql::*;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

use crate::models::enigma::Enigma;

/// Statut de publication d'une enquête (Story 7.2, 7.3).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum InvestigationStatus {
    Draft,
    Published,
}

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
    /// Statut brouillon ou publié (Story 7.2, 7.3).
    pub status: String,
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
        status: InvestigationStatus,
        center_lat: Option<f64>,
        center_lng: Option<f64>,
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
            center_lat,
            center_lng,
            status: status_to_string(status),
        }
    }
}

fn status_to_string(s: InvestigationStatus) -> String {
    match s {
        InvestigationStatus::Draft => "draft".to_string(),
        InvestigationStatus::Published => "published".to_string(),
    }
}

/// Input pour la création d'une enquête (Story 7.2 – FR62). Champs camelCase en GraphQL.
#[derive(Debug, Clone, InputObject, Validate)]
#[graphql(name = "CreateInvestigationInput")]
pub struct CreateInvestigationInput {
    #[validate(length(min = 1, message = "Le titre est requis"))]
    pub titre: String,
    pub description: String,
    #[validate(range(min = 1, message = "La durée estimée doit être au moins 1 minute"))]
    #[graphql(name = "durationEstimate")]
    pub duration_estimate: u32,
    #[validate(length(min = 1, message = "La difficulté est requise"))]
    pub difficulte: String,
    #[graphql(name = "isFree")]
    pub is_free: bool,
    #[graphql(name = "priceAmount")]
    pub price_amount: Option<u32>,
    #[graphql(name = "priceCurrency")]
    pub price_currency: Option<String>,
    /// "draft" ou "published" ; défaut "draft" (Story 7.3).
    pub status: Option<String>,
    #[graphql(name = "centerLat")]
    pub center_lat: Option<f64>,
    #[graphql(name = "centerLng")]
    pub center_lng: Option<f64>,
}

/// Input pour la mise à jour d'une enquête (Story 7.2 – FR62). Tous les champs optionnels.
#[derive(Debug, Clone, InputObject, Default)]
#[graphql(name = "UpdateInvestigationInput")]
pub struct UpdateInvestigationInput {
    pub titre: Option<String>,
    pub description: Option<String>,
    #[graphql(name = "durationEstimate")]
    pub duration_estimate: Option<u32>,
    pub difficulte: Option<String>,
    #[graphql(name = "isFree")]
    pub is_free: Option<bool>,
    #[graphql(name = "priceAmount")]
    pub price_amount: Option<u32>,
    #[graphql(name = "priceCurrency")]
    pub price_currency: Option<String>,
    pub status: Option<String>,
    #[graphql(name = "centerLat")]
    pub center_lat: Option<f64>,
    #[graphql(name = "centerLng")]
    pub center_lng: Option<f64>,
}

/// Enquête avec liste ordonnée d'énigmes (Story 3.1) – retour de getInvestigationById.
#[derive(Debug, Clone, SimpleObject)]
pub struct InvestigationWithEnigmas {
    pub investigation: Investigation,
    pub enigmas: Vec<Enigma>,
}
