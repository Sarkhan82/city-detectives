//! Schéma GraphQL (Story 1.2, 2.1, 4.1, 4.3, 6.1, 7.1) – register, me (+ isAdmin), listInvestigations, getAdminDashboard, etc.

use async_graphql::*;
use axum::extract::State;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::Json;
use serde::Deserialize;
use std::sync::Arc;

use crate::api::metrics;
use crate::api::middleware::auth::{extract_bearer, BearerToken};
use crate::models::enigma::{CreateEnigmaInput, UpdateEnigmaInput};
use crate::models::enigma::{
    EnigmaExplanation, EnigmaHints, LoreContent, ValidateEnigmaPayload, ValidateEnigmaResult,
};
use crate::models::gamification::{LeaderboardEntry, UserBadge, UserPostcard, UserSkill};
use crate::models::investigation::{CreateInvestigationInput, UpdateInvestigationInput};
use crate::models::user::{RegisterInput, Role};
use crate::services::admin_service::{AdminService, DashboardOverview, TechnicalMetrics};
use crate::services::analytics_service::{
    AnalyticsService, CompletionRateEntry, UserAnalytics, UserJourneyAnalytics,
};
use crate::services::auth_service::AuthService;
use crate::services::enigma_service::EnigmaService;
use crate::services::gamification_service::GamificationService;
use crate::services::investigation_service::InvestigationService;
use crate::services::lore_service::LoreService;
use crate::services::payment_service::PaymentService;
use crate::services::push_service::PushService;
use uuid::Uuid;

pub type AppSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

#[allow(clippy::too_many_arguments)]
pub fn create_schema(
    auth_service: Arc<AuthService>,
    investigation_service: Arc<InvestigationService>,
    enigma_service: Arc<EnigmaService>,
    lore_service: Arc<LoreService>,
    gamification_service: Arc<GamificationService>,
    payment_service: Arc<PaymentService>,
    admin_service: Arc<AdminService>,
    analytics_service: Arc<AnalyticsService>,
    push_service: Arc<PushService>,
) -> AppSchema {
    Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(auth_service)
        .data(investigation_service)
        .data(enigma_service)
        .data(lore_service)
        .data(gamification_service)
        .data(payment_service)
        .data(admin_service)
        .data(analytics_service)
        .data(push_service)
        .finish()
}

/// Utilisateur courant exposé par la query me (Story 7.1 – FR61). Champs camelCase pour GraphQL.
pub struct CurrentUser {
    pub id: Uuid,
    pub is_admin: bool,
}

#[Object]
impl CurrentUser {
    async fn id(&self) -> String {
        self.id.to_string()
    }
    /// True si l'utilisateur a le rôle admin (accès dashboard).
    async fn is_admin(&self) -> bool {
        self.is_admin
    }
}

/// Vérifie le token et exige le rôle admin. Sinon retourne une erreur 403 FORBIDDEN (Story 7.1 – FR61).
fn require_admin(ctx: &Context<'_>) -> Result<Uuid, Error> {
    let auth = ctx.data::<Arc<AuthService>>()?;
    let token: String = ctx
        .data::<BearerToken>()
        .ok()
        .and_then(|t| t.0.clone())
        .ok_or_else(|| {
            Error::new("Authentification requise")
                .extend_with(|_, e| e.set("code", "UNAUTHENTICATED"))
        })?;
    let (user_id, role) = auth.validate_token_claims(&token).map_err(Error::from)?;
    if role != Role::Admin {
        return Err(Error::new("Accès réservé aux administrateurs")
            .extend_with(|_, e| e.set("code", "FORBIDDEN")));
    }
    Ok(user_id)
}

pub struct QueryRoot;

#[Object]
impl QueryRoot {
    async fn health(&self) -> &'static str {
        "ok"
    }

    /// Utilisateur courant (protégé) – requiert Authorization: Bearer <token>. Story 7.1 : inclut isAdmin pour afficher l'accès dashboard.
    async fn me(&self, ctx: &Context<'_>) -> Result<CurrentUser, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let (user_id, role) = auth.validate_token_claims(token).map_err(Error::from)?;
        Ok(CurrentUser {
            id: user_id,
            is_admin: role == Role::Admin,
        })
    }

    /// Vue d'ensemble dashboard admin (Story 7.1 – FR61). Réservé aux admins ; 403 si non-admin.
    async fn get_admin_dashboard(&self, ctx: &Context<'_>) -> Result<DashboardOverview, Error> {
        let _admin_id = require_admin(ctx)?;
        let admin_svc = ctx.data::<Arc<AdminService>>()?;
        Ok(admin_svc.get_dashboard_overview().await)
    }

    /// Métriques techniques (perfs, santé, crashs) – admin uniquement (Story 7.4 – FR68).
    async fn get_technical_metrics(&self, ctx: &Context<'_>) -> Result<TechnicalMetrics, Error> {
        let _admin_id = require_admin(ctx)?;
        let admin_svc = ctx.data::<Arc<AdminService>>()?;
        Ok(admin_svc.get_technical_metrics())
    }

    /// Analytics utilisateurs (actifs, complétions) – admin uniquement (Story 7.4 – FR69, FR70).
    async fn get_user_analytics(&self, ctx: &Context<'_>) -> Result<UserAnalytics, Error> {
        let _admin_id = require_admin(ctx)?;
        let analytics_svc = ctx.data::<Arc<AnalyticsService>>()?;
        Ok(analytics_svc.get_user_analytics().await)
    }

    /// Taux de complétion par enquête – admin uniquement (Story 7.4 – FR70).
    async fn get_completion_rates(
        &self,
        ctx: &Context<'_>,
    ) -> Result<Vec<CompletionRateEntry>, Error> {
        let _admin_id = require_admin(ctx)?;
        let analytics_svc = ctx.data::<Arc<AnalyticsService>>()?;
        Ok(analytics_svc.get_completion_rates().await)
    }

    /// Parcours utilisateur (funnel) – admin uniquement (Story 7.4 – FR71).
    async fn get_user_journey_analytics(
        &self,
        ctx: &Context<'_>,
    ) -> Result<UserJourneyAnalytics, Error> {
        let _admin_id = require_admin(ctx)?;
        let analytics_svc = ctx.data::<Arc<AnalyticsService>>()?;
        Ok(analytics_svc.get_user_journey_analytics().await)
    }

    /// Liste des enquêtes disponibles (Story 2.1). Les non-admins ne voient que les enquêtes publiées (Story 7.3 – FR66).
    async fn list_investigations(
        &self,
        ctx: &Context<'_>,
    ) -> Result<Vec<crate::models::investigation::Investigation>, Error> {
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        let list = svc.list_investigations().await;
        let is_admin = ctx
            .data::<BearerToken>()
            .ok()
            .and_then(|t| t.0.as_deref())
            .filter(|s| !s.is_empty())
            .and_then(|token| {
                let auth = ctx.data::<Arc<AuthService>>().ok()?;
                auth.validate_token_claims(token).ok()
            })
            .map(|(_, role)| role == Role::Admin)
            .unwrap_or(false);
        let list = if is_admin {
            list
        } else {
            list.into_iter()
                .filter(|i| i.status == "published")
                .collect()
        };
        Ok(list)
    }

    /// Enquête par id avec liste ordonnée d'énigmes (Story 3.1) – pour écran « enquête en cours ».
    /// Les non-admins ne voient pas les enquêtes brouillon (Story 7.3 – FR66).
    async fn investigation(
        &self,
        ctx: &Context<'_>,
        id: String,
    ) -> Result<Option<crate::models::investigation::InvestigationWithEnigmas>, Error> {
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID enquête invalide"))?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        let result = svc.get_investigation_by_id_with_enigmas(id).await;
        if let Some(ref r) = result {
            if r.investigation.status == "draft" {
                let is_admin = ctx
                    .data::<BearerToken>()
                    .ok()
                    .and_then(|t| t.0.as_deref())
                    .filter(|s| !s.is_empty())
                    .and_then(|token| {
                        let auth = ctx.data::<Arc<AuthService>>().ok()?;
                        auth.validate_token_claims(token).ok()
                    })
                    .map(|(_, role)| role == Role::Admin)
                    .unwrap_or(false);
                if !is_admin {
                    return Ok(None);
                }
            }
        }
        Ok(result)
    }

    /// Prévisualisation d'une enquête (brouillon ou publiée) avec énigmes – admin uniquement (Story 7.3 – FR65).
    async fn investigation_for_preview(
        &self,
        ctx: &Context<'_>,
        id: String,
    ) -> Result<Option<crate::models::investigation::InvestigationWithEnigmas>, Error> {
        let _admin_id = require_admin(ctx)?;
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID enquête invalide"))?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        Ok(svc.get_investigation_by_id_with_enigmas(id).await)
    }

    /// Indices progressifs par énigme (Story 4.3 – FR30). Requiert authentification.
    async fn get_enigma_hints(
        &self,
        ctx: &Context<'_>,
        enigma_id: String,
    ) -> Result<EnigmaHints, Error> {
        let _ = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        ctx.data::<Arc<AuthService>>()?
            .validate_token(token)
            .map_err(Error::from)?;

        let enigma_svc = ctx.data::<Arc<EnigmaService>>()?;
        let id = Uuid::parse_str(&enigma_id).map_err(|_| Error::new("ID énigme invalide"))?;
        enigma_svc.get_enigma_hints(id).map_err(Error::from)
    }

    /// Explications historiques et éducatives par énigme (Story 4.3 – FR31, FR32). Requiert authentification.
    async fn get_enigma_explanation(
        &self,
        ctx: &Context<'_>,
        enigma_id: String,
    ) -> Result<EnigmaExplanation, Error> {
        let _ = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        ctx.data::<Arc<AuthService>>()?
            .validate_token(token)
            .map_err(Error::from)?;

        let enigma_svc = ctx.data::<Arc<EnigmaService>>()?;
        let id = Uuid::parse_str(&enigma_id).map_err(|_| Error::new("ID énigme invalide"))?;
        enigma_svc.get_enigma_explanation(id).map_err(Error::from)
    }

    /// Contenu LORE par enquête et index de séquence (Story 4.4 – FR34, FR37). Lecture seule.
    /// sequence_index 0 = intro, 1+ = séquences entre énigmes.
    async fn get_lore_content(
        &self,
        ctx: &Context<'_>,
        investigation_id: String,
        sequence_index: i32,
    ) -> Result<Option<LoreContent>, Error> {
        let lore_svc = ctx.data::<Arc<LoreService>>()?;
        let id =
            Uuid::parse_str(&investigation_id).map_err(|_| Error::new("ID enquête invalide"))?;
        Ok(lore_svc.get_lore_content(id, sequence_index))
    }

    /// Index des séquences LORE définies pour une enquête (ordre d'affichage). Story 4.4 – code review.
    async fn get_lore_sequence_indexes(
        &self,
        ctx: &Context<'_>,
        investigation_id: String,
    ) -> Result<Vec<i32>, Error> {
        let lore_svc = ctx.data::<Arc<LoreService>>()?;
        let id =
            Uuid::parse_str(&investigation_id).map_err(|_| Error::new("ID enquête invalide"))?;
        Ok(lore_svc.get_lore_sequence_indexes(id))
    }

    /// Badges débloqués par l'utilisateur courant (Story 5.2 – FR42). Requiert authentification.
    async fn get_user_badges(&self, ctx: &Context<'_>) -> Result<Vec<UserBadge>, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let gamification_svc = ctx.data::<Arc<GamificationService>>()?;
        Ok(gamification_svc.get_user_badges(user_id))
    }

    /// Compétences détective par utilisateur courant (Story 5.2 – FR43). Requiert authentification.
    async fn get_user_skills(&self, ctx: &Context<'_>) -> Result<Vec<UserSkill>, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let gamification_svc = ctx.data::<Arc<GamificationService>>()?;
        Ok(gamification_svc.get_user_skills(user_id))
    }

    /// Cartes postales virtuelles par utilisateur courant (Story 5.2 – FR44). Requiert authentification.
    async fn get_user_postcards(&self, ctx: &Context<'_>) -> Result<Vec<UserPostcard>, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let gamification_svc = ctx.data::<Arc<GamificationService>>()?;
        Ok(gamification_svc.get_user_postcards(user_id))
    }

    /// Leaderboard global ou par enquête (Story 5.2 – FR45). Requiert authentification.
    async fn get_leaderboard(
        &self,
        ctx: &Context<'_>,
        investigation_id: Option<String>,
    ) -> Result<Vec<LeaderboardEntry>, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let inv_id = investigation_id
            .as_ref()
            .and_then(|s| Uuid::parse_str(s).ok());
        let gamification_svc = ctx.data::<Arc<GamificationService>>()?;
        Ok(gamification_svc.get_leaderboard(user_id, inv_id))
    }

    /// Enquêtes achetées par l'utilisateur courant (Story 6.2 – FR48). Requiert authentification.
    async fn get_user_purchases(&self, ctx: &Context<'_>) -> Result<Vec<String>, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let payment_svc = ctx.data::<Arc<PaymentService>>()?;
        let ids = payment_svc.get_user_purchases(user_id);
        Ok(ids.iter().map(Uuid::to_string).collect())
    }
}

pub struct MutationRoot;

#[Object]
impl MutationRoot {
    /// Inscription : email + mot de passe → JWT (Story 1.2).
    async fn register(
        &self,
        ctx: &Context<'_>,
        email: String,
        password: String,
    ) -> Result<String, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let input = RegisterInput { email, password };
        auth.register(input).map_err(Error::from)
    }

    /// Validation d'une réponse d'énigme (Story 4.1) – géo (userLat/userLng) ou photo (photoUrl/photoBase64).
    /// Requiert authentification (Authorization: Bearer <token>).
    async fn validate_enigma_response(
        &self,
        ctx: &Context<'_>,
        enigma_id: String,
        payload: ValidateEnigmaPayload,
    ) -> Result<ValidateEnigmaResult, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token
            .as_deref()
            .ok_or_else(|| Error::new("Authentification requise"))?;
        auth.validate_token(token).map_err(Error::from)?;

        let enigma_svc = ctx.data::<Arc<EnigmaService>>()?;
        let id = Uuid::parse_str(&enigma_id).map_err(|_| Error::new("ID énigme invalide"))?;
        enigma_svc
            .validate_response(id, payload)
            .map_err(Error::from)
    }

    /// Enregistre une intention d'achat (clic Acheter/Payer) – Story 6.2 FR52. Requiert authentification.
    async fn record_purchase_intent(
        &self,
        ctx: &Context<'_>,
        investigation_id: String,
    ) -> Result<bool, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token
            .as_deref()
            .ok_or_else(|| Error::new("Authentification requise"))?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let inv_id =
            Uuid::parse_str(&investigation_id).map_err(|_| Error::new("ID enquête invalide"))?;
        let inv_svc = ctx.data::<Arc<InvestigationService>>()?;
        if inv_svc
            .get_investigation_by_id_with_enigmas(inv_id)
            .await
            .is_none()
        {
            return Err(Error::new("Enquête introuvable"));
        }
        let payment_svc = ctx.data::<Arc<PaymentService>>()?;
        payment_svc
            .record_purchase_intent(user_id, inv_id)
            .map_err(Error::from)?;
        Ok(true)
    }

    /// Simule un achat réussi (MVP) – Story 6.2 FR48, FR53. Requiert authentification.
    async fn simulate_purchase(
        &self,
        ctx: &Context<'_>,
        investigation_id: String,
    ) -> Result<bool, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token
            .as_deref()
            .ok_or_else(|| Error::new("Authentification requise"))?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let inv_id =
            Uuid::parse_str(&investigation_id).map_err(|_| Error::new("ID enquête invalide"))?;
        let inv_svc = ctx.data::<Arc<InvestigationService>>()?;
        if inv_svc
            .get_investigation_by_id_with_enigmas(inv_id)
            .await
            .is_none()
        {
            return Err(Error::new("Enquête introuvable"));
        }
        let payment_svc = ctx.data::<Arc<PaymentService>>()?;
        payment_svc
            .simulate_purchase(user_id, inv_id)
            .map_err(Error::from)?;
        Ok(true)
    }

    /// Enregistre « enquête démarrée » pour analytics (Story 7.4 – FR70). Requiert authentification.
    async fn record_investigation_started(
        &self,
        ctx: &Context<'_>,
        investigation_id: String,
    ) -> Result<bool, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token
            .as_deref()
            .ok_or_else(|| Error::new("Authentification requise"))?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let inv_id =
            Uuid::parse_str(&investigation_id).map_err(|_| Error::new("ID enquête invalide"))?;
        let inv_svc = ctx.data::<Arc<InvestigationService>>()?;
        if inv_svc
            .get_investigation_by_id_with_enigmas(inv_id)
            .await
            .is_none()
        {
            return Err(Error::new("Enquête introuvable"));
        }
        let analytics_svc = ctx.data::<Arc<AnalyticsService>>()?;
        analytics_svc
            .record_investigation_started(user_id, inv_id)
            .await;
        Ok(true)
    }

    /// Enregistre « enquête complétée » pour analytics (Story 7.4 – FR70). Requiert authentification.
    async fn record_investigation_completed(
        &self,
        ctx: &Context<'_>,
        investigation_id: String,
    ) -> Result<bool, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token
            .as_deref()
            .ok_or_else(|| Error::new("Authentification requise"))?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        let inv_id =
            Uuid::parse_str(&investigation_id).map_err(|_| Error::new("ID enquête invalide"))?;
        let inv_svc = ctx.data::<Arc<InvestigationService>>()?;
        if inv_svc
            .get_investigation_by_id_with_enigmas(inv_id)
            .await
            .is_none()
        {
            return Err(Error::new("Enquête introuvable"));
        }
        let analytics_svc = ctx.data::<Arc<AnalyticsService>>()?;
        analytics_svc
            .record_investigation_completed(user_id, inv_id)
            .await;
        Ok(true)
    }

    /// Enregistre le token push FCM/APNs pour l'utilisateur connecté (Story 8.1 – FR85, FR86, FR87).
    /// Upsert par (user_id, platform). Requiert authentification.
    async fn register_push_token(
        &self,
        ctx: &Context<'_>,
        token: String,
        platform: String,
    ) -> Result<bool, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let bearer = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let bearer = bearer
            .as_deref()
            .ok_or_else(|| Error::new("Authentification requise"))?;
        let user_id = auth.validate_token(bearer).map_err(Error::from)?;
        let push_svc = ctx.data::<Arc<PushService>>()?;
        push_svc
            .register_token(user_id, token, platform)
            .map_err(Error::from)?;
        Ok(true)
    }

    /// Crée une enquête (admin, Story 7.2 – FR62). Réservé aux admins.
    async fn create_investigation(
        &self,
        ctx: &Context<'_>,
        input: CreateInvestigationInput,
    ) -> Result<crate::models::investigation::Investigation, Error> {
        let _admin_id = require_admin(ctx)?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        svc.create_investigation(input).await.map_err(Error::from)
    }

    /// Met à jour une enquête (admin, Story 7.2 – FR62). Réservé aux admins.
    async fn update_investigation(
        &self,
        ctx: &Context<'_>,
        id: String,
        input: UpdateInvestigationInput,
    ) -> Result<crate::models::investigation::Investigation, Error> {
        let _admin_id = require_admin(ctx)?;
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID enquête invalide"))?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        svc.update_investigation(id, input)
            .await
            .map_err(Error::from)
    }

    /// Publie une enquête (draft → published) – admin uniquement (Story 7.3 – FR66).
    /// Story 8.1 (FR85) : envoie une notification push « Nouvelle enquête » aux tokens enregistrés.
    async fn publish_investigation(
        &self,
        ctx: &Context<'_>,
        id: String,
    ) -> Result<crate::models::investigation::Investigation, Error> {
        let _admin_id = require_admin(ctx)?;
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID enquête invalide"))?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        let inv = svc.publish_investigation(id).await.map_err(Error::from)?;
        let push_svc = ctx.data::<Arc<PushService>>();
        if let Ok(push) = push_svc {
            let tokens: Vec<String> = push
                .list_all_tokens()
                .into_iter()
                .map(|e| e.token)
                .collect();
            let mut data = std::collections::HashMap::new();
            data.insert("investigation_id".to_string(), inv.id.to_string());
            data.insert("type".to_string(), "new_investigation".to_string());
            if let Err(e) = push
                .send_notification(
                    &tokens,
                    &format!("Nouvelle enquête : {}", inv.titre),
                    "Une nouvelle enquête est disponible.",
                    Some(data),
                )
                .await
            {
                tracing::warn!("Push after publish failed: {}", e);
            }
        }
        Ok(inv)
    }

    /// Dépublie une enquête (published → draft) – admin uniquement (Story 7.3 – FR67).
    async fn rollback_investigation(
        &self,
        ctx: &Context<'_>,
        id: String,
    ) -> Result<crate::models::investigation::Investigation, Error> {
        let _admin_id = require_admin(ctx)?;
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID enquête invalide"))?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        svc.rollback_investigation(id).await.map_err(Error::from)
    }

    /// Crée une énigme (admin, Story 7.2 – FR63). Réservé aux admins.
    async fn create_enigma(
        &self,
        ctx: &Context<'_>,
        input: CreateEnigmaInput,
    ) -> Result<crate::models::enigma::Enigma, Error> {
        let _admin_id = require_admin(ctx)?;
        let enigma_svc = ctx.data::<Arc<EnigmaService>>()?;
        enigma_svc.create_enigma(input).map_err(Error::from)
    }

    /// Met à jour une énigme (admin, Story 7.2 – FR63). Réservé aux admins.
    async fn update_enigma(
        &self,
        ctx: &Context<'_>,
        id: String,
        input: UpdateEnigmaInput,
    ) -> Result<crate::models::enigma::Enigma, Error> {
        let _admin_id = require_admin(ctx)?;
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID énigme invalide"))?;
        let enigma_svc = ctx.data::<Arc<EnigmaService>>()?;
        enigma_svc.update_enigma(id, input).map_err(Error::from)
    }

    /// Marque le contenu historique d'une énigme comme validé (Story 7.2 – FR64). Réservé aux admins.
    async fn validate_enigma_historical_content(
        &self,
        ctx: &Context<'_>,
        enigma_id: String,
    ) -> Result<crate::models::enigma::Enigma, Error> {
        let _admin_id = require_admin(ctx)?;
        let id = Uuid::parse_str(&enigma_id).map_err(|_| Error::new("ID énigme invalide"))?;
        let enigma_svc = ctx.data::<Arc<EnigmaService>>()?;
        enigma_svc
            .validate_enigma_historical_content(id)
            .map_err(Error::from)
    }
}

#[derive(Deserialize)]
pub struct GraphQLRequest {
    query: String,
    #[serde(default)]
    variables: Option<serde_json::Value>,
}

pub async fn graphql_handler(
    State(schema): State<AppSchema>,
    headers: axum::http::HeaderMap,
    Json(req): Json<GraphQLRequest>,
) -> impl IntoResponse {
    let start = std::time::Instant::now();
    let bearer = extract_bearer(&headers);
    let gql_request = async_graphql::Request::new(req.query)
        .variables(Variables::from_json(
            req.variables.unwrap_or(serde_json::Value::Null),
        ))
        .data(bearer);
    let res = schema.execute(gql_request).await;
    let elapsed_ms = start.elapsed().as_millis() as u64;
    let status = if res.is_ok() {
        metrics::record_request(elapsed_ms, false);
        StatusCode::OK
    } else {
        metrics::record_request(elapsed_ms, true);
        StatusCode::BAD_REQUEST
    };
    (status, Json(serde_json::to_value(res).unwrap()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::services::analytics_service::AnalyticsService;
    use crate::services::auth_service::AuthService;
    use crate::services::enigma_service::EnigmaService;
    use crate::services::gamification_service::GamificationService;
    use crate::services::investigation_service::InvestigationService;
    use crate::services::lore_service::LoreService;

    /// Test listInvestigations sans serveur HTTP – exécutable en CI.
    #[tokio::test]
    async fn list_investigations_in_process_returns_array() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth,
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            Arc::new(PaymentService::new()),
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );
        let request = async_graphql::Request::new(
            r#"query { listInvestigations { id titre description durationEstimate difficulte isFree priceAmount priceCurrency } }"#,
        );
        let res = schema.execute(request).await;
        assert!(res.is_ok(), "errors: {:?}", res.errors);
        let data = res.data.into_json().unwrap();
        let list = data
            .get("listInvestigations")
            .and_then(|v| v.as_array())
            .expect("listInvestigations array");
        assert!(!list.is_empty(), "mock doit retourner au moins un item");
        let first = &list[0];
        assert!(first.get("id").is_some());
        assert!(first.get("titre").is_some());
        assert!(first.get("description").is_some());
        assert!(first.get("durationEstimate").is_some());
        assert!(first.get("difficulte").is_some());
        assert!(first.get("isFree").is_some());
        assert_eq!(
            first.get("isFree").and_then(|v| v.as_bool()),
            Some(true),
            "première enquête = première gratuite (FR46)"
        );
        assert!(
            first.get("priceAmount").is_none_or(|v| v.is_null()),
            "gratuite : priceAmount null"
        );
        assert!(
            first.get("priceCurrency").is_none_or(|v| v.is_null()),
            "gratuite : priceCurrency null"
        );
        if list.len() >= 2 {
            let second = &list[1];
            assert_eq!(second.get("isFree").and_then(|v| v.as_bool()), Some(false));
            assert_eq!(
                second.get("priceAmount").and_then(|v| v.as_u64()),
                Some(299),
                "payante : prix 2,99 € (FR47, FR49)"
            );
            assert_eq!(
                second.get("priceCurrency").and_then(|v| v.as_str()),
                Some("EUR")
            );
        }
    }

    /// Test investigation(id) retourne isFree, priceAmount, priceCurrency (Story 6.1 – écran détail).
    #[tokio::test]
    async fn investigation_by_id_returns_price_fields_for_paid() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth,
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            Arc::new(PaymentService::new()),
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );
        let id_paid = "22222222-2222-2222-2222-222222222222";
        let request = async_graphql::Request::new(format!(
            r#"query {{ investigation(id: "{}") {{ investigation {{ id titre isFree priceAmount priceCurrency }} enigmas {{ id }} }} }}"#,
            id_paid
        ));
        let res = schema.execute(request).await;
        assert!(res.is_ok(), "errors: {:?}", res.errors);
        let data = res.data.into_json().unwrap();
        let root = data
            .get("investigation")
            .and_then(|v| v.as_object())
            .expect("investigation");
        let inv = root
            .get("investigation")
            .and_then(|v| v.as_object())
            .expect("investigation.investigation");
        assert_eq!(inv.get("id").and_then(|v| v.as_str()).unwrap(), id_paid);
        assert_eq!(inv.get("isFree").and_then(|v| v.as_bool()), Some(false));
        assert_eq!(inv.get("priceAmount").and_then(|v| v.as_u64()), Some(299));
        assert_eq!(
            inv.get("priceCurrency").and_then(|v| v.as_str()),
            Some("EUR")
        );
    }

    /// Test investigation(id) avec liste énigmes ordonnée (Story 3.1) – exécutable en CI.
    #[tokio::test]
    async fn investigation_by_id_returns_investigation_with_enigmas() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth,
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            Arc::new(PaymentService::new()),
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );
        let id = "11111111-1111-1111-1111-111111111111";
        let request = async_graphql::Request::new(format!(
            r#"query {{ investigation(id: "{}") {{ investigation {{ id titre }} enigmas {{ id orderIndex type titre }} }} }}"#,
            id
        ));
        let res = schema.execute(request).await;
        assert!(res.is_ok(), "errors: {:?}", res.errors);
        let data = res.data.into_json().unwrap();
        let root = data
            .get("investigation")
            .and_then(|v| v.as_object())
            .expect("investigation");
        let inv = root
            .get("investigation")
            .and_then(|v| v.as_object())
            .expect("investigation.investigation");
        assert_eq!(inv.get("id").and_then(|v| v.as_str()).unwrap(), id);
        assert!(inv.get("titre").is_some());
        let enigmas = root
            .get("enigmas")
            .and_then(|v| v.as_array())
            .expect("enigmas array");
        assert!(!enigmas.is_empty(), "doit retourner au moins une énigme");
        let first = enigmas[0].as_object().unwrap();
        assert!(first.get("id").is_some());
        assert!(first.get("orderIndex").is_some());
        assert!(first.get("type").is_some());
        assert!(first.get("titre").is_some());
    }

    /// Test getLoreContent (Story 4.4 – FR34, FR37) – cas nominal.
    #[tokio::test]
    async fn get_lore_content_returns_content_for_investigation_and_sequence() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth,
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            Arc::new(PaymentService::new()),
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );
        let id = "11111111-1111-1111-1111-111111111111";
        let request = async_graphql::Request::new(format!(
            r#"query {{ getLoreContent(investigationId: "{}", sequenceIndex: 0) {{ sequenceIndex title contentText mediaUrls }} }}"#,
            id
        ));
        let res = schema.execute(request).await;
        assert!(res.is_ok(), "errors: {:?}", res.errors);
        let data = res.data.into_json().unwrap();
        let lore = data
            .get("getLoreContent")
            .and_then(|v| v.as_object())
            .expect("getLoreContent object");
        assert_eq!(
            lore.get("sequenceIndex").and_then(|v| v.as_i64()).unwrap(),
            0
        );
        assert!(!lore
            .get("title")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty());
        assert!(!lore
            .get("contentText")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty());
        let urls = lore
            .get("mediaUrls")
            .and_then(|v| v.as_array())
            .expect("mediaUrls array");
        assert!(!urls.is_empty());
    }

    /// Test getLoreContent retourne null quand pas de contenu à cet index (code review).
    #[tokio::test]
    async fn get_lore_content_returns_null_for_unknown_sequence_index() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth,
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            Arc::new(PaymentService::new()),
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );
        let id = "11111111-1111-1111-1111-111111111111";
        let request = async_graphql::Request::new(format!(
            r#"query {{ getLoreContent(investigationId: "{}", sequenceIndex: 99) {{ sequenceIndex title }} }}"#,
            id
        ));
        let res = schema.execute(request).await;
        assert!(res.is_ok(), "errors: {:?}", res.errors);
        let data = res.data.into_json().unwrap();
        let lore = data.get("getLoreContent");
        assert!(
            lore == Some(&serde_json::Value::Null),
            "getLoreContent(sequenceIndex 99) doit retourner null"
        );
    }

    /// Test getLoreSequenceIndexes (code review – API exposée).
    #[tokio::test]
    async fn get_lore_sequence_indexes_returns_ordered_list() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth,
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            Arc::new(PaymentService::new()),
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );
        let id = "11111111-1111-1111-1111-111111111111";
        let request = async_graphql::Request::new(format!(
            r#"query {{ getLoreSequenceIndexes(investigationId: "{}") }}"#,
            id
        ));
        let res = schema.execute(request).await;
        assert!(res.is_ok(), "errors: {:?}", res.errors);
        let data = res.data.into_json().unwrap();
        let indexes = data
            .get("getLoreSequenceIndexes")
            .and_then(|v| v.as_array())
            .expect("getLoreSequenceIndexes array");
        assert!(!indexes.is_empty());
        assert_eq!(indexes[0].as_i64(), Some(0));
        assert_eq!(indexes[1].as_i64(), Some(1));
    }

    /// Test recordPurchaseIntent + simulatePurchase + getUserPurchases (Story 6.2 – FR48, FR52).
    #[tokio::test]
    async fn payment_record_intent_and_simulate_purchase_persist_and_read() {
        use crate::api::middleware::auth::BearerToken;

        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let lore_svc = Arc::new(LoreService::new());
        let gamification_svc = Arc::new(GamificationService::new());
        let payment_svc = Arc::new(PaymentService::new());
        let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
        let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
        let schema = create_schema(
            auth.clone(),
            inv_svc,
            enigma_svc,
            lore_svc,
            gamification_svc,
            payment_svc,
            admin_svc,
            analytics_svc,
            Arc::new(PushService::new()),
        );

        let register_req = async_graphql::Request::new(
            r#"mutation { register(email: "payment-test@example.com", password: "password123") }"#,
        );
        let reg_res = schema.execute(register_req).await;
        assert!(reg_res.is_ok(), "register: {:?}", reg_res.errors);
        let token = reg_res
            .data
            .into_json()
            .unwrap()
            .get("register")
            .and_then(|v| v.as_str())
            .expect("register returns JWT")
            .to_string();

        let inv_id = "22222222-2222-2222-2222-222222222222";

        let record_req = async_graphql::Request::new(format!(
            r#"mutation {{ recordPurchaseIntent(investigationId: "{}") }}"#,
            inv_id
        ))
        .data(BearerToken(Some(token.clone())));

        let record_res = schema.execute(record_req).await;
        assert!(
            record_res.is_ok(),
            "recordPurchaseIntent: {:?}",
            record_res.errors
        );
        let record_ok = record_res
            .data
            .into_json()
            .unwrap()
            .get("recordPurchaseIntent")
            .and_then(|v| v.as_bool());
        assert_eq!(record_ok, Some(true));

        let sim_req = async_graphql::Request::new(format!(
            r#"mutation {{ simulatePurchase(investigationId: "{}") }}"#,
            inv_id
        ))
        .data(BearerToken(Some(token.clone())));

        let sim_res = schema.execute(sim_req).await;
        assert!(sim_res.is_ok(), "simulatePurchase: {:?}", sim_res.errors);
        let sim_ok = sim_res
            .data
            .into_json()
            .unwrap()
            .get("simulatePurchase")
            .and_then(|v| v.as_bool());
        assert_eq!(sim_ok, Some(true));

        let get_req = async_graphql::Request::new(r#"query { getUserPurchases }"#)
            .data(BearerToken(Some(token)));
        let get_res = schema.execute(get_req).await;
        assert!(get_res.is_ok(), "getUserPurchases: {:?}", get_res.errors);
        let data = get_res.data.into_json().unwrap();
        let ids = data
            .get("getUserPurchases")
            .and_then(|v| v.as_array())
            .expect("getUserPurchases array");
        assert!(
            ids.iter().any(|v| v.as_str() == Some(inv_id)),
            "getUserPurchases doit contenir l'enquête achetée: {:?}",
            ids
        );
    }
}
