//! Service push (Story 8.1 – FR85, FR86, FR87).
//! Enregistrement des tokens FCM/APNs ; envoi via FCM (Task 2.2).
//! Stockage en mémoire (MVP) ; en prod remplacer par table push_tokens en base.
//! Envoi : si FCM_SERVER_KEY est défini, envoi via FCM Legacy API ; sinon no-op.
//! Note : l’API Legacy FCM (https://fcm.googleapis.com/fcm/send) est dépréciée par Google ;
//! à terme migrer vers FCM HTTP v1.

use std::collections::HashMap;
use std::sync::RwLock;
use std::time::{SystemTime, UNIX_EPOCH};
use uuid::Uuid;

#[derive(Clone, Debug)]
pub struct PushTokenEntry {
    pub user_id: Uuid,
    pub token: String,
    pub platform: String,
    pub created_at: i64,
    pub updated_at: i64,
}

fn now_secs() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs() as i64
}

pub struct PushService {
    /// (user_id, platform) -> PushTokenEntry
    store: RwLock<HashMap<(Uuid, String), PushTokenEntry>>,
}

impl Default for PushService {
    fn default() -> Self {
        Self::new()
    }
}

impl PushService {
    pub fn new() -> Self {
        Self {
            store: RwLock::new(HashMap::new()),
        }
    }

    /// Enregistre ou met à jour le token pour (user_id, platform). Upsert par (user_id, platform).
    pub fn register_token(
        &self,
        user_id: Uuid,
        token: String,
        platform: String,
    ) -> Result<(), String> {
        let token = token.trim();
        if token.is_empty() {
            return Err("Token ne peut pas être vide".to_string());
        }
        const MAX_TOKEN_LEN: usize = 512;
        if token.len() > MAX_TOKEN_LEN {
            return Err(format!(
                "Token trop long (max {} caractères)",
                MAX_TOKEN_LEN
            ));
        }
        let platform = platform.to_lowercase();
        if platform.is_empty() {
            return Err("Platform ne peut pas être vide".to_string());
        }
        let key = (user_id, platform.clone());
        let now = now_secs();
        let mut store = self.store.write().map_err(|e| e.to_string())?;
        let entry = store.get(&key);
        let (created_at, updated_at) = match entry {
            Some(e) => (e.created_at, now),
            None => (now, now),
        };
        store.insert(
            key,
            PushTokenEntry {
                user_id,
                token: token.to_string(),
                platform,
                created_at,
                updated_at,
            },
        );
        Ok(())
    }

    /// Récupère le token pour un (user_id, platform) si présent.
    pub fn get_token(&self, user_id: Uuid, platform: &str) -> Option<String> {
        let store = self.store.read().ok()?;
        let key = (user_id, platform.to_lowercase());
        store.get(&key).map(|e| e.token.clone())
    }

    /// Liste tous les tokens (pour envoi FCM – Task 2.2).
    pub fn list_all_tokens(&self) -> Vec<PushTokenEntry> {
        let store = self.store.read().unwrap();
        store.values().cloned().collect()
    }

    /// Tokens pour un user_id donné (pour ciblage par ville/région plus tard).
    pub fn list_tokens_for_user(&self, user_id: Uuid) -> Vec<PushTokenEntry> {
        let store = self.store.read().unwrap();
        store
            .values()
            .filter(|e| e.user_id == user_id)
            .cloned()
            .collect()
    }

    /// Envoie une notification à une liste de tokens via FCM Legacy API (Task 2.2).
    /// No-op si FCM_SERVER_KEY n'est pas défini. Payload optionnel pour deep link (investigation_id, type).
    pub async fn send_notification(
        &self,
        tokens: &[String],
        title: &str,
        body: &str,
        data: Option<HashMap<String, String>>,
    ) -> Result<(), String> {
        let key = match std::env::var("FCM_SERVER_KEY") {
            Ok(k) if !k.trim().is_empty() => k,
            _ => return Ok(()),
        };
        if tokens.is_empty() {
            return Ok(());
        }
        let client = reqwest::Client::new();
        let data = data.unwrap_or_default();
        for token in tokens {
            let payload = serde_json::json!({
                "to": token,
                "notification": { "title": title, "body": body },
                "data": data
            });
            let res = client
                .post("https://fcm.googleapis.com/fcm/send")
                .header("Authorization", format!("key={}", key.trim()))
                .header("Content-Type", "application/json")
                .json(&payload)
                .send()
                .await
                .map_err(|e| e.to_string())?;
            if !res.status().is_success() {
                tracing::warn!("FCM send failed with status: {}", res.status());
            }
        }
        Ok(())
    }
}
