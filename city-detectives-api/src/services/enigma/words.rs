//! Validation énigmes mots (Story 4.2, FR25) – comparaison normalisée : minuscules, accents, espaces.

use crate::models::enigma::ValidateEnigmaResult;

/// Normalise une chaîne pour comparaison : minuscules, suppression des accents, trim des espaces.
pub fn normalize_text(s: &str) -> String {
    let trimmed = s.trim().to_lowercase();
    remove_accents(&trimmed)
}

/// Suppression des accents pour comparaison (MVP : français courant ; étendre si i18n).
fn remove_accents(s: &str) -> String {
    s.chars()
        .map(|c| match c {
            'à' | 'â' | 'ä' => 'a',
            'é' | 'è' | 'ê' | 'ë' => 'e',
            'î' | 'ï' => 'i',
            'ô' | 'ö' => 'o',
            'ù' | 'û' | 'ü' => 'u',
            'ç' => 'c',
            'œ' => 'o',
            _ => c,
        })
        .collect()
}

/// Valide la réponse mots : comparaison normalisée entre réponse attendue et saisie utilisateur.
pub fn validate(
    expected_answer: &str,
    user_answer: Option<String>,
) -> Result<ValidateEnigmaResult, String> {
    let user = user_answer
        .as_deref()
        .map(normalize_text)
        .unwrap_or_default();
    let expected = normalize_text(expected_answer);

    if user.is_empty() {
        return Ok(ValidateEnigmaResult {
            validated: false,
            message: "Veuillez saisir une réponse.".to_string(),
        });
    }

    if user == expected {
        Ok(ValidateEnigmaResult {
            validated: true,
            message: "Bravo, c'est la bonne réponse !".to_string(),
        })
    } else {
        Ok(ValidateEnigmaResult {
            validated: false,
            message: "Ce n'est pas la bonne réponse. Réessayez.".to_string(),
        })
    }
}
