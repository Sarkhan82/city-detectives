//! Service analytics (Story 7.4 – FR69, FR70) – événements enquête démarrée/complétée, agrégations.

use async_graphql::*;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use uuid::Uuid;

use crate::services::investigation_service::InvestigationService;

#[derive(Debug, Clone)]
pub enum InvestigationEventType {
    Started,
    Completed,
}

#[derive(Debug, Clone)]
struct InvestigationEvent {
    user_id: Uuid,
    investigation_id: Uuid,
    event_type: InvestigationEventType,
}

/// Agrégats analytics utilisateurs (Story 7.4 – FR69).
#[derive(Debug, Clone, SimpleObject)]
#[graphql(name = "UserAnalytics")]
pub struct UserAnalytics {
    #[graphql(name = "activeUserCount")]
    pub active_user_count: u32,
    #[graphql(name = "totalCompletions")]
    pub total_completions: u32,
}

/// Étape du parcours utilisateur (Story 7.4 – FR71).
#[derive(Debug, Clone, SimpleObject)]
#[graphql(name = "JourneyStep")]
pub struct JourneyStep {
    #[graphql(name = "label")]
    pub label: String,
    #[graphql(name = "userCount")]
    pub user_count: u32,
}

/// Parcours utilisateur (funnel) pour l'admin (Story 7.4 – FR71).
#[derive(Debug, Clone, SimpleObject)]
#[graphql(name = "UserJourneyAnalytics")]
pub struct UserJourneyAnalytics {
    #[graphql(name = "funnelSteps")]
    pub funnel_steps: Vec<JourneyStep>,
}

/// Taux de complétion par enquête (Story 7.4 – FR70).
#[derive(Debug, Clone, SimpleObject)]
#[graphql(name = "CompletionRateEntry")]
pub struct CompletionRateEntry {
    #[graphql(name = "investigationId")]
    pub investigation_id: String,
    #[graphql(name = "investigationTitle")]
    pub investigation_title: String,
    #[graphql(name = "startedCount")]
    pub started_count: u32,
    #[graphql(name = "completedCount")]
    pub completed_count: u32,
    #[graphql(name = "completionRate")]
    pub completion_rate: f64,
}

pub struct AnalyticsService {
    events: Arc<RwLock<Vec<InvestigationEvent>>>,
    investigation_service: Arc<InvestigationService>,
}

impl AnalyticsService {
    pub fn new(investigation_service: Arc<InvestigationService>) -> Self {
        Self {
            events: Arc::new(RwLock::new(Vec::new())),
            investigation_service,
        }
    }

    /// Enregistre « enquête démarrée » (Story 7.4 – FR70).
    pub async fn record_investigation_started(&self, user_id: Uuid, investigation_id: Uuid) {
        let mut events = self.events.write().await;
        events.push(InvestigationEvent {
            user_id,
            investigation_id,
            event_type: InvestigationEventType::Started,
        });
    }

    /// Enregistre « enquête complétée » (Story 7.4 – FR70).
    pub async fn record_investigation_completed(&self, user_id: Uuid, investigation_id: Uuid) {
        let mut events = self.events.write().await;
        events.push(InvestigationEvent {
            user_id,
            investigation_id,
            event_type: InvestigationEventType::Completed,
        });
    }

    /// Agrégats utilisateurs : actifs, complétions totales (Story 7.4 – FR69, FR70).
    pub async fn get_user_analytics(&self) -> UserAnalytics {
        let events = self.events.read().await;
        let active_user_count = events
            .iter()
            .map(|e| e.user_id)
            .collect::<std::collections::HashSet<_>>()
            .len() as u32;
        let total_completions = events
            .iter()
            .filter(|e| matches!(e.event_type, InvestigationEventType::Completed))
            .count() as u32;
        UserAnalytics {
            active_user_count,
            total_completions,
        }
    }

    /// Taux de complétion par enquête (Story 7.4 – FR70).
    pub async fn get_completion_rates(&self) -> Vec<CompletionRateEntry> {
        use std::collections::HashSet;
        let events = self.events.read().await;
        let mut by_inv: HashMap<Uuid, (HashSet<Uuid>, HashSet<Uuid>)> = HashMap::new();
        for e in events.iter() {
            let entry = by_inv
                .entry(e.investigation_id)
                .or_insert_with(|| (HashSet::new(), HashSet::new()));
            match e.event_type {
                InvestigationEventType::Started => {
                    entry.0.insert(e.user_id);
                }
                InvestigationEventType::Completed => {
                    entry.1.insert(e.user_id);
                }
            }
        }
        let investigations = self.investigation_service.list_investigations().await;
        let mut result = Vec::new();
        for inv in investigations {
            let id = Uuid::parse_str(&inv.id).ok();
            if let Some(uuid) = id {
                let (started_set, completed_set) = by_inv.get(&uuid).cloned().unwrap_or_default();
                let started = started_set.len() as u32;
                let completed = completed_set.len() as u32;
                let rate = if started > 0 {
                    completed as f64 / started as f64
                } else {
                    0.0
                };
                result.push(CompletionRateEntry {
                    investigation_id: inv.id.clone(),
                    investigation_title: inv.titre.clone(),
                    started_count: started,
                    completed_count: completed,
                    completion_rate: rate,
                });
            }
        }
        result
    }

    /// Parcours utilisateur (funnel) : étapes dérivées des événements (Story 7.4 – FR71).
    pub async fn get_user_journey_analytics(&self) -> UserJourneyAnalytics {
        let events = self.events.read().await;
        let started_users: std::collections::HashSet<Uuid> = events
            .iter()
            .filter(|e| matches!(e.event_type, InvestigationEventType::Started))
            .map(|e| e.user_id)
            .collect();
        let completed_users: std::collections::HashSet<Uuid> = events
            .iter()
            .filter(|e| matches!(e.event_type, InvestigationEventType::Completed))
            .map(|e| e.user_id)
            .collect();
        let funnel_steps = vec![
            JourneyStep {
                label: "Enquête démarrée".to_string(),
                user_count: started_users.len() as u32,
            },
            JourneyStep {
                label: "Enquête complétée".to_string(),
                user_count: completed_users.len() as u32,
            },
        ];
        UserJourneyAnalytics { funnel_steps }
    }
}
