//! Schéma GraphQL (Story 1.2) – mutation register, requête protégée me, JWT.

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

pub type AppSchema = Schema<QueryRoot, MutationRoot, EmptySubscription>;

pub fn create_schema(auth_service: Arc<AuthService>) -> AppSchema {
    Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(auth_service)
        .finish()
}

struct QueryRoot;

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
}

struct MutationRoot;

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
