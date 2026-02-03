//! Service admin (Story 7.1 – FR61, 7.2) – agrégation vue d'ensemble dashboard (enquêtes, énigmes, métriques).

use async_graphql::*;
use std::sync::Arc;
use uuid::Uuid;

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
}
