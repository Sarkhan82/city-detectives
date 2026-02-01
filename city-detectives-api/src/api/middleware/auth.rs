//! Extraction du token Bearer depuis le header Authorization (routes protégées).

use axum::http::HeaderMap;

/// Token Bearer extrait du header Authorization.
#[derive(Clone)]
pub struct BearerToken(pub Option<String>);

/// Extrait le token depuis `Authorization: Bearer <token>`.
pub fn extract_bearer(headers: &HeaderMap) -> BearerToken {
    let token = headers
        .get("Authorization")
        .and_then(|v| v.to_str().ok())
        .filter(|s| s.starts_with("Bearer "))
        .map(|s| s[7..].trim().to_string());
    BearerToken(token)
}
