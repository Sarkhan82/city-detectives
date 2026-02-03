//! Service investigations (Story 2.1, 3.1, 4.1) – liste des enquêtes ; enquête par id avec énigmes (mock MVP).
//! Les énigmes sont fournies par EnigmaService pour des IDs déterministes et la validation (Story 4.1).

use crate::models::investigation::{Investigation, InvestigationWithEnigmas};
use crate::services::enigma_service::EnigmaService;
use std::sync::Arc;
use uuid::Uuid;

/// IDs fixes pour les enquêtes mock (Story 3.1) – permet de retrouver une enquête par id.
const MOCK_INV_1: Uuid = uuid::uuid!("11111111-1111-1111-1111-111111111111");
const MOCK_INV_2: Uuid = uuid::uuid!("22222222-2222-2222-2222-222222222222");

pub struct InvestigationService {
    enigma_service: Arc<EnigmaService>,
}

impl InvestigationService {
    pub fn new(enigma_service: Arc<EnigmaService>) -> Self {
        Self { enigma_service }
    }

    fn mock_investigations(&self) -> Vec<Investigation> {
        vec![
            Investigation::from_parts(
                MOCK_INV_1,
                "Le mystère du parc".to_string(),
                "Une enquête familiale dans le parc central.".to_string(),
                45,
                "facile".to_string(),
                true,
            ),
            Investigation::from_parts(
                MOCK_INV_2,
                "Les secrets du vieux quartier".to_string(),
                "Découvrez l'histoire cachée du centre-ville.".to_string(),
                90,
                "moyen".to_string(),
                false,
            ),
        ]
    }

    /// Retourne la liste des enquêtes disponibles (mock pour MVP).
    pub fn list_investigations(&self) -> Vec<Investigation> {
        self.mock_investigations()
    }

    /// Retourne une enquête par id avec sa liste ordonnée d'énigmes (Story 3.1, 4.1). IDs déterministes via EnigmaService.
    pub fn get_investigation_by_id_with_enigmas(
        &self,
        id: Uuid,
    ) -> Option<InvestigationWithEnigmas> {
        let invs = self.mock_investigations();
        let investigation = invs.into_iter().find(|i| i.id == id.to_string())?;
        let enigmas = self.enigma_service.get_enigmas_for_investigation(id);
        Some(InvestigationWithEnigmas {
            investigation,
            enigmas,
        })
    }
}

impl Default for InvestigationService {
    fn default() -> Self {
        Self::new(Arc::new(EnigmaService::new()))
    }
}
