//! Tests d'intégration API admin (Story 7.1 – FR61, 7.2 – FR62, 7.3 – FR65, FR66, FR67).
//! getAdminDashboard, createInvestigation, updateInvestigation : JWT admin → succès ; JWT user → 403.
//! investigationForPreview, publishInvestigation, rollbackInvestigation ; listInvestigations filtre published pour non-admin.

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

// --- Story 7.3 – FR65, FR66, FR67 ---

#[tokio::test]
async fn investigation_for_preview_returns_draft_when_admin_jwt() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let create = r#"mutation {
        createInvestigation(input: {
            titre: "Brouillon preview"
            description: "Desc"
            durationEstimate: 30
            difficulte: "facile"
            isFree: true
            status: "draft"
        }) { id titre status }
    }"#;
    let req = Request::new(create).data(BearerToken(Some(token.clone())));
    let res = schema.execute(req).await;
    assert!(res.is_ok(), "create must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let inv = data
        .get("createInvestigation")
        .and_then(|v| v.as_object())
        .expect("createInvestigation");
    let id = inv.get("id").and_then(|v| v.as_str()).expect("id");
    let preview = format!(
        r#"query {{ investigationForPreview(id: "{}") {{ investigation {{ id titre status }} enigmas {{ id }} }} }}"#,
        id
    );
    let req = Request::new(preview).data(BearerToken(Some(token)));
    let res = schema.execute(req).await;
    assert!(
        res.is_ok(),
        "investigationForPreview must succeed for admin: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let root = data
        .get("investigationForPreview")
        .and_then(|v| v.as_object())
        .expect("investigationForPreview");
    let inv_out = root
        .get("investigation")
        .and_then(|v| v.as_object())
        .expect("investigation");
    assert_eq!(
        inv_out.get("status").and_then(|v| v.as_str()),
        Some("draft")
    );
}

#[tokio::test]
async fn investigation_for_preview_returns_forbidden_when_user_jwt() {
    let schema = make_schema();
    let token = get_user_token(&schema).await;
    let request = Request::new(
        r#"query { investigationForPreview(id: "11111111-1111-1111-1111-111111111111") { investigation { id } } }"#,
    )
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(
        !res.is_ok(),
        "investigationForPreview must fail for non-admin"
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
async fn list_investigations_without_token_returns_only_published() {
    let schema = make_schema();
    let request = Request::new(r#"query { listInvestigations { id status } }"#);
    let res = schema.execute(request).await;
    assert!(
        res.is_ok(),
        "listInvestigations without token: {:?}",
        res.errors
    );
    let data = res.data.into_json().unwrap();
    let list = data
        .get("listInvestigations")
        .and_then(|v| v.as_array())
        .expect("list");
    for item in list {
        let obj = item.as_object().expect("item object");
        assert_eq!(
            obj.get("status").and_then(|v| v.as_str()),
            Some("published"),
            "non-admin must see only published"
        );
    }
}

#[tokio::test]
async fn publish_investigation_succeeds_then_visible_in_catalog() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let create = r#"mutation {
        createInvestigation(input: {
            titre: "To publish"
            description: "D"
            durationEstimate: 10
            difficulte: "facile"
            isFree: true
            status: "draft"
        }) { id status }
    }"#;
    let res = schema
        .execute(Request::new(create).data(BearerToken(Some(token.clone()))))
        .await;
    assert!(res.is_ok(), "create: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let id = data
        .get("createInvestigation")
        .and_then(|v| v.as_object())
        .and_then(|o| o.get("id"))
        .and_then(|v| v.as_str())
        .expect("id")
        .to_string();
    let list_before = Request::new(r#"query { listInvestigations { id } }"#);
    let _count_before = schema
        .execute(list_before)
        .await
        .data
        .into_json()
        .unwrap()
        .get("listInvestigations")
        .and_then(|v| v.as_array())
        .map(|a| a.len())
        .unwrap_or(0);
    let publish = format!(
        r#"mutation {{ publishInvestigation(id: "{}") {{ id status }} }}"#,
        id
    );
    let res = schema
        .execute(Request::new(publish).data(BearerToken(Some(token))))
        .await;
    assert!(res.is_ok(), "publishInvestigation: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    assert_eq!(
        data.get("publishInvestigation")
            .and_then(|v| v.as_object())
            .and_then(|o| o.get("status"))
            .and_then(|v| v.as_str()),
        Some("published")
    );
    let list_after = Request::new(r#"query { listInvestigations { id } }"#);
    let binding = schema.execute(list_after).await.data.into_json().unwrap();
    let list = binding
        .get("listInvestigations")
        .and_then(|v| v.as_array())
        .expect("list");
    assert!(
        list.iter()
            .any(|v| v.get("id").and_then(|x| x.as_str()) == Some(id.as_str())),
        "after publish, listInvestigations (no auth) must include the investigation"
    );
}

#[tokio::test]
async fn rollback_investigation_succeeds_then_hidden_from_catalog() {
    let schema = make_schema();
    let token = get_admin_token(&schema).await;
    let create = r#"mutation {
        createInvestigation(input: {
            titre: "To rollback"
            description: "D"
            durationEstimate: 10
            difficulte: "facile"
            isFree: true
            status: "published"
        }) { id status }
    }"#;
    let res = schema
        .execute(Request::new(create).data(BearerToken(Some(token.clone()))))
        .await;
    assert!(res.is_ok(), "create: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let id = data
        .get("createInvestigation")
        .and_then(|v| v.as_object())
        .and_then(|o| o.get("id"))
        .and_then(|v| v.as_str())
        .expect("id")
        .to_string();
    let rollback = format!(
        r#"mutation {{ rollbackInvestigation(id: "{}") {{ id status }} }}"#,
        id
    );
    let res = schema
        .execute(Request::new(rollback).data(BearerToken(Some(token))))
        .await;
    assert!(res.is_ok(), "rollbackInvestigation: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    assert_eq!(
        data.get("rollbackInvestigation")
            .and_then(|v| v.as_object())
            .and_then(|o| o.get("status"))
            .and_then(|v| v.as_str()),
        Some("draft")
    );
    let list_after = Request::new(r#"query { listInvestigations { id } }"#);
    let binding = schema.execute(list_after).await.data.into_json().unwrap();
    let list = binding
        .get("listInvestigations")
        .and_then(|v| v.as_array())
        .expect("list");
    assert!(
        !list
            .iter()
            .any(|v| v.get("id").and_then(|x| x.as_str()) == Some(id.as_str())),
        "after rollback, listInvestigations (no auth) must not include the investigation"
    );
}
