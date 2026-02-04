//! Tests d'intégration API gamification (Story 5.2 – FR42–FR45).
//! Queries getUserBadges, getUserSkills, getUserPostcards, getLeaderboard (authentification requise).

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

async fn get_test_token(schema: &city_detectives_api::api::graphql::AppSchema) -> String {
    let request = Request::new(
        r#"mutation { register(email: "gamification-test@example.com", password: "password123") }"#,
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
async fn get_user_badges_returns_list_when_authenticated() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let request = Request::new(
        r#"query { getUserBadges { badgeId code label description iconRef unlockedAt } }"#,
    )
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "getUserBadges must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let list = data
        .get("getUserBadges")
        .and_then(|v| v.as_array())
        .expect("getUserBadges array");
    assert!(!list.is_empty(), "mock returns at least one badge");
    let first = list[0].as_object().unwrap();
    assert!(first.get("code").is_some());
    assert!(first.get("label").is_some());
    assert!(first.get("unlockedAt").is_some());
}

#[tokio::test]
async fn get_user_skills_returns_list_when_authenticated() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let request = Request::new(r#"query { getUserSkills { code label level progressPercent } }"#)
        .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "getUserSkills must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let list = data
        .get("getUserSkills")
        .and_then(|v| v.as_array())
        .expect("getUserSkills array");
    assert!(!list.is_empty());
    let first = list[0].as_object().unwrap();
    assert!(first.get("code").is_some());
    assert!(first.get("level").is_some());
}

#[tokio::test]
async fn get_user_postcards_returns_list_when_authenticated() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let request =
        Request::new(r#"query { getUserPostcards { id placeName imageUrl unlockedAt } }"#)
            .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "getUserPostcards must succeed: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let list = data
        .get("getUserPostcards")
        .and_then(|v| v.as_array())
        .expect("getUserPostcards array");
    assert!(!list.is_empty());
    let first = list[0].as_object().unwrap();
    assert!(first.get("placeName").is_some());
}

#[tokio::test]
async fn get_leaderboard_returns_list_when_authenticated() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let request = Request::new(r#"query { getLeaderboard { rank userId score displayName } }"#)
        .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "getLeaderboard must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let list = data
        .get("getLeaderboard")
        .and_then(|v| v.as_array())
        .expect("getLeaderboard array");
    assert!(!list.is_empty());
    let first = list[0].as_object().unwrap();
    assert!(first.get("rank").is_some());
    assert!(first.get("score").is_some());
}
