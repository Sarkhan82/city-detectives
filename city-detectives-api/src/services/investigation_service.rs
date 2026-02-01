//! Service investigations (Story 2.1) – liste des enquêtes (mock en mémoire pour MVP).

use crate::models::investigation::Investigation;
use uuid::Uuid;

pub struct InvestigationService;

impl InvestigationService {
    pub fn new() -> Self {
        Self
    }

    /// Retourne la liste des enquêtes disponibles (mock pour MVP).
    pub fn list_investigations(&self) -> Vec<Investigation> {
        vec![
            Investigation::from_parts(
                Uuid::new_v4(),
                "Le mystère du parc".to_string(),
                "Une enquête familiale dans le parc central.".to_string(),
                45,
                "facile".to_string(),
                true,
            ),
            Investigation::from_parts(
                Uuid::new_v4(),
                "Les secrets du vieux quartier".to_string(),
                "Découvrez l'histoire cachée du centre-ville.".to_string(),
                90,
                "moyen".to_string(),
                false,
            ),
        ]
    }
}

impl Default for InvestigationService {
    fn default() -> Self {
        Self::new()
    }
}
