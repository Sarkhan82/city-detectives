//! Schéma GraphQL (Story 1.2, 2.1, 4.1, 4.3) – register, me, listInvestigations, validateEnigmaResponse, getEnigmaHints, getEnigmaExplanation.

use async_graphql::*;
use axum::extract::State;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::Json;
use serde::Deserialize;
use std::sync::Arc;

use crate::api::middleware::auth::{extract_bearer, BearerToken};
use crate::models::enigma::{
    EnigmaExplanation, EnigmaHints, ValidateEnigmaPayload, ValidateEnigmaResult,
};
use crate::models::user::RegisterInput;
use crate::services::auth_service::AuthService;
use crate::services::enigma_service::EnigmaService;
use crate::services::investigation_service::InvestigationService;
use uuid::Uuid;

pub type AppSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

pub fn create_schema(
    auth_service: Arc<AuthService>,
    investigation_service: Arc<InvestigationService>,
    enigma_service: Arc<EnigmaService>,
) -> AppSchema {
    Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(auth_service)
        .data(investigation_service)
        .data(enigma_service)
        .finish()
}

pub struct QueryRoot;

#[Object]
impl QueryRoot {
    async fn health(&self) -> &'static str {
        "ok"
    }

    /// Utilisateur courant (protégé) – requiert Authorization: Bearer <token>.
    async fn me(&self, ctx: &Context<'_>) -> Result<String, Error> {
        let auth = ctx.data::<Arc<AuthService>>()?;
        let token = ctx.data::<BearerToken>().ok().and_then(|t| t.0.clone());
        let token = token.as_deref().ok_or("Token manquant")?;
        let user_id = auth.validate_token(token).map_err(Error::from)?;
        Ok(user_id.to_string())
    }

    /// Liste des enquêtes disponibles (Story 2.1) – durée, difficulté, description.
    async fn list_investigations(
        &self,
        ctx: &Context<'_>,
    ) -> Result<Vec<crate::models::investigation::Investigation>, Error> {
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        Ok(svc.list_investigations())
    }

    /// Enquête par id avec liste ordonnée d'énigmes (Story 3.1) – pour écran « enquête en cours ».
    async fn investigation(
        &self,
        ctx: &Context<'_>,
        id: String,
    ) -> Result<Option<crate::models::investigation::InvestigationWithEnigmas>, Error> {
        let id = Uuid::parse_str(&id).map_err(|_| Error::new("ID enquête invalide"))?;
        let svc = ctx.data::<Arc<InvestigationService>>()?;
        Ok(svc.get_investigation_by_id_with_enigmas(id))
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
    let bearer = extract_bearer(&headers);
    let gql_request = async_graphql::Request::new(req.query)
        .variables(Variables::from_json(
            req.variables.unwrap_or(serde_json::Value::Null),
        ))
        .data(bearer);
    let res = schema.execute(gql_request).await;
    let status = if res.is_ok() {
        StatusCode::OK
    } else {
        StatusCode::BAD_REQUEST
    };
    (status, Json(serde_json::to_value(res).unwrap()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::services::auth_service::AuthService;
    use crate::services::enigma_service::EnigmaService;
    use crate::services::investigation_service::InvestigationService;

    /// Test listInvestigations sans serveur HTTP – exécutable en CI.
    #[tokio::test]
    async fn list_investigations_in_process_returns_array() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let schema = create_schema(auth, inv_svc, enigma_svc);
        let request = async_graphql::Request::new(
            r#"query { listInvestigations { id titre description durationEstimate difficulte isFree } }"#,
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
    }

    /// Test investigation(id) avec liste énigmes ordonnée (Story 3.1) – exécutable en CI.
    #[tokio::test]
    async fn investigation_by_id_returns_investigation_with_enigmas() {
        let auth = Arc::new(AuthService::default());
        let enigma_svc = Arc::new(EnigmaService::new());
        let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
        let schema = create_schema(auth, inv_svc, enigma_svc);
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
}
