//! Service admin (Story 7.1 – FR61, 7.2, 7.4 – FR68–FR71) – agrégation vue d'ensemble dashboard (enquêtes, énigmes, métriques).

use async_graphql::*;
use std::sync::atomic::Ordering;
use std::sync::Arc;
use uuid::Uuid;

use crate::api::metrics;
use crate::services::enigma_service::EnigmaService;
use crate::services::investigation_service::InvestigationService;

/// Vue d'ensemble du dashboard admin (Story 7.1 – FR61). Champs camelCase en GraphQL.
#[derive(Debug, Clone, SimpleObject)]
#[graphql(name = "DashboardOverview")]
pub struct DashboardOverview {
    #[graphql(name = "investigationCount")]
    pub investigation_count: u32,
    #[graphql(name = "publishedCount")]
    pub published_count: u32,
    #[graphql(name = "draftCount")]
    pub draft_count: u32,
    #[graphql(name = "enigmaCount")]
    pub enigma_count: u32,
}

/// Métriques techniques pour l'admin (Story 7.4 – FR68). Santé, latence API, crashs, lien Sentry.
#[derive(Debug, Clone, SimpleObject)]
#[graphql(name = "TechnicalMetrics")]
pub struct TechnicalMetrics {
    #[graphql(name = "healthStatus")]
    pub health_status: String,
    #[graphql(name = "apiLatencyAvgMs")]
    pub api_latency_avg_ms: Option<f64>,
    #[graphql(name = "apiLatencyP95Ms")]
    pub api_latency_p95_ms: Option<f64>,
    #[graphql(name = "errorRate")]
    pub error_rate: f64,
    #[graphql(name = "crashCount")]
    pub crash_count: u32,
    #[graphql(name = "sentryDashboardUrl")]
    pub sentry_dashboard_url: Option<String>,
}

pub struct AdminService {
    investigation_service: Arc<InvestigationService>,
    enigma_service: Arc<EnigmaService>,
}

impl AdminService {
    pub fn new(
        investigation_service: Arc<InvestigationService>,
        enigma_service: Arc<EnigmaService>,
    ) -> Self {
        Self {
            investigation_service,
            enigma_service,
        }
    }

    /// Agrège les compteurs pour la vue d'ensemble (Story 7.1 – FR61, 7.2 avec statut draft/published).
    pub async fn get_dashboard_overview(&self) -> DashboardOverview {
        let investigations = self.investigation_service.list_investigations().await;
        let investigation_count = investigations.len() as u32;
        let published_count = investigations
            .iter()
            .filter(|i| i.status == "published")
            .count() as u32;
        let draft_count = investigations
            .iter()
            .filter(|i| i.status == "draft")
            .count() as u32;
        let mut enigma_count = 0u32;
        for inv in &investigations {
            if let Ok(uuid) = Uuid::parse_str(&inv.id) {
                let enigmas = self.enigma_service.get_enigmas_for_investigation(uuid);
                enigma_count += enigmas.len() as u32;
            }
        }
        DashboardOverview {
            investigation_count,
            published_count,
            draft_count,
            enigma_count,
        }
    }

    /// Métriques techniques pour le dashboard admin (Story 7.4 – FR68). Health, latence, crashs, lien Sentry.
    /// Limites MVP : health_status en dur "ok" (pas de health check réel) ; crash_count à 0 tant qu'aucune
    /// ingestion Sentry (webhook/API) ; api_latency_p95_ms non calculé (métriques actuelles = moyenne uniquement).
    pub fn get_technical_metrics(&self) -> TechnicalMetrics {
        let sentry_dashboard_url = std::env::var("SENTRY_DASHBOARD_URL")
            .ok()
            .filter(|s| !s.is_empty());
        let total_requests = metrics::REQUEST_COUNT.load(Ordering::Relaxed);
        let total_latency_ms = metrics::TOTAL_LATENCY_MS.load(Ordering::Relaxed);
        let error_count = metrics::ERROR_COUNT.load(Ordering::Relaxed);
        let api_latency_avg_ms = if total_requests > 0 {
            Some(total_latency_ms as f64 / total_requests as f64)
        } else {
            None
        };
        let error_rate = if total_requests > 0 {
            error_count as f64 / total_requests as f64
        } else {
            0.0
        };
        let api_latency_p95_ms = metrics::p95_latency_ms();
        TechnicalMetrics {
            health_status: "ok".to_string(),
            api_latency_avg_ms,
            api_latency_p95_ms,
            error_rate,
            crash_count: 0,
            sentry_dashboard_url,
        }
    }
}
