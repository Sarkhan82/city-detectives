//! Tests d'intégration API investigations (Story 2.1, 6.1) – query listInvestigations (HTTP).
//!
//! Ces tests requièrent un serveur tournant sur localhost:8080. Lancer avec:
//! `cargo test --test investigations_test -- --ignored --nocapture`
//!
//! **CI :** La même couverture (listInvestigations avec isFree, priceAmount, priceCurrency) est
//! assurée par les tests in-process dans `src/api/graphql.rs` (list_investigations_in_process_returns_array),
//! exécutés en CI sans serveur HTTP.

use reqwest::Client;
use serde_json::json;

const BASE: &str = "http://localhost:8080";

const LIST_INVESTIGATIONS_QUERY: &str = r#"
  query {
    listInvestigations {
      id
      titre
      description
      durationEstimate
      difficulte
      isFree
      priceAmount
      priceCurrency
    }
  }
"#;

#[tokio::test]
#[ignore] // Lancer avec: cargo test --test investigations_test -- --ignored --nocapture (serveur sur 8080)
async fn test_list_investigations_returns_array() {
    let client = Client::new();
    let res = client
        .post(format!("{}/graphql", BASE))
        .json(&json!({ "query": LIST_INVESTIGATIONS_QUERY }))
        .send()
        .await
        .unwrap();
    assert!(res.status().is_success(), "status: {}", res.status());
    let body: serde_json::Value = res.json().await.unwrap();
    let errors = body.get("errors");
    assert!(
        errors.is_none(),
        "listInvestigations ne doit pas renvoyer d'erreur: {:?}",
        errors
    );
    let data = body
        .get("data")
        .and_then(|d| d.get("listInvestigations"))
        .expect("data.listInvestigations doit exister");
    assert!(data.is_array(), "listInvestigations doit être un tableau");
}

#[tokio::test]
#[ignore]
async fn test_list_investigations_items_have_required_fields() {
    let client = Client::new();
    let res = client
        .post(format!("{}/graphql", BASE))
        .json(&json!({ "query": LIST_INVESTIGATIONS_QUERY }))
        .send()
        .await
        .unwrap();
    assert!(res.status().is_success());
    let body: serde_json::Value = res.json().await.unwrap();
    let list = body
        .get("data")
        .and_then(|d| d.get("listInvestigations"))
        .and_then(|a| a.as_array())
        .expect("listInvestigations array");
    for item in list {
        assert!(item.get("id").is_some(), "chaque item doit avoir id");
        assert!(item.get("titre").is_some(), "chaque item doit avoir titre");
        assert!(
            item.get("description").is_some(),
            "chaque item doit avoir description"
        );
        assert!(
            item.get("durationEstimate").is_some(),
            "chaque item doit avoir durationEstimate"
        );
        assert!(
            item.get("difficulte").is_some(),
            "chaque item doit avoir difficulte"
        );
        assert!(
            item.get("isFree").is_some(),
            "chaque item doit avoir isFree"
        );
        assert!(
            item.get("priceAmount").is_some(),
            "chaque item doit avoir priceAmount (null si gratuit)"
        );
        assert!(
            item.get("priceCurrency").is_some(),
            "chaque item doit avoir priceCurrency (null si gratuit)"
        );
    }
}
