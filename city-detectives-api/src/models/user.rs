//! Modèle User (Story 1.2) – email, password_hash.

use serde::{Deserialize, Serialize};
use uuid::Uuid;
use validator::Validate;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub email: String,
    #[serde(skip_serializing)]
    #[allow(dead_code)] // utilisé pour vérification mot de passe (login futur)
    pub password_hash: String,
}

#[derive(Debug, Clone, Deserialize, Validate)]
pub struct RegisterInput {
    #[validate(email)]
    pub email: String,
    #[validate(length(min = 8))]
    pub password: String,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn register_input_rejects_invalid_email() {
        let input = RegisterInput {
            email: "not-an-email".to_string(),
            password: "password123".to_string(),
        };
        assert!(input.validate().is_err());
    }

    #[test]
    fn register_input_rejects_short_password() {
        let input = RegisterInput {
            email: "user@example.com".to_string(),
            password: "short".to_string(),
        };
        assert!(input.validate().is_err());
    }

    #[test]
    fn register_input_accepts_valid_input() {
        let input = RegisterInput {
            email: "user@example.com".to_string(),
            password: "password123".to_string(),
        };
        assert!(input.validate().is_ok());
    }
}
