//! Tests d'intégration API énigmes (Story 4.1) – mutation validateEnigmaResponse (géolocalisation et photo).
//! Exécutables en processus (sans serveur HTTP) via le schéma GraphQL.
//! La mutation requiert authentification : on enregistre un utilisateur et on passe le token.

use async_graphql::Request;
use city_detectives_api::api::graphql::create_schema;
use city_detectives_api::api::middleware::auth::BearerToken;
use city_detectives_api::services::auth_service::AuthService;
use city_detectives_api::services::enigma_service::EnigmaService;
use city_detectives_api::services::investigation_service::InvestigationService;
use std::sync::Arc;

fn make_schema() -> city_detectives_api::api::graphql::AppSchema {
    let auth = Arc::new(AuthService::default());
    let enigma_svc = Arc::new(EnigmaService::new());
    let inv_svc = Arc::new(InvestigationService::new(enigma_svc.clone()));
    create_schema(auth, inv_svc, enigma_svc)
}

/// Enregistre un utilisateur de test et retourne le JWT pour les requêtes protégées.
async fn get_test_token(schema: &city_detectives_api::api::graphql::AppSchema) -> String {
    let request = Request::new(
        r#"mutation { register(email: "enigma-test@example.com", password: "password123") }"#,
    );
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "register must succeed: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    data.get("register")
        .and_then(|v| v.as_str())
        .expect("register returns JWT string")
        .to_string()
}

/// ID énigme géo enquête 1, ordre 2 (point 48.8566, 2.3522, tolérance 10 m).
fn geo_enigma_id() -> String {
    let id = EnigmaService::enigma_id_for(uuid::uuid!("11111111-1111-1111-1111-111111111111"), 2);
    id.to_string()
}

/// ID énigme photo enquête 1, ordre 3.
fn photo_enigma_id() -> String {
    let id = EnigmaService::enigma_id_for(uuid::uuid!("11111111-1111-1111-1111-111111111111"), 3);
    id.to_string()
}

/// ID énigme mots enquête 1, ordre 1 (réponse attendue "paris" normalisée) – Story 4.2.
fn words_enigma_id() -> String {
    let id = EnigmaService::enigma_id_for(uuid::uuid!("11111111-1111-1111-1111-111111111111"), 1);
    id.to_string()
}

/// ID énigme puzzle enquête 2, ordre 3 (code attendu "1234") – Story 4.2.
fn puzzle_enigma_id() -> String {
    let id = EnigmaService::enigma_id_for(uuid::uuid!("22222222-2222-2222-2222-222222222222"), 3);
    id.to_string()
}

#[tokio::test]
async fn validate_geolocation_valid_when_within_tolerance() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = geo_enigma_id();
    // Point cible 48.8566, 2.3522 ; user au même point → distance 0 m < 10 m
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ userLat: 48.8566, userLng: 2.3522 }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(true),
        "doit être validé quand au bon endroit"
    );
    assert!(
        result
            .get("message")
            .and_then(|v| v.as_str())
            .unwrap()
            .contains("Bravo"),
        "message positif attendu"
    );
}

#[tokio::test]
async fn validate_geolocation_invalid_when_too_far() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = geo_enigma_id();
    // Point cible 48.8566, 2.3522 ; user loin (ex. 50.0, 3.0) → > 10 m
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ userLat: 50.0, userLng: 3.0 }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(false),
        "ne doit pas être validé quand trop loin"
    );
    assert!(
        result
            .get("message")
            .and_then(|v| v.as_str())
            .unwrap()
            .contains("pas encore au bon endroit")
            || result
                .get("message")
                .and_then(|v| v.as_str())
                .unwrap()
                .contains("Distance"),
        "message explicite attendu (FR29)"
    );
}

#[tokio::test]
async fn validate_photo_valid_when_photo_provided() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = photo_enigma_id();
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ photoUrl: "https://example.com/photo.jpg" }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(true),
        "photo fournie doit être validée en MVP"
    );
}

#[tokio::test]
async fn validate_photo_invalid_when_no_photo() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = photo_enigma_id();
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(false),
        "sans photo ne doit pas être validé"
    );
    assert!(
        result
            .get("message")
            .and_then(|v| v.as_str())
            .unwrap()
            .contains("photo")
            || result
                .get("message")
                .and_then(|v| v.as_str())
                .unwrap()
                .contains("Aucune"),
        "message explicite attendu (FR29)"
    );
}

// --- Story 4.2 : validation énigmes mots et puzzle (FR25, FR26, FR28, FR29) ---

#[tokio::test]
async fn validate_words_valid_when_correct_answer() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = words_enigma_id();
    // Réponse attendue mock "paris" ; normalisation minuscules/accents/espaces
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ textAnswer: "Paris" }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(true),
        "réponse correcte (normalisée) doit être validée"
    );
}

#[tokio::test]
async fn validate_words_invalid_when_wrong_answer() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = words_enigma_id();
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ textAnswer: "Lyon" }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(false),
        "réponse incorrecte ne doit pas être validée"
    );
    assert!(
        !result
            .get("message")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty(),
        "message explicite attendu (FR29)"
    );
}

#[tokio::test]
async fn validate_puzzle_valid_when_correct_code() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = puzzle_enigma_id();
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ codeAnswer: "1234" }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(true),
        "code correct doit être validé"
    );
}

#[tokio::test]
async fn validate_puzzle_invalid_when_wrong_code() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = puzzle_enigma_id();
    let request = Request::new(format!(
        r#"
        mutation {{
            validateEnigmaResponse(
                enigmaId: "{}",
                payload: {{ codeAnswer: "0000" }}
            ) {{
                validated
                message
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let result = data
        .get("validateEnigmaResponse")
        .and_then(|v| v.as_object())
        .expect("validateEnigmaResponse object");
    assert_eq!(
        result.get("validated").and_then(|v| v.as_bool()),
        Some(false),
        "code incorrect ne doit pas être validé"
    );
}

// --- Story 4.3 : getEnigmaHints et getEnigmaExplanation (FR30, FR31) ---

#[tokio::test]
async fn get_enigma_hints_returns_suggestion_hint_solution() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = words_enigma_id();
    let request = Request::new(format!(
        r#"
        query {{
            getEnigmaHints(enigmaId: "{}") {{
                suggestion
                hint
                solution
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let hints = data
        .get("getEnigmaHints")
        .and_then(|v| v.as_object())
        .expect("getEnigmaHints object");
    assert!(
        !hints
            .get("suggestion")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty(),
        "suggestion non vide"
    );
    assert!(
        !hints
            .get("hint")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty(),
        "hint non vide"
    );
    assert!(
        !hints
            .get("solution")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty(),
        "solution non vide"
    );
}

#[tokio::test]
async fn get_enigma_explanation_returns_historical_and_educational() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    let enigma_id = geo_enigma_id();
    let request = Request::new(format!(
        r#"
        query {{
            getEnigmaExplanation(enigmaId: "{}") {{
                historicalExplanation
                educationalContent
            }}
        }}
        "#,
        enigma_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    assert!(res.is_ok(), "errors: {:?}", res.errors);
    let data = res.data.into_json().unwrap();
    let explanation = data
        .get("getEnigmaExplanation")
        .and_then(|v| v.as_object())
        .expect("getEnigmaExplanation object");
    assert!(
        !explanation
            .get("historicalExplanation")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty(),
        "historicalExplanation non vide"
    );
    assert!(
        !explanation
            .get("educationalContent")
            .and_then(|v| v.as_str())
            .unwrap()
            .is_empty(),
        "educationalContent non vide"
    );
}

#[tokio::test]
async fn get_enigma_hints_returns_error_for_unknown_enigma() {
    let schema = make_schema();
    let token = get_test_token(&schema).await;
    // UUID valide mais non présent dans le mock (pas d'énigme avec cet id)
    let unknown_id = "00000000-0000-0000-0000-000000000001";
    let request = Request::new(format!(
        r#"
        query {{
            getEnigmaHints(enigmaId: "{}") {{
                suggestion
                hint
                solution
            }}
        }}
        "#,
        unknown_id
    ))
    .data(BearerToken(Some(token)));
    let res = schema.execute(request).await;
    let errors = res.errors;
    assert!(
        !errors.is_empty(),
        "getEnigmaHints(unknown id) doit retourner une erreur GraphQL"
    );
    let msg = errors.first().map(|e| e.message.as_str()).unwrap_or("");
    assert!(
        msg.contains("introuvable") || msg.contains("Énigme"),
        "message attendu (énigme introuvable): {}",
        msg
    );
}
