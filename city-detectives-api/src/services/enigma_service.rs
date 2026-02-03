//! Service énigmes (Story 4.1, 4.2, 4.3, 7.2) – validation, indices, explications ; create/update admin.

use crate::models::enigma::{
    CreateEnigmaInput, Enigma, EnigmaExplanation, EnigmaHints, UpdateEnigmaInput,
    ValidateEnigmaPayload, ValidateEnigmaResult,
};
use crate::services::enigma::{puzzle, words};
use geo::HaversineDistance;
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use uuid::Uuid;

/// Namespace UUID pour générer des IDs d'énigmes déterministes (v5).
const NAMESPACE_ENIGMA: Uuid = uuid::uuid!("6ba7b810-9dad-11d1-80b4-00c04fd430c8");

/// Définition interne d'une énigme (point cible, tolérance, type, réponses attendues, indices, explications).
#[derive(Clone)]
struct EnigmaDef {
    investigation_id: Uuid,
    order_index: u32,
    enigma_type: String,
    titre: String,
    target_lat: Option<f64>,
    target_lng: Option<f64>,
    tolerance_meters: Option<f64>,
    #[allow(dead_code)]
    reference_photo_url: Option<String>,
    expected_text_answer: Option<String>,
    expected_code_answer: Option<String>,
    hint_suggestion: String,
    hint_hint: String,
    hint_solution: String,
    historical_explanation: String,
    educational_content: String,
    historical_content_validated: bool,
}

/// IDs d'enquêtes mock (alignés avec InvestigationService).
const MOCK_INV_1: Uuid = uuid::uuid!("11111111-1111-1111-1111-111111111111");
const MOCK_INV_2: Uuid = uuid::uuid!("22222222-2222-2222-2222-222222222222");

/// Tolérance géo par défaut en mètres (FR24, NFR précision <10 m).
const DEFAULT_GEO_TOLERANCE_M: f64 = 10.0;

pub struct EnigmaService {
    /// Carte enigma_id -> définition (mock + créées/mises à jour par admin, Story 7.2).
    definitions: Arc<RwLock<HashMap<Uuid, EnigmaDef>>>,
}

impl EnigmaService {
    /// Retourne un ID d'énigme déterministe pour une enquête et un ordre (cohérent avec les queries).
    pub fn enigma_id_for(investigation_id: Uuid, order_index: u32) -> Uuid {
        Uuid::new_v5(
            &NAMESPACE_ENIGMA,
            format!("{}:{}", investigation_id, order_index).as_bytes(),
        )
    }

    pub fn new() -> Self {
        let mut definitions = HashMap::new();

        // Enquête 1 : 3 énigmes (1 words, 2 géo, 3 photo)
        let inv1_base = "inv1";
        Self::insert_mock(
            &mut definitions,
            MOCK_INV_1,
            1,
            "words",
            &format!("Énigme 1 – {}", inv1_base),
            None,
            None,
            None,
            None,
            Some("paris".to_string()),
            None,
            "Pensez à une ville française célèbre.",
            "La ville commence par P et rime avec « mari ».",
            "La réponse est : Paris.",
            "Paris est la capitale de la France depuis le Xe siècle.",
            "Paris concentre musées, monuments et culture ; le Louvre est le plus grand musée d'art au monde.",
        );
        Self::insert_mock(
            &mut definitions,
            MOCK_INV_1,
            2,
            "geolocation",
            &format!("Énigme 2 – {}", inv1_base),
            Some(48.8566),
            Some(2.3522),
            Some(DEFAULT_GEO_TOLERANCE_M),
            None,
            None,
            None,
            "Cherchez un lieu emblématique au centre de Paris.",
            "La tour la plus connue de France, symbole de la capitale.",
            "Vous devez vous rendre à la Tour Eiffel (Champ de Mars).",
            "La Tour Eiffel a été construite pour l'Exposition universelle de 1889.",
            "Gustave Eiffel a conçu la structure ; elle mesure 330 mètres et pèse environ 10 100 tonnes.",
        );
        Self::insert_mock(
            &mut definitions,
            MOCK_INV_1,
            3,
            "photo",
            &format!("Énigme 3 – {}", inv1_base),
            None,
            None,
            None,
            Some("https://example.com/ref.jpg".to_string()),
            None,
            None,
            "Prenez une photo du monument ou du détail indiqué sur la carte.",
            "Assurez-vous que le monument est bien visible et centré.",
            "Photographiez le lieu exact demandé pour valider l'énigme.",
            "Ce lieu est un point de repère historique de Paris.",
            "Les monuments parisiens sont protégés au titre des Monuments historiques.",
        );

        // Enquête 2 : 3 énigmes (1 géo, 2 photo, 3 puzzle)
        let inv2_base = "inv2";
        Self::insert_mock(
            &mut definitions,
            MOCK_INV_2,
            1,
            "geolocation",
            &format!("Énigme 1 – {}", inv2_base),
            Some(48.8606),
            Some(2.3376),
            Some(DEFAULT_GEO_TOLERANCE_M),
            None,
            None,
            None,
            "Utilisez la carte pour vous rapprocher du point indiqué.",
            "Vérifiez que votre position GPS est activée et précise.",
            "Atteignez le marqueur sur la carte pour valider.",
            "Ce quartier est riche en histoire et en culture.",
            "La géolocalisation permet de valider votre présence sur les lieux.",
        );
        Self::insert_mock(
            &mut definitions,
            MOCK_INV_2,
            2,
            "photo",
            &format!("Énigme 2 – {}", inv2_base),
            None,
            None,
            None,
            None,
            None,
            None,
            "Une photo du lieu ou de l'objet demandé suffit pour valider.",
            "Cadrez bien le sujet avant de prendre la photo.",
            "Envoyez la photo du bon lieu pour débloquer la suite.",
            "Les lieux d'enquête sont choisis pour leur intérêt historique.",
            "La photographie de lieux permet de garder une trace de votre enquête.",
        );
        Self::insert_mock(
            &mut definitions,
            MOCK_INV_2,
            3,
            "puzzle",
            &format!("Énigme 3 – {}", inv2_base),
            None,
            None,
            None,
            None,
            None,
            Some("1234".to_string()),
            "Le code est un nombre à quatre chiffres.",
            "Pensez à un code PIN classique (chiffres seulement).",
            "Le code attendu est : 1234.",
            "Les codes à chiffres sont utilisés depuis des siècles pour sécuriser.",
            "Les énigmes à code développent la logique et l'attention aux détails.",
        );

        Self {
            definitions: Arc::new(RwLock::new(definitions)),
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn insert_mock(
        defs: &mut HashMap<Uuid, EnigmaDef>,
        investigation_id: Uuid,
        order_index: u32,
        enigma_type: &str,
        titre: &str,
        target_lat: Option<f64>,
        target_lng: Option<f64>,
        tolerance_meters: Option<f64>,
        reference_photo_url: Option<String>,
        expected_text_answer: Option<String>,
        expected_code_answer: Option<String>,
        hint_suggestion: &str,
        hint_hint: &str,
        hint_solution: &str,
        historical_explanation: &str,
        educational_content: &str,
    ) {
        let id = Self::enigma_id_for(investigation_id, order_index);
        defs.insert(
            id,
            EnigmaDef {
                investigation_id,
                order_index,
                enigma_type: enigma_type.to_string(),
                titre: titre.to_string(),
                target_lat,
                target_lng,
                tolerance_meters,
                reference_photo_url,
                expected_text_answer,
                expected_code_answer,
                hint_suggestion: hint_suggestion.to_string(),
                hint_hint: hint_hint.to_string(),
                hint_solution: hint_solution.to_string(),
                historical_explanation: historical_explanation.to_string(),
                educational_content: educational_content.to_string(),
                historical_content_validated: false,
            },
        );
    }

    fn def_to_enigma(id: Uuid, def: &EnigmaDef) -> Enigma {
        Enigma {
            id: id.to_string(),
            investigation_id: Some(def.investigation_id.to_string()),
            order_index: def.order_index,
            enigma_type: def.enigma_type.clone(),
            titre: def.titre.clone(),
            target_lat: def.target_lat,
            target_lng: def.target_lng,
            tolerance_meters: def.tolerance_meters,
            reference_photo_url: def.reference_photo_url.clone(),
            consigne: None,
            hint_suggestion: Some(def.hint_suggestion.clone()),
            hint_hint: Some(def.hint_hint.clone()),
            hint_solution: Some(def.hint_solution.clone()),
            historical_explanation: Some(def.historical_explanation.clone()),
            educational_content: Some(def.educational_content.clone()),
            historical_content_validated: Some(def.historical_content_validated),
        }
    }

    /// Liste des énigmes pour une enquête (ordre par order_index).
    pub fn get_enigmas_for_investigation(&self, investigation_id: Uuid) -> Vec<Enigma> {
        let guard = self.definitions.read().expect("RwLock read");
        let mut out: Vec<(Uuid, Enigma)> = guard
            .iter()
            .filter(|(_, def)| def.investigation_id == investigation_id)
            .map(|(&id, def)| (id, Self::def_to_enigma(id, def)))
            .collect();
        drop(guard);
        out.sort_by_key(|(_, e)| e.order_index);
        out.into_iter().map(|(_, e)| e).collect()
    }

    /// Valide une réponse : géo (distance < tolérance) ou photo (présence de photo en MVP).
    pub fn validate_response(
        &self,
        enigma_id: Uuid,
        payload: ValidateEnigmaPayload,
    ) -> Result<ValidateEnigmaResult, String> {
        let guard = self.definitions.read().expect("RwLock read");
        let def = guard
            .get(&enigma_id)
            .ok_or_else(|| "Énigme introuvable".to_string())?;

        match def.enigma_type.as_str() {
            "geolocation" => self.validate_geolocation(def, payload),
            "photo" => self.validate_photo(def, payload),
            "words" => self.validate_words(def, payload),
            "puzzle" => self.validate_puzzle(def, payload),
            _ => Ok(ValidateEnigmaResult {
                validated: false,
                message: "Type d'énigme non supporté pour la validation".to_string(),
            }),
        }
    }

    fn validate_geolocation(
        &self,
        def: &EnigmaDef,
        payload: ValidateEnigmaPayload,
    ) -> Result<ValidateEnigmaResult, String> {
        let user_lat = payload
            .user_lat
            .ok_or_else(|| "Coordonnées utilisateur manquantes (userLat, userLng)".to_string())?;
        let user_lng = payload
            .user_lng
            .ok_or_else(|| "Coordonnées utilisateur manquantes (userLat, userLng)".to_string())?;

        let target_lat = def
            .target_lat
            .ok_or_else(|| "Énigme géo sans point cible".to_string())?;
        let target_lng = def
            .target_lng
            .ok_or_else(|| "Énigme géo sans point cible".to_string())?;
        let tolerance = def.tolerance_meters.unwrap_or(DEFAULT_GEO_TOLERANCE_M);

        let from = geo::Point::new(user_lng, user_lat);
        let to = geo::Point::new(target_lng, target_lat);
        let distance_m = from.haversine_distance(&to);

        if distance_m <= tolerance {
            Ok(ValidateEnigmaResult {
                validated: true,
                message: "Bravo, vous êtes au bon endroit !".to_string(),
            })
        } else {
            Ok(ValidateEnigmaResult {
                validated: false,
                message: format!(
                    "Vous n'êtes pas encore au bon endroit. Distance : {:.0} m (tolérance {} m).",
                    distance_m, tolerance
                ),
            })
        }
    }

    fn validate_photo(
        &self,
        _def: &EnigmaDef,
        payload: ValidateEnigmaPayload,
    ) -> Result<ValidateEnigmaResult, String> {
        let has_photo = payload
            .photo_url
            .as_ref()
            .map(|s| !s.is_empty())
            .unwrap_or(false)
            || payload
                .photo_base64
                .as_ref()
                .map(|s| !s.is_empty())
                .unwrap_or(false);

        if has_photo {
            Ok(ValidateEnigmaResult {
                validated: true,
                message: "Photo reçue et validée.".to_string(),
            })
        } else {
            Ok(ValidateEnigmaResult {
                validated: false,
                message: "Aucune photo fournie. Prenez une photo ou sélectionnez-en une."
                    .to_string(),
            })
        }
    }

    fn validate_words(
        &self,
        def: &EnigmaDef,
        payload: ValidateEnigmaPayload,
    ) -> Result<ValidateEnigmaResult, String> {
        let expected = def.expected_text_answer.as_deref().unwrap_or("");
        words::validate(expected, payload.text_answer)
    }

    fn validate_puzzle(
        &self,
        def: &EnigmaDef,
        payload: ValidateEnigmaPayload,
    ) -> Result<ValidateEnigmaResult, String> {
        let expected = def.expected_code_answer.as_deref().unwrap_or("");
        puzzle::validate(expected, payload.code_answer)
    }

    /// Indices progressifs par énigme (Story 4.3 – FR30). Lecture seule.
    pub fn get_enigma_hints(&self, enigma_id: Uuid) -> Result<EnigmaHints, String> {
        let guard = self.definitions.read().expect("RwLock read");
        let def = guard
            .get(&enigma_id)
            .ok_or_else(|| "Énigme introuvable".to_string())?;
        Ok(EnigmaHints {
            suggestion: def.hint_suggestion.clone(),
            hint: def.hint_hint.clone(),
            solution: def.hint_solution.clone(),
        })
    }

    /// Explications historiques et éducatives par énigme (Story 4.3 – FR31, FR32).
    pub fn get_enigma_explanation(&self, enigma_id: Uuid) -> Result<EnigmaExplanation, String> {
        let guard = self.definitions.read().expect("RwLock read");
        let def = guard
            .get(&enigma_id)
            .ok_or_else(|| "Énigme introuvable".to_string())?;
        Ok(EnigmaExplanation {
            historical_explanation: def.historical_explanation.clone(),
            educational_content: def.educational_content.clone(),
        })
    }

    /// Crée une énigme (admin, Story 7.2 – FR63).
    pub fn create_enigma(&self, input: CreateEnigmaInput) -> Result<Enigma, String> {
        let inv_id = Uuid::parse_str(&input.investigation_id).map_err(|_| "ID enquête invalide")?;
        if input.titre.is_empty() {
            return Err("Le titre est requis".to_string());
        }
        if input.enigma_type.is_empty() {
            return Err("Le type d'énigme est requis".to_string());
        }
        if input.order_index == 0 {
            return Err("L'ordre (orderIndex) doit être au moins 1".to_string());
        }
        let id = Uuid::new_v4();
        let def = EnigmaDef {
            investigation_id: inv_id,
            order_index: input.order_index,
            enigma_type: input.enigma_type,
            titre: input.titre,
            target_lat: input.target_lat,
            target_lng: input.target_lng,
            tolerance_meters: input.tolerance_meters,
            reference_photo_url: input.reference_photo_url,
            expected_text_answer: input.expected_text_answer,
            expected_code_answer: input.expected_code_answer,
            hint_suggestion: input.hint_suggestion.unwrap_or_default(),
            hint_hint: input.hint_hint.unwrap_or_default(),
            hint_solution: input.hint_solution.unwrap_or_default(),
            historical_explanation: input.historical_explanation.unwrap_or_default(),
            educational_content: input.educational_content.unwrap_or_default(),
            historical_content_validated: input.historical_content_validated.unwrap_or(false),
        };
        let enigma = Self::def_to_enigma(id, &def);
        let mut guard = self.definitions.write().expect("RwLock write");
        guard.insert(id, def);
        Ok(enigma)
    }

    /// Met à jour une énigme (admin, Story 7.2 – FR63).
    pub fn update_enigma(
        &self,
        enigma_id: Uuid,
        input: UpdateEnigmaInput,
    ) -> Result<Enigma, String> {
        let mut guard = self.definitions.write().expect("RwLock write");
        let def = guard.get_mut(&enigma_id).ok_or("Énigme introuvable")?;
        if let Some(ref t) = input.titre {
            if t.is_empty() {
                return Err("Le titre ne peut pas être vide".to_string());
            }
            def.titre = t.clone();
        }
        if let Some(o) = input.order_index {
            if o == 0 {
                return Err("L'ordre (orderIndex) doit être au moins 1".to_string());
            }
            def.order_index = o;
        }
        if let Some(ref ty) = input.enigma_type {
            def.enigma_type = ty.clone();
        }
        if input.target_lat.is_some() {
            def.target_lat = input.target_lat;
        }
        if input.target_lng.is_some() {
            def.target_lng = input.target_lng;
        }
        if input.tolerance_meters.is_some() {
            def.tolerance_meters = input.tolerance_meters;
        }
        if input.reference_photo_url.is_some() {
            def.reference_photo_url = input.reference_photo_url.clone();
        }
        if let Some(c) = input.consigne {
            def.hint_suggestion = c;
        }
        if input.expected_text_answer.is_some() {
            def.expected_text_answer = input.expected_text_answer.clone();
        }
        if input.expected_code_answer.is_some() {
            def.expected_code_answer = input.expected_code_answer.clone();
        }
        if let Some(s) = input.hint_suggestion {
            def.hint_suggestion = s;
        }
        if let Some(s) = input.hint_hint {
            def.hint_hint = s;
        }
        if let Some(s) = input.hint_solution {
            def.hint_solution = s;
        }
        if let Some(s) = input.historical_explanation {
            def.historical_explanation = s;
        }
        if let Some(s) = input.educational_content {
            def.educational_content = s;
        }
        if let Some(v) = input.historical_content_validated {
            def.historical_content_validated = v;
        }
        let enigma = Self::def_to_enigma(enigma_id, def);
        Ok(enigma)
    }

    /// Marque le contenu historique d'une énigme comme validé (Story 7.2 – FR64). Admin uniquement.
    pub fn validate_enigma_historical_content(&self, enigma_id: Uuid) -> Result<Enigma, String> {
        let mut guard = self.definitions.write().expect("RwLock write");
        let def = guard.get_mut(&enigma_id).ok_or("Énigme introuvable")?;
        def.historical_content_validated = true;
        let enigma = Self::def_to_enigma(enigma_id, def);
        Ok(enigma)
    }
}

impl Default for EnigmaService {
    fn default() -> Self {
        Self::new()
    }
}
