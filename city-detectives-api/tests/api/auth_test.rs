//! Tests d'intégration API auth (Story 1.2) – register, JWT, email dupliqué.
//! En local : `cargo test` n'exécute pas ces tests (ils sont `#[ignore]`).
//! Pour les lancer (serveur sur 8080) : `cargo test --test auth_test -- --ignored --nocapture`.
//! La CI (quality.yml) les exécute après démarrage du serveur.

use reqwest::Client;
use serde_json::json;

const BASE: &str = "http://localhost:8080";

fn register_mutation(email: &str, password: &str) -> String {
    format!(
        r#"mutation {{ register(email: "{}", password: "{}") }}"#,
        email.replace('"', "\\\""),
        password.replace('"', "\\\"")
    )
}

#[tokio::test]
#[ignore] // Lancer avec: cargo test --test auth_test -- --ignored --nocapture (serveur sur 8080)
async fn test_register_returns_jwt() {
    let client = Client::new();
    let res = client
        .post(format!("{}/graphql", BASE))
        .json(&json!({
            "query": register_mutation("test_register_jwt@example.com", "password123")
        }))
        .send()
        .await
        .unwrap();
    assert!(res.status().is_success(), "status: {}", res.status());
    let body: serde_json::Value = res.json().await.unwrap();
    let data = body.get("data").and_then(|d| d.get("register"));
    let token = data
        .and_then(|t| t.as_str())
        .expect("register doit retourner un JWT");
    assert!(!token.is_empty());
    assert!(token.split('.').count() == 3, "JWT doit avoir 3 parties");
}

#[tokio::test]
#[ignore]
async fn test_register_duplicate_email_rejected() {
    let client = Client::new();
    let email = "dup@example.com";
    let query = json!({ "query": register_mutation(email, "password123") });

    let res1 = client
        .post(format!("{}/graphql", BASE))
        .json(&query)
        .send()
        .await
        .unwrap();
    assert!(res1.status().is_success());
    let body1: serde_json::Value = res1.json().await.unwrap();
    assert!(body1.get("data").and_then(|d| d.get("register")).is_some());

    let res2 = client
        .post(format!("{}/graphql", BASE))
        .json(&query)
        .send()
        .await
        .unwrap();
    let body2: serde_json::Value = res2.json().await.unwrap();
    let errors = body2.get("errors");
    assert!(
        errors.is_some(),
        "second enregistrement doit renvoyer une erreur"
    );
}

#[tokio::test]
#[ignore]
async fn test_register_invalid_email_returns_error() {
    let client = Client::new();
    let res = client
        .post(format!("{}/graphql", BASE))
        .json(&json!({
            "query": register_mutation("invalid-email", "password12345")
        }))
        .send()
        .await
        .unwrap();
    // Backend renvoie 200 avec errors ou 400 (BAD_REQUEST) pour validation
    let body: serde_json::Value = res.json().await.unwrap();
    let errors = body.get("errors");
    assert!(
        errors.is_some(),
        "email invalide doit renvoyer une erreur de validation, body={}",
        body
    );
}

#[tokio::test]
#[ignore]
async fn test_register_short_password_returns_error() {
    let client = Client::new();
    let res = client
        .post(format!("{}/graphql", BASE))
        .json(&json!({
            "query": register_mutation("user@example.com", "short")
        }))
        .send()
        .await
        .unwrap();
    // Backend renvoie 200 avec errors ou 400 (BAD_REQUEST) pour validation
    let body: serde_json::Value = res.json().await.unwrap();
    let errors = body.get("errors");
    assert!(
        errors.is_some(),
        "mot de passe < 8 caractères doit renvoyer une erreur de validation, body={}",
        body
    );
}
