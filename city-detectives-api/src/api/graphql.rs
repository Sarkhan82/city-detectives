//! Schéma GraphQL (Story 1.2, 2.1) – register, me, listInvestigations.

use async_graphql::*;
use axum::extract::State;
use axum::http::StatusCode;
use axum::response::IntoResponse;
use axum::Json;
use serde::Deserialize;
use std::sync::Arc;

use crate::api::middleware::auth::{extract_bearer, BearerToken};
use crate::models::user::RegisterInput;
use crate::services::auth_service::AuthService;
use crate::services::investigation_service::InvestigationService;

pub type AppSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

pub fn create_schema(
    auth_service: Arc<AuthService>,
    investigation_service: Arc<InvestigationService>,
) -> AppSchema {
    Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(auth_service)
        .data(investigation_service)
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
    use crate::services::investigation_service::InvestigationService;

    /// Test listInvestigations sans serveur HTTP – exécutable en CI.
    #[tokio::test]
    async fn list_investigations_in_process_returns_array() {
        let auth = Arc::new(AuthService::default());
        let inv_svc = Arc::new(InvestigationService::new());
        let schema = create_schema(auth, inv_svc);
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
}
