//! Service auth (Story 1.2, 7.1) – register, bcrypt, JWT, rôle admin.

use crate::models::user::{RegisterInput, Role, User};
use bcrypt::{hash, DEFAULT_COST};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::RwLock;
use uuid::Uuid;
use validator::Validate;

const JWT_EXP_SECS: i64 = 15 * 60; // 15 min

/// Email seed admin (Story 7.1 – FR61). Compte avec cet email obtient le rôle admin.
/// En prod : préférer une variable d'environnement (ex. ADMIN_SEED_EMAIL) ou liste configurable.
const ADMIN_SEED_EMAIL: &str = "admin@city-detectives.local";

/// Secret JWT par défaut (dev) ; source unique pour éviter duplication avec main.
/// En prod, utiliser JWT_SECRET depuis l'environnement.
pub fn default_jwt_secret() -> Vec<u8> {
    b"city-detectives-mvp-secret-change-in-production".to_vec()
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // user id
    /// Rôle dans le JWT pour middleware admin (Story 7.1 – FR61). "user" | "admin".
    #[serde(default)]
    pub role: String,
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
        let role = if email == ADMIN_SEED_EMAIL {
            Role::Admin
        } else {
            Role::User
        };
        let user = User {
            id,
            email: email.clone(),
            password_hash,
            role,
        };
        {
            let mut users = self.users.write().unwrap();
            users.insert(email, user);
        }
        let token = self.create_token(id, role)?;
        Ok(token)
    }

    /// Crée un JWT avec sub (user id) et role (Story 7.1 – FR61).
    fn create_token(&self, user_id: Uuid, role: Role) -> Result<String, String> {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs() as i64;
        let role_str = match role {
            Role::User => "user",
            Role::Admin => "admin",
        };
        let claims = Claims {
            sub: user_id.to_string(),
            role: role_str.to_string(),
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

    /// Valide le token et retourne (user_id, role) pour autorisation (Story 7.1).
    pub fn validate_token(&self, token: &str) -> Result<Uuid, String> {
        let (user_id, _) = self.validate_token_claims(token)?;
        Ok(user_id)
    }

    /// Valide le token et retourne (user_id, role). Utilisé par le guard admin (Story 7.1 – FR61).
    pub fn validate_token_claims(&self, token: &str) -> Result<(Uuid, Role), String> {
        let token_data = decode::<Claims>(
            token,
            &DecodingKey::from_secret(&self.secret),
            &Validation::default(),
        )
        .map_err(|_| "Token invalide ou expiré".to_string())?;
        let user_id =
            Uuid::parse_str(&token_data.claims.sub).map_err(|_| "Token invalide".to_string())?;
        let role = if token_data.claims.role.eq_ignore_ascii_case("admin") {
            Role::Admin
        } else {
            Role::User
        };
        Ok((user_id, role))
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

    #[test]
    fn register_with_admin_seed_email_returns_token_with_admin_role() {
        let service = AuthService::default();
        let input = RegisterInput {
            email: ADMIN_SEED_EMAIL.to_string(),
            password: "password123".to_string(),
        };
        let token = service.register(input).unwrap();
        let (_, role) = service.validate_token_claims(&token).unwrap();
        assert_eq!(
            role,
            Role::Admin,
            "admin seed email must get Admin role in JWT"
        );
    }
}
