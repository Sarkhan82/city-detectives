//! City Detectives API – point d'entrée (Story 1.2 – auth JWT).
//! Lance le serveur Axum avec route GraphQL (mutation register).

use axum::{routing::post, Router};
use std::sync::Arc;
use tower_http::cors::{Any, CorsLayer};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod api;
mod db;
mod models;
mod services;

use api::graphql::create_schema;
use services::auth_service::{self, AuthService};

#[tokio::main]
async fn main() {
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "info".into()),
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    let jwt_secret = std::env::var("JWT_SECRET")
        .map(|s| s.into_bytes())
        .unwrap_or_else(|_| auth_service::default_jwt_secret());
    let auth_service = Arc::new(AuthService::new(jwt_secret));
    let schema = create_schema(auth_service);

    let app = Router::new()
        .route("/graphql", post(api::graphql::graphql_handler))
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any),
        )
        .with_state(schema);

    let addr = std::net::SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::info!("Listening on {}", addr);
    axum::serve(tokio::net::TcpListener::bind(addr).await.unwrap(), app)
        .await
        .unwrap();
}
