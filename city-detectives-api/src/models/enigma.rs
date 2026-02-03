//! Modèle Enigma (Story 3.1, 4.1) – énigme pour une enquête ; types photo/géo et validation.

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

// --- Story 4.1 : types et validation ---

/// Énigme géolocalisation : point cible et tolérance en mètres (FR23, FR24). Exposé en GraphQL.
#[allow(dead_code)]
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct GeolocationEnigma {
    pub id: String,
    #[graphql(name = "orderIndex")]
    pub order_index: u32,
    pub titre: String,
    /// Latitude cible.
    #[graphql(name = "targetLat")]
    pub target_lat: f64,
    /// Longitude cible.
    #[graphql(name = "targetLng")]
    pub target_lng: f64,
    /// Tolérance en mètres (ex. 10 m).
    #[graphql(name = "toleranceMeters")]
    pub tolerance_meters: f64,
}

/// Énigme photo : référence ou point cible pour comparaison (FR23). Exposé en GraphQL.
#[allow(dead_code)]
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct PhotoEnigma {
    pub id: String,
    #[graphql(name = "orderIndex")]
    pub order_index: u32,
    pub titre: String,
    /// URL de référence photo (optionnel en MVP).
    #[graphql(name = "referencePhotoUrl")]
    pub reference_photo_url: Option<String>,
}

/// Énigme mots : consigne et question (réponse non exposée en API) – Story 4.2, FR25.
#[allow(dead_code)]
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct WordsEnigma {
    pub id: String,
    #[graphql(name = "orderIndex")]
    pub order_index: u32,
    pub titre: String,
    /// Consigne ou question affichée à l'utilisateur.
    pub consigne: String,
}

/// Énigme puzzle : consigne (code/règle non exposée en API) – Story 4.2, FR26.
#[allow(dead_code)]
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
pub struct PuzzleEnigma {
    pub id: String,
    #[graphql(name = "orderIndex")]
    pub order_index: u32,
    pub titre: String,
    /// Consigne affichée à l'utilisateur.
    pub consigne: String,
}

/// Payload pour validation : coordonnées (géolocalisation), photo (URL/base64), ou texte/code (mots, puzzle).
#[derive(Debug, Clone, Deserialize, InputObject)]
#[graphql(name = "ValidateEnigmaPayload")]
pub struct ValidateEnigmaPayload {
    /// Pour énigme géo : latitude utilisateur.
    #[graphql(name = "userLat")]
    pub user_lat: Option<f64>,
    /// Pour énigme géo : longitude utilisateur.
    #[graphql(name = "userLng")]
    pub user_lng: Option<f64>,
    /// Pour énigme photo : URL de la photo soumise.
    #[graphql(name = "photoUrl")]
    pub photo_url: Option<String>,
    /// Pour énigme photo : base64 de la photo (alternatif).
    #[graphql(name = "photoBase64")]
    pub photo_base64: Option<String>,
    /// Pour énigme mots : réponse texte (FR25, FR28).
    #[graphql(name = "textAnswer")]
    pub text_answer: Option<String>,
    /// Pour énigme puzzle : code ou réponse logique (FR26, FR29).
    #[graphql(name = "codeAnswer")]
    pub code_answer: Option<String>,
}

/// Résultat de la validation d'une énigme (FR28, FR29).
#[derive(Debug, Clone, Serialize, SimpleObject)]
pub struct ValidateEnigmaResult {
    pub validated: bool,
    pub message: String,
}

// --- Story 4.3 : aide contextuelle et explications (FR30, FR31, FR32) ---

/// Indices progressifs par énigme (suggestion → indice → solution). Exposé en GraphQL.
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
#[graphql(name = "EnigmaHints")]
pub struct EnigmaHints {
    /// Niveau 1 : suggestion légère.
    pub suggestion: String,
    /// Niveau 2 : indice plus direct.
    pub hint: String,
    /// Niveau 3 : solution.
    pub solution: String,
}

/// Explications historiques et contenu éducatif par énigme (FR31, FR32, FR36–FR38). Exposé en GraphQL.
#[derive(Debug, Clone, Serialize, Deserialize, SimpleObject)]
#[graphql(name = "EnigmaExplanation")]
pub struct EnigmaExplanation {
    /// Texte historique sur le lieu ou le thème de l'énigme.
    #[graphql(name = "historicalExplanation")]
    pub historical_explanation: String,
    /// Contenu éducatif sur le lieu ou le thème.
    #[graphql(name = "educationalContent")]
    pub educational_content: String,
}
