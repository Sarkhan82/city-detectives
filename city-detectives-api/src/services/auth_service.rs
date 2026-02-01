//! Service auth (Story 1.2) – register, bcrypt, JWT.
//! Stockage en mémoire pour MVP ; à remplacer par PostgreSQL/sqlx en prod.

use crate::models::user::{RegisterInput, User};
use bcrypt::{hash, DEFAULT_COST, verify};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::RwLock;
use uuid::Uuid;
use validator::Validate;

const JWT_EXP_SECS: i64 = 15 * 60; // 15 min

/// Secret JWT par défaut (dev) ; source unique pour éviter duplication avec main.
/// En prod, utiliser JWT_SECRET depuis l'environnement.
pub fn default_jwt_secret() -> Vec<u8> {
    b"city-detectives-mvp-secret-change-in-production".to_vec()
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // user id
    pub exp: i64,
    pub iat: i64,
}

pub struct AuthService {
    secret: Vec<u8>,
    users: RwLock<HashMap<String, User>>, // email -> User
}

impl Default for AuthService {
    fn default() -> Self {
        Self::new(default_jwt_secret())
    }
}

impl AuthService {
    /// Crée le service avec le secret JWT (lecture depuis JWT_SECRET en prod).
    pub fn new(secret: Vec<u8>) -> Self {
        Self {
            secret,
            users: RwLock::new(HashMap::new()),
        }
    }

    pub fn register(&self, input: RegisterInput) -> Result<String, String> {
        input.validate().map_err(|e| e.to_string())?;
        let email = input.email.to_lowercase();
        {
            let users = self.users.read().unwrap();
            if users.contains_key(&email) {
                return Err("Email déjà utilisé".to_string());
            }
        }
        let password_hash = hash(input.password, DEFAULT_COST).map_err(|e| e.to_string())?;
        let id = Uuid::new_v4();
        let user = User {
            id,
            email: email.clone(),
            password_hash,
        };
        {
            let mut users = self.users.write().unwrap();
            users.insert(email, user);
        }
        let token = self.create_token(id)?;
        Ok(token)
    }

    fn create_token(&self, user_id: Uuid) -> Result<String, String> {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;
        let claims = Claims {
            sub: user_id.to_string(),
            exp: now + JWT_EXP_SECS,
            iat: now,
        };
        encode(
            &Header::default(),
            &claims,
            &EncodingKey::from_secret(&self.secret),
        )
        .map_err(|e| e.to_string())
    }

    pub fn validate_token(&self, token: &str) -> Result<Uuid, String> {
        let token_data = decode::<Claims>(
            token,
            &DecodingKey::from_secret(&self.secret),
            &Validation::default(),
        )
        .map_err(|_| "Token invalide ou expiré".to_string())?;
        Uuid::parse_str(&token_data.claims.sub).map_err(|_| "Token invalide".to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn register_returns_jwt() {
        let service = AuthService::default();
        let input = RegisterInput {
            email: "jwt_test@example.com".to_string(),
            password: "password123".to_string(),
        };
        let token = service.register(input).unwrap();
        assert!(!token.is_empty());
        assert_eq!(token.split('.').count(), 3);
        let user_id = service.validate_token(&token).unwrap();
        assert!(!user_id.is_nil());
    }

    #[test]
    fn register_duplicate_email_rejected() {
        let service = AuthService::default();
        let input = RegisterInput {
            email: "dup@example.com".to_string(),
            password: "password123".to_string(),
        };
        let _ = service.register(input.clone()).unwrap();
        let res = service.register(input);
        assert!(res.is_err());
        assert!(res.unwrap_err().contains("déjà utilisé"));
    }
}
