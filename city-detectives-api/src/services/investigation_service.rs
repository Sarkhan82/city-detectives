//! Service investigations (Story 2.1, 3.1, 4.1, 7.2) – liste, get by id, create, update (admin).

use crate::models::investigation::{
    CreateInvestigationInput, Investigation, InvestigationStatus, InvestigationWithEnigmas,
    UpdateInvestigationInput,
};
use crate::services::enigma_service::EnigmaService;
use std::sync::Arc;
use tokio::sync::RwLock;
use uuid::Uuid;
use validator::Validate;

/// IDs fixes pour les enquêtes mock (Story 3.1) – permet de retrouver une enquête par id.
const MOCK_INV_1: Uuid = uuid::uuid!("11111111-1111-1111-1111-111111111111");
const MOCK_INV_2: Uuid = uuid::uuid!("22222222-2222-2222-2222-222222222222");

pub struct InvestigationService {
    enigma_service: Arc<EnigmaService>,
    /// Store mutable : enquêtes mock + créées/mises à jour par l'admin (Story 7.2).
    store: Arc<RwLock<Vec<Investigation>>>,
}

impl InvestigationService {
    pub fn new(enigma_service: Arc<EnigmaService>) -> Self {
        let store = Arc::new(RwLock::new(Self::initial_investigations()));
        Self {
            enigma_service,
            store,
        }
    }

    fn initial_investigations() -> Vec<Investigation> {
        vec![
            Investigation::from_parts(
                MOCK_INV_1,
                "Le mystère du parc".to_string(),
                "Une enquête familiale dans le parc central.".to_string(),
                45,
                "facile".to_string(),
                true,
                None,
                None,
                InvestigationStatus::Published,
                None,
                None,
            ),
            Investigation::from_parts(
                MOCK_INV_2,
                "Les secrets du vieux quartier".to_string(),
                "Découvrez l'histoire cachée du centre-ville.".to_string(),
                90,
                "moyen".to_string(),
                false,
                Some(299u32),
                Some("EUR".to_string()),
                InvestigationStatus::Published,
                None,
                None,
            ),
        ]
    }

    /// Retourne la liste des enquêtes disponibles.
    pub async fn list_investigations(&self) -> Vec<Investigation> {
        let guard = self.store.read().await;
        guard.clone()
    }

    /// Retourne une enquête par id avec sa liste ordonnée d'énigmes (Story 3.1, 4.1).
    /// Appel synchrone à EnigmaService exécuté dans spawn_blocking pour ne pas bloquer le runtime async.
    pub async fn get_investigation_by_id_with_enigmas(
        &self,
        id: Uuid,
    ) -> Option<InvestigationWithEnigmas> {
        let guard = self.store.read().await;
        let investigation = guard.iter().find(|i| i.id == id.to_string())?.clone();
        drop(guard);
        let enigma_svc = self.enigma_service.clone();
        let enigmas =
            tokio::task::spawn_blocking(move || enigma_svc.get_enigmas_for_investigation(id))
                .await
                .ok()?;
        Some(InvestigationWithEnigmas {
            investigation,
            enigmas,
        })
    }

    /// Crée une enquête (admin, Story 7.2 – FR62). Validation des champs puis persistance en mémoire.
    pub async fn create_investigation(
        &self,
        input: CreateInvestigationInput,
    ) -> Result<Investigation, String> {
        input.validate().map_err(|e| e.to_string())?;
        if !input.is_free {
            if input.price_amount.is_none()
                || input.price_currency.as_ref().is_none_or(|s| s.is_empty())
            {
                return Err(
                    "Enquête payante : priceAmount et priceCurrency sont requis".to_string()
                );
            }
        } else if input.price_amount.is_some()
            || input.price_currency.as_ref().is_some_and(|s| !s.is_empty())
        {
            return Err(
                "Enquête gratuite : priceAmount et priceCurrency doivent être absents".to_string(),
            );
        }
        let status = input
            .status
            .as_deref()
            .and_then(parse_status)
            .unwrap_or(InvestigationStatus::Draft);
        let id = Uuid::new_v4();
        let inv = Investigation::from_parts(
            id,
            input.titre,
            input.description,
            input.duration_estimate,
            input.difficulte,
            input.is_free,
            input.price_amount,
            input.price_currency,
            status,
            input.center_lat,
            input.center_lng,
        );
        let mut guard = self.store.write().await;
        guard.push(inv.clone());
        Ok(inv)
    }

    /// Met à jour une enquête (admin, Story 7.2 – FR62).
    pub async fn update_investigation(
        &self,
        id: Uuid,
        input: UpdateInvestigationInput,
    ) -> Result<Investigation, String> {
        let mut guard = self.store.write().await;
        let pos = guard
            .iter()
            .position(|i| i.id == id.to_string())
            .ok_or("Enquête introuvable")?;
        let existing = &guard[pos];
        if let Some(ref t) = input.titre {
            if t.is_empty() {
                return Err("Le titre ne peut pas être vide".to_string());
            }
        }
        if let Some(ref d) = input.difficulte {
            if d.is_empty() {
                return Err("La difficulté ne peut pas être vide".to_string());
            }
        }
        if let Some(d) = input.duration_estimate {
            if d == 0 {
                return Err("La durée estimée doit être au moins 1 minute".to_string());
            }
        }
        let is_free = input.is_free.unwrap_or(existing.is_free);
        if !is_free {
            let pa = input.price_amount.or(existing.price_amount);
            let pc = input
                .price_currency
                .clone()
                .or_else(|| existing.price_currency.clone());
            if pa.is_none() || pc.as_ref().is_none_or(|s| s.is_empty()) {
                return Err(
                    "Enquête payante : priceAmount et priceCurrency sont requis".to_string()
                );
            }
        }
        let status = input
            .status
            .as_deref()
            .and_then(parse_status)
            .map(|s| match s {
                InvestigationStatus::Draft => "draft".to_string(),
                InvestigationStatus::Published => "published".to_string(),
            })
            .unwrap_or_else(|| existing.status.clone());
        let updated = Investigation {
            id: existing.id.clone(),
            titre: input
                .titre
                .clone()
                .unwrap_or_else(|| existing.titre.clone()),
            description: input
                .description
                .clone()
                .unwrap_or_else(|| existing.description.clone()),
            duration_estimate: input
                .duration_estimate
                .unwrap_or(existing.duration_estimate),
            difficulte: input
                .difficulte
                .clone()
                .unwrap_or_else(|| existing.difficulte.clone()),
            is_free,
            price_amount: if is_free {
                None
            } else {
                input.price_amount.or(existing.price_amount)
            },
            price_currency: if is_free {
                None
            } else {
                input
                    .price_currency
                    .clone()
                    .or_else(|| existing.price_currency.clone())
            },
            center_lat: input.center_lat.or(existing.center_lat),
            center_lng: input.center_lng.or(existing.center_lng),
            status,
        };
        guard[pos] = updated.clone();
        Ok(updated)
    }
}

fn parse_status(s: &str) -> Option<InvestigationStatus> {
    match s {
        "draft" => Some(InvestigationStatus::Draft),
        "published" => Some(InvestigationStatus::Published),
        _ => None,
    }
}

impl Default for InvestigationService {
    fn default() -> Self {
        Self::new(Arc::new(EnigmaService::new()))
    }
}
