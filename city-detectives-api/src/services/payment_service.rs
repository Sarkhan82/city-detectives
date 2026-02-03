//! Service paiement (Story 6.2 – FR48, FR52, FR53).
//! MVP : simulation uniquement ; record_purchase_intent + simulate_purchase ; stockage en mémoire.
//! Persistance DB (tables purchase_intents, user_purchases) prévue post-MVP (Task 2.2) ; migrations sqlx à ajouter.

use std::sync::Mutex;
use uuid::Uuid;

/// Entrée d'intention d'achat (FR52) – user_id, investigation_id, created_at.
#[derive(Debug, Clone)]
pub struct PurchaseIntent {
    pub user_id: Uuid,
    pub investigation_id: Uuid,
    pub created_at: std::time::SystemTime,
}

/// Achats simulés (FR48) – user_id + investigation_id.
pub struct PaymentService {
    purchase_intents: Mutex<Vec<PurchaseIntent>>,
    user_purchases: Mutex<Vec<(Uuid, Uuid)>>,
}

impl PaymentService {
    pub fn new() -> Self {
        Self {
            purchase_intents: Mutex::new(Vec::new()),
            user_purchases: Mutex::new(Vec::new()),
        }
    }

    /// Enregistre une intention d'achat (clic « Acheter » / « Payer ») – FR52.
    pub fn record_purchase_intent(
        &self,
        user_id: Uuid,
        investigation_id: Uuid,
    ) -> Result<(), String> {
        let mut intents = self.purchase_intents.lock().map_err(|e| e.to_string())?;
        intents.push(PurchaseIntent {
            user_id,
            investigation_id,
            created_at: std::time::SystemTime::now(),
        });
        Ok(())
    }

    /// Simule un achat réussi : enregistre dans user_purchases (FR48).
    pub fn simulate_purchase(&self, user_id: Uuid, investigation_id: Uuid) -> Result<(), String> {
        let mut purchases = self.user_purchases.lock().map_err(|e| e.to_string())?;
        if !purchases
            .iter()
            .any(|(u, i)| *u == user_id && *i == investigation_id)
        {
            purchases.push((user_id, investigation_id));
        }
        Ok(())
    }

    /// Liste des investigation_id achetés par l'utilisateur (FR48).
    pub fn get_user_purchases(&self, user_id: Uuid) -> Vec<Uuid> {
        let purchases = self.user_purchases.lock();
        let purchases = match purchases {
            Ok(p) => p,
            Err(_) => return Vec::new(),
        };
        purchases
            .iter()
            .filter(|(u, _)| *u == user_id)
            .map(|(_, inv_id)| *inv_id)
            .collect()
    }
}

impl Default for PaymentService {
    fn default() -> Self {
        Self::new()
    }
}
