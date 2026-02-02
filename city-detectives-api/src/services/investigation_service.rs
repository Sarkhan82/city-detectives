//! Service investigations (Story 2.1, 3.1) – liste des enquêtes ; enquête par id avec énigmes (mock MVP).

use crate::models::enigma::Enigma;
use crate::models::investigation::{Investigation, InvestigationWithEnigmas};
use uuid::Uuid;

/// IDs fixes pour les enquêtes mock (Story 3.1) – permet de retrouver une enquête par id.
const MOCK_INV_1: Uuid = uuid::uuid!("11111111-1111-1111-1111-111111111111");
const MOCK_INV_2: Uuid = uuid::uuid!("22222222-2222-2222-2222-222222222222");

pub struct InvestigationService;

impl InvestigationService {
    pub fn new() -> Self {
        Self
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

    /// Retourne une enquête par id avec sa liste ordonnée d'énigmes (Story 3.1). Pas de session persistante.
    pub fn get_investigation_by_id_with_enigmas(
        &self,
        id: Uuid,
    ) -> Option<InvestigationWithEnigmas> {
        let invs = self.mock_investigations();
        let investigation = invs.into_iter().find(|i| i.id == id.to_string())?;
        let enigmas = self.mock_enigmas_for_investigation(id);
        Some(InvestigationWithEnigmas {
            investigation,
            enigmas,
        })
    }

    fn mock_enigmas_for_investigation(&self, investigation_id: Uuid) -> Vec<Enigma> {
        // Génère des énigmes mock ordonnées (order_index 1, 2, 3...) – type/titre minimal pour affichage.
        let base = format!("{:x}", investigation_id.as_u128())
            .chars()
            .take(8)
            .collect::<String>();
        vec![
            Enigma::from_parts(
                Uuid::new_v4(),
                1,
                "text".to_string(),
                format!("Énigme 1 – {}", base),
            ),
            Enigma::from_parts(
                Uuid::new_v4(),
                2,
                "text".to_string(),
                format!("Énigme 2 – {}", base),
            ),
            Enigma::from_parts(
                Uuid::new_v4(),
                3,
                "text".to_string(),
                format!("Énigme 3 – {}", base),
            ),
        ]
    }
}

impl Default for InvestigationService {
    fn default() -> Self {
        Self::new()
    }
}
