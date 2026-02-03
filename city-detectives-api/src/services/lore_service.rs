//! Service LORE (Story 4.4 – FR34, FR37) – contenu narratif par enquête (séquences, texte, médias).
//! Lecture seule ; pas de mutation.

use crate::models::enigma::LoreContent;
use std::collections::HashMap;
use uuid::Uuid;

/// IDs d'enquêtes mock (alignés avec InvestigationService / EnigmaService).
const MOCK_INV_1: Uuid = uuid::uuid!("11111111-1111-1111-1111-111111111111");
const MOCK_INV_2: Uuid = uuid::uuid!("22222222-2222-2222-2222-222222222222");

pub struct LoreService {
    /// (investigation_id, sequence_index) -> contenu LORE.
    sequences: HashMap<(Uuid, i32), LoreContent>,
}

impl LoreService {
    pub fn new() -> Self {
        let mut sequences = HashMap::new();

        // Enquête 1 : intro LORE (séquence 0) + une séquence entre énigmes (séquence 1).
        sequences.insert(
            (MOCK_INV_1, 0),
            LoreContent {
                sequence_index: 0,
                title: "Bienvenue dans l'enquête".to_string(),
                content_text: "Cette enquête vous mènera au cœur de Paris, de la Tour Eiffel aux rues historiques. Chaque énigme vous rapprochera des secrets des lieux.".to_string(),
                media_urls: vec!["https://example.com/lore/inv1-intro.jpg".to_string()],
            },
        );
        sequences.insert(
            (MOCK_INV_1, 1),
            LoreContent {
                sequence_index: 1,
                title: "Le Champ de Mars".to_string(),
                content_text: "Le Champ de Mars s'étend devant la Tour Eiffel. Ce parc doit son nom au dieu de la guerre ; il a accueilli les Expositions universelles.".to_string(),
                media_urls: vec![],
            },
        );

        // Enquête 2 : intro LORE.
        sequences.insert(
            (MOCK_INV_2, 0),
            LoreContent {
                sequence_index: 0,
                title: "Introduction – Deuxième enquête".to_string(),
                content_text: "Une nouvelle aventure vous attend. Découvrez les énigmes de cette enquête et le contexte historique des lieux.".to_string(),
                media_urls: vec![],
            },
        );

        Self { sequences }
    }

    /// Retourne le contenu LORE pour une enquête et un index de séquence (0 = intro, 1+ = entre énigmes).
    pub fn get_lore_content(
        &self,
        investigation_id: Uuid,
        sequence_index: i32,
    ) -> Option<LoreContent> {
        self.sequences
            .get(&(investigation_id, sequence_index))
            .cloned()
    }

    /// Retourne les index de séquences LORE définis pour une enquête (ordre d'affichage).
    pub fn get_lore_sequence_indexes(&self, investigation_id: Uuid) -> Vec<i32> {
        let mut indexes: Vec<i32> = self
            .sequences
            .keys()
            .filter(|(inv, _)| *inv == investigation_id)
            .map(|(_, idx)| *idx)
            .collect();
        indexes.sort_unstable();
        indexes
    }
}

impl Default for LoreService {
    fn default() -> Self {
        Self::new()
    }
}
