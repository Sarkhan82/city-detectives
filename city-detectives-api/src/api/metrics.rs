//! Métriques techniques simples pour le endpoint GraphQL (Story 7.4 – FR68).
//!
//! Stocke le nombre total de requêtes, le nombre d'erreurs et la somme des latences
//! pour calculer une latence moyenne et un taux d'erreur côté admin.

use std::sync::atomic::{AtomicU64, Ordering};

/// Nombre total de requêtes GraphQL traitées.
pub static REQUEST_COUNT: AtomicU64 = AtomicU64::new(0);

/// Nombre de requêtes GraphQL ayant retourné une erreur applicative.
pub static ERROR_COUNT: AtomicU64 = AtomicU64::new(0);

/// Somme des latences (en millisecondes) de toutes les requêtes GraphQL.
pub static TOTAL_LATENCY_MS: AtomicU64 = AtomicU64::new(0);

/// Enregistre une requête avec sa latence et si elle est en erreur.
pub fn record_request(latency_ms: u64, is_error: bool) {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);
    TOTAL_LATENCY_MS.fetch_add(latency_ms, Ordering::Relaxed);
    if is_error {
        ERROR_COUNT.fetch_add(1, Ordering::Relaxed);
    }
}
