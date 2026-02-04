//! Tests d'intégration API push (Story 8.1 – FR85, FR86, FR87).
//! registerPushToken : JWT → succès, persistance et mise à jour (upsert par user_id + platform).

use async_graphql::Request;
use city_detectives_api::api::graphql::create_schema;
use city_detectives_api::api::middleware::auth::BearerToken;
use city_detectives_api::services::admin_service::AdminService;
use city_detectives_api::services::analytics_service::AnalyticsService;
use city_detectives_api::services::auth_service::AuthService;
use city_detectives_api::services::enigma_service::EnigmaService;
use city_detectives_api::services::gamification_service::GamificationService;
use city_detectives_api::services::investigation_service::InvestigationService;
use city_detectives_api::services::lore_service::LoreService;
use city_detectives_api::services::payment_service::PaymentService;
use city_detectives_api::services::push_service::PushService;
use std::sync::Arc;

fn make_schema() -> city_detectives_api::api::graphql::AppSchema {
    let auth = Arc::new(AuthService::default());
    let enigma_svc = Arc::new(EnigmaService::new());
    let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
    let lore_svc = Arc::new(LoreService::new());
    let gamification_svc = Arc::new(GamificationService::new());
    let payment_svc = Arc::new(PaymentService::new());
    let admin_svc = Arc::new(AdminService::new(inv_svc.clone(), enigma_svc.clone()));
    let analytics_svc = Arc::new(AnalyticsService::new(inv_svc.clone()));
    let push_svc = Arc::new(PushService::new());
    create_schema(
        auth,
        inv_svc,
        enigma_svc,
        lore_svc,
        gamification_svc,
        payment_svc,
        admin_svc,
        analytics_svc,
        push_svc,
    )
}

async fn get_user_token(schema: &city_detectives_api::api::graphql::AppSchema) -> String {
    let request = Request::new(
        r#"mutation { register(email: "push-test@example.com", password: "password123") }"#,
    );
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "register must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    data.get("register")
        .and_then(|v| v.as_str())
        .expect("register returns JWT string")
        .to_string()
}

#[tokio::test]
async fn register_push_token_succeeds_when_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let request = Request::new(
        r#"mutation { registerPushToken(token: "fcm-token-123", platform: "android") }"#,
    )
    .data(BearerToken(Some(token)));

    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "registerPushToken must succeed with JWT: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let ok = data
        .get("registerPushToken")
        .and_then(|v| v.as_bool())
        .expect("registerPushToken returns bool");
    assert!(ok, "registerPushToken should return true");
}

#[tokio::test]
async fn register_push_token_requires_auth() {
    let schema = make_schema();
    let request =
        Request::new(r#"mutation { registerPushToken(token: "fcm-token-456", platform: "ios") }"#);
    let res = schema.execute(request).await;
    let data = res.data.into_json().unwrap();
    assert!(
        data.get("registerPushToken").is_none(),
        "registerPushToken without JWT should not return data"
    );
    assert!(
        !res.errors.is_empty(),
        "registerPushToken without JWT should return errors"
    );
}

#[tokio::test]
async fn register_push_token_upsert_updates_token() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let bearer = BearerToken(Some(token));

    let req1 =
        Request::new(r#"mutation { registerPushToken(token: "fcm-first", platform: "android") }"#)
            .data(bearer.clone());
    let res1 = schema.execute(req1).await;
    assert!(
        res1.is_ok(),
        "first register must succeed: {:?}",
        res1.errors
    );

    let req2 = Request::new(
        r#"mutation { registerPushToken(token: "fcm-updated", platform: "android") }"#,
    )
    .data(bearer);
    let res2 = schema.execute(req2).await;
    assert!(
        res2.is_ok(),
        "second register (upsert) must succeed: {:?}",
        res2.errors
    );
    let data = res2.data.into_json().unwrap();
    assert_eq!(
        data.get("registerPushToken").and_then(|v| v.as_bool()),
        Some(true),
        "upsert should return true"
    );
}

#[tokio::test]
async fn register_push_token_rejects_token_too_long() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let long_token = "x".repeat(513);
    let request = Request::new(format!(
        r#"mutation {{ registerPushToken(token: "{}", platform: "android") }}"#,
        long_token
    ))
    .data(BearerToken(Some(token)));

    let res = schema.execute(request).await;
    let data = res.data.into_json().unwrap();
    assert!(
        data.get("registerPushToken").and_then(|v| v.as_bool()) != Some(true),
        "token > 512 chars should be rejected"
    );
    assert!(
        !res.errors.is_empty(),
        "registerPushToken with too long token should return errors"
    );
}
