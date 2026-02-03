//! Tests d'intégration API admin (Story 7.1 – FR61).
//! getAdminDashboard avec JWT admin → données ; avec JWT utilisateur normal → erreur 403 / FORBIDDEN.

use async_graphql::Request;
use city_detectives_api::api::graphql::create_schema;
use city_detectives_api::api::middleware::auth::BearerToken;
use city_detectives_api::services::admin_service::AdminService;
use city_detectives_api::services::auth_service::AuthService;
use city_detectives_api::services::enigma_service::EnigmaService;
use city_detectives_api::services::gamification_service::GamificationService;
use city_detectives_api::services::investigation_service::InvestigationService;
use city_detectives_api::services::lore_service::LoreService;
use city_detectives_api::services::payment_service::PaymentService;
use std::sync::Arc;

fn make_schema() -> city_detectives_api::api::graphql::AppSchema {
    let auth = Arc::new(AuthService::default());
    let enigma_svc = Arc::new(EnigmaService::new());
    let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
    let lore_svc = Arc::new(LoreService::new());
    let gamification_svc = Arc::new(GamificationService::new());
    let payment_svc = Arc::new(PaymentService::new());
    let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
    create_schema(
        auth,
        inv_svc,
        enigma_svc,
        lore_svc,
        gamification_svc,
        payment_svc,
        admin_svc,
    )
}

/// Enregistre un utilisateur admin (email seed Story 7.1) et retourne le JWT.
async fn get_admin_token(schema: &city_detectives_api::api::graphql::AppSchema) -> String {
    let request = Request::new(
        r#"mutation { register(email: "admin@city-detectives.local", password: "password123") }"#,
    );
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "register admin must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    data.get("register")
        .and_then(|v| v.as_str())
        .expect("register returns JWT string")
        .to_string()
}

/// Enregistre un utilisateur normal et retourne le JWT.
async fn get_user_token(schema: &city_detectives_api::api::graphql::AppSchema) -> String {
    let request = Request::new(
        r#"mutation { register(email: "user-dashboard-test@example.com", password: "password123") }"#,
    );
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "register user must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    data.get("register")
        .and_then(|v| v.as_str())
        .expect("register returns JWT string")
        .to_string()
}

#[tokio::test]
async fn me_returns_is_admin_true_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let request = Request::new(r#"query { me { id isAdmin } }"#).data(BearerToken(Some(token)));

    let res = schema.execute(request).await;
    assert!(res.is_ok(), "me must succeed for admin: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let me = data
        .get("me")
        .and_then(|v| v.as_object())
        .expect("me object");
    assert_eq!(
        me.get("isAdmin").and_then(|v| v.as_bool()),
        Some(true),
        "me.isAdmin must be true for admin token"
    );
}

#[tokio::test]
async fn get_admin_dashboard_returns_data_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let request = Request::new(
        r#"query { getAdminDashboard { investigationCount publishedCount draftCount enigmaCount } }"#,
    )
    .data(BearerToken(Some(token)));

    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "getAdminDashboard must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let dash = data
        .get("getAdminDashboard")
        .and_then(|v| v.as_object())
        .expect("getAdminDashboard object");

    assert!(
        dash.get("investigationCount").is_some(),
        "investigationCount"
    );
    assert!(dash.get("publishedCount").is_some(), "publishedCount");
    assert!(dash.get("draftCount").is_some(), "draftCount");
    assert!(dash.get("enigmaCount").is_some(), "enigmaCount");
    assert!(
        dash.get("investigationCount")
            .and_then(|v| v.as_u64())
            .is_some(),
        "investigationCount must be a number"
    );
}

#[tokio::test]
async fn get_admin_dashboard_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let request = Request::new(
        r#"query { getAdminDashboard { investigationCount publishedCount draftCount enigmaCount } }"#,
    )
    .data(BearerToken(Some(token)));

    let res = schema.execute(request).await;
    assert!(!res.is_ok(), "getAdminDashboard must fail for non-admin");
    let errors = res.errors;
    assert!(!errors.is_empty(), "must return at least one error");
    let code = errors.first().and_then(|e| {
        e.extensions
            .as_ref()
            .and_then(|ext| ext.get("code"))
            .and_then(|v| match v {
                async_graphql::Value::String(s) => Some(s.as_str()),
                _ => None,
            })
    });
    assert_eq!(
        code,
        Some("FORBIDDEN"),
        "error code must be FORBIDDEN for non-admin, got: {:?}",
        errors
    );
}
