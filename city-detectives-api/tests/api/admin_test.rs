//! Tests d'intégration API admin (Story 7.1 – FR61, 7.2 – FR62).
//! getAdminDashboard, createInvestigation, updateInvestigation : JWT admin → succès ; JWT user → 403.

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

#[tokio::test]
async fn create_investigation_succeeds_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let mutation = r#"mutation {
        createInvestigation(input: {
            titre: "Nouvelle enquête"
            description: "Description test"
            durationEstimate: 60
            difficulte: "moyen"
            isFree: true
            status: "draft"
        }) { id titre status }
    }"#;
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "createInvestigation must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let inv = data
        .get("createInvestigation")
        .and_then(|v| v.as_object())
        .expect("createInvestigation object");
    assert!(inv.get("id").and_then(|v| v.as_str()).unwrap().len() > 0);
    assert_eq!(
        inv.get("titre").and_then(|v| v.as_str()),
        Some("Nouvelle enquête")
    );
    assert_eq!(inv.get("status").and_then(|v| v.as_str()), Some("draft"));
}

#[tokio::test]
async fn create_investigation_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let mutation = r#"mutation {
        createInvestigation(input: {
            titre: "Nouvelle enquête"
            description: "Description"
            durationEstimate: 60
            difficulte: "moyen"
            isFree: true
        }) { id }
    }"#;
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(!res.is_ok(), "createInvestigation must fail for non-admin");
    let code = res.errors.first().and_then(|e| {
        e.extensions
            .as_ref()
            .and_then(|ext| ext.get("code"))
            .and_then(|v| match v {
                async_graphql::Value::String(s) => Some(s.as_str()),
                _ => None,
            })
    });
    assert_eq!(code, Some("FORBIDDEN"));
}

#[tokio::test]
async fn update_investigation_succeeds_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let id = "11111111-1111-1111-1111-111111111111";
    let mutation = format!(
        r#"mutation {{
            updateInvestigation(id: "{}", input: {{ titre: "Titre mis à jour", status: "draft" }}) {{ id titre status }}
        }}"#,
        id
    );
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "updateInvestigation must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let inv = data
        .get("updateInvestigation")
        .and_then(|v| v.as_object())
        .expect("updateInvestigation object");
    assert_eq!(inv.get("id").and_then(|v| v.as_str()), Some(id));
    assert_eq!(
        inv.get("titre").and_then(|v| v.as_str()),
        Some("Titre mis à jour")
    );
    assert_eq!(inv.get("status").and_then(|v| v.as_str()), Some("draft"));
}

#[tokio::test]
async fn update_investigation_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let mutation = r#"mutation {
        updateInvestigation(id: "11111111-1111-1111-1111-111111111111", input: { titre: "Hack" }) { id }
    }"#;
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(!res.is_ok(), "updateInvestigation must fail for non-admin");
    let code = res.errors.first().and_then(|e| {
        e.extensions
            .as_ref()
            .and_then(|ext| ext.get("code"))
            .and_then(|v| match v {
                async_graphql::Value::String(s) => Some(s.as_str()),
                _ => None,
            })
    });
    assert_eq!(code, Some("FORBIDDEN"));
}

#[tokio::test]
async fn create_enigma_succeeds_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let mutation = r#"mutation {
        createEnigma(input: {
            investigationId: "11111111-1111-1111-1111-111111111111"
            orderIndex: 4
            type: "words"
            titre: "Nouvelle énigme"
        }) { id investigationId orderIndex type titre }
    }"#;
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "createEnigma must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let enigma = data
        .get("createEnigma")
        .and_then(|v| v.as_object())
        .expect("createEnigma object");
    assert!(enigma.get("id").and_then(|v| v.as_str()).unwrap().len() > 0);
    assert_eq!(enigma.get("orderIndex").and_then(|v| v.as_u64()), Some(4));
    assert_eq!(enigma.get("type").and_then(|v| v.as_str()), Some("words"));
    assert_eq!(
        enigma.get("titre").and_then(|v| v.as_str()),
        Some("Nouvelle énigme")
    );
}

#[tokio::test]
async fn create_enigma_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let mutation = r#"mutation {
        createEnigma(input: {
            investigationId: "11111111-1111-1111-1111-111111111111"
            orderIndex: 4
            type: "words"
            titre: "Nouvelle énigme"
        }) { id }
    }"#;
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(!res.is_ok(), "createEnigma must fail for non-admin");
    let code = res.errors.first().and_then(|e| {
        e.extensions
            .as_ref()
            .and_then(|ext| ext.get("code"))
            .and_then(|v| match v {
                async_graphql::Value::String(s) => Some(s.as_str()),
                _ => None,
            })
    });
    assert_eq!(code, Some("FORBIDDEN"));
}

#[tokio::test]
async fn validate_enigma_historical_content_succeeds_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let request = Request::new(
        r#"query { investigation(id: "11111111-1111-1111-1111-111111111111") { enigmas { id } } }"#,
    );
    let res = schema.execute(request).await;
    let data = res.data.into_json().unwrap();
    let first_id = data
        .get("investigation")
        .and_then(|v| v.as_object())
        .and_then(|o| o.get("enigmas"))
        .and_then(|v| v.as_array())
        .and_then(|a| a.first())
        .and_then(|e| e.get("id"))
        .and_then(|v| v.as_str())
        .expect("first enigma id");
    let mutation = format!(
        r#"mutation {{ validateEnigmaHistoricalContent(enigmaId: "{}") {{ id historicalContentValidated }} }}"#,
        first_id
    );
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "validateEnigmaHistoricalContent must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let enigma = data
        .get("validateEnigmaHistoricalContent")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaHistoricalContent object");
    assert_eq!(
        enigma
            .get("historicalContentValidated")
            .and_then(|v| v.as_bool()),
        Some(true)
    );
}

#[tokio::test]
async fn validate_enigma_historical_content_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let request = Request::new(
        r#"query { investigation(id: "11111111-1111-1111-1111-111111111111") { enigmas { id } } }"#,
    );
    let res = schema.execute(request).await;
    let data = res.data.into_json().unwrap();
    let first_id = data
        .get("investigation")
        .and_then(|v| v.as_object())
        .and_then(|o| o.get("enigmas"))
        .and_then(|v| v.as_array())
        .and_then(|a| a.first())
        .and_then(|e| e.get("id"))
        .and_then(|v| v.as_str())
        .expect("first enigma id");
    let mutation = format!(
        r#"mutation {{ validateEnigmaHistoricalContent(enigmaId: "{}") {{ id }} }}"#,
        first_id
    );
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        !res.is_ok(),
        "validateEnigmaHistoricalContent must fail for non-admin"
    );
    let code = res.errors.first().and_then(|e| {
        e.extensions
            .as_ref()
            .and_then(|ext| ext.get("code"))
            .and_then(|v| match v {
                async_graphql::Value::String(s) => Some(s.as_str()),
                _ => None,
            })
    });
    assert_eq!(code, Some("FORBIDDEN"));
}

#[tokio::test]
async fn update_enigma_succeeds_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let request = Request::new(
        r#"query { investigation(id: "11111111-1111-1111-1111-111111111111") { enigmas { id } } }"#,
    );
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "investigation query: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let root = data
        .get("investigation")
        .and_then(|v| v.as_object())
        .expect("investigation");
    let enigmas = root
        .get("enigmas")
        .and_then(|v| v.as_array())
        .expect("enigmas");
    let first_id = enigmas[0]
        .get("id")
        .and_then(|v| v.as_str())
        .expect("first enigma id");
    let mutation = format!(
        r#"mutation {{ updateEnigma(id: "{}", input: {{ titre: "Titre énigme mis à jour" }}) {{ id titre }} }}"#,
        first_id
    );
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "updateEnigma must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let enigma = data
        .get("updateEnigma")
        .and_then(|v| v.as_object())
        .expect("updateEnigma object");
    assert_eq!(
        enigma.get("titre").and_then(|v| v.as_str()),
        Some("Titre énigme mis à jour")
    );
}

#[tokio::test]
async fn update_enigma_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let request = Request::new(
        r#"query { investigation(id: "11111111-1111-1111-1111-111111111111") { enigmas { id } } }"#,
    );
    let res = schema.execute(request).await;
    let data = res.data.into_json().unwrap();
    let first_id = data
        .get("investigation")
        .and_then(|v| v.as_object())
        .and_then(|o| o.get("enigmas"))
        .and_then(|v| v.as_array())
        .and_then(|a| a.first())
        .and_then(|e| e.get("id"))
        .and_then(|v| v.as_str())
        .expect("first enigma id");
    let mutation = format!(
        r#"mutation {{ updateEnigma(id: "{}", input: {{ titre: "Hack" }}) {{ id }} }}"#,
        first_id
    );
    let request = Request::new(mutation).data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(!res.is_ok(), "updateEnigma must fail for non-admin");
    let code = res.errors.first().and_then(|e| {
        e.extensions
            .as_ref()
            .and_then(|ext| ext.get("code"))
            .and_then(|v| match v {
                async_graphql::Value::String(s) => Some(s.as_str()),
                _ => None,
            })
    });
    assert_eq!(code, Some("FORBIDDEN"));
}
