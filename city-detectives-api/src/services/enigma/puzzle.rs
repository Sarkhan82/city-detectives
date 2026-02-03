//! Validation énigmes puzzle (Story 4.2, FR26) – code ou logique.

use crate::models::enigma::ValidateEnigmaResult;

/// Valide la réponse puzzle : comparaison du code/saisie avec la valeur attendue (trim, sensible à la casse par défaut).
pub fn validate(
    expected_code: &str,
    user_code: Option<String>,
) -> Result<ValidateEnigmaResult, String> {
    let user = user_code
        .as_deref()
        .map(|s| s.trim().to_string())
        .unwrap_or_default();

    if user.is_empty() {
        return Ok(ValidateEnigmaResult {
            validated: false,
            message: "Veuillez saisir le code ou votre réponse.".to_string(),
        });
    }

    if user == expected_code.trim() {
        Ok(ValidateEnigmaResult {
            validated: true,
            message: "Code correct ! Enigme résolue.".to_string(),
        })
    } else {
        Ok(ValidateEnigmaResult {
            validated: false,
            message: "Code incorrect. Réessayez.".to_string(),
        })
    }
}
