//! Métriques techniques simples pour le endpoint GraphQL (Story 7.4 – FR68).
//!
//! Stocke le nombre total de requêtes, le nombre d'erreurs, la somme des latences
//! et un échantillon des dernières latences pour calculer moyenne, p95 et taux d'erreur côté admin.

use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{OnceLock, RwLock};

const LATENCY_SAMPLE_CAP: usize = 500;

fn latency_samples() -> &'static RwLock<Vec<u64>> {
    static SAMPLES: OnceLock<RwLock<Vec<u64>>> = OnceLock::new();
    SAMPLES.get_or_init(|| RwLock::new(Vec::new()))
}

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
    if let Ok(mut samples) = latency_samples().write() {
        samples.push(latency_ms);
        if samples.len() > LATENCY_SAMPLE_CAP {
            samples.remove(0);
        }
    }
}

/// Retourne le percentile 95 des dernières latences (ms), ou None si pas assez d'échantillons.
pub fn p95_latency_ms() -> Option<f64> {
    let samples = latency_samples().read().ok()?.clone();
    if samples.len() < 10 {
        return None;
    }
    let mut sorted = samples;
    sorted.sort_unstable();
    let idx = (sorted.len() as f64 * 0.95).ceil() as usize;
    let idx = idx.min(sorted.len().saturating_sub(1));
    Some(sorted[idx] as f64)
}
