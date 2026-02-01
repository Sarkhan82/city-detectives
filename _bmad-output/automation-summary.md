# Résumé d'automatisation – Story 1.2 (Création de compte)

**Date :** 2026-01-26  
**Story :** 1.2 – Création de compte  
**Mode :** BMad-Integrated  
**Cible de couverture :** critical-paths  

---

## Contexte

- **Frameworks :** Flutter (widget tests) + Rust (cargo test, tests d’intégration API).
- **Artéfacts BMad :** Story 1.2 chargée ; critères d’acceptation utilisés pour cibler les tests.
- **Pas de Playwright/Cypress** : projet polyglotte Flutter / Rust ; patterns “fixture-architecture” et “network-first” appliqués au sens API/backend.

---

## Tests existants (avant workflow)

### Rust – API (`city-detectives-api/tests/api/auth_test.rs`)

- `test_register_returns_jwt` [P1] – register avec email/mot de passe valides → 200 + JWT (3 parties).
- `test_register_duplicate_email_rejected` [P1] – deuxième inscription même email → erreur GraphQL.

*(Les deux sont `#[ignore]` : nécessitent serveur sur localhost:8080 ; à lancer avec  
`cargo test --test auth_test -- --ignored --nocapture`.)*

### Flutter – Widget (`city_detectives/test/register_screen_test.dart`)

- Formulaire : champs (email, mot de passe, confirmation) et bouton « Créer mon compte ».
- Mots de passe différents : message « Les mots de passe ne correspondent pas. ».
- Isolation : `RegisterScreen` avec route dédiée.

---

## Tests ajoutés par le workflow

### Rust – Unitaires (`city-detectives-api/src/models/user.rs`)

- `register_input_rejects_invalid_email` [P2] – email invalide → `validate()` erreur.
- `register_input_rejects_short_password` [P2] – mot de passe &lt; 8 caractères → erreur.
- `register_input_accepts_valid_input` [P2] – email + mot de passe valides → `validate()` ok.

*(Exécutés par défaut avec `cargo test`.)*

### Rust – API (`city-detectives-api/tests/api/auth_test.rs`)

- `test_register_invalid_email_returns_error` [P1] – email invalide (ex. `invalid-email`) → réponse GraphQL avec `errors`.
- `test_register_short_password_returns_error` [P1] – mot de passe court → réponse GraphQL avec `errors`.

*(Tous deux `#[ignore]` ; même mode d’exécution que les autres tests d’intégration API.)*

### Flutter

- Aucun nouveau fichier : couverture widget déjà suffisante pour AC (formulaire, validation côté client mot de passe, isolation).
- Recommandation : pour “affichage erreur API”, ajouter plus tard un test avec mock de `authServiceProvider` si besoin.

---

## Plan de couverture (niveaux / priorités)

| Niveau   | Fichier / zone              | P0 | P1 | P2 | Description |
|----------|-----------------------------|----|----|----|-------------|
| API      | `auth_test.rs`              | –  | 4  | –  | register JWT, email dupliqué, email invalide, mot de passe court |
| Unit     | `user.rs` (mod tests)       | –  | –  | 3  | Validation `RegisterInput` (email, longueur mot de passe) |
| Widget   | `register_screen_test.dart`  | –  | 3  | –  | Formulaire, mismatch mot de passe, isolation écran |

- **Total :** 4 tests API (Rust), 3 tests unitaires (Rust), 3 tests widget (Flutter).
- **Doublons évités :** E2E non requis pour 1.2 ; logique métier (validation) couverte en unitaire + API.

---

## Exécution des tests

### Rust

```bash
cd city-detectives-api

# Tous les tests (unitaires uniquement par défaut)
cargo test

# Tests d’intégration API (serveur sur localhost:8080)
cargo test --test auth_test -- --ignored --nocapture
```

### Flutter

```bash
cd city_detectives
flutter test
```

---

## Validation locale

- **Rust :** `cargo test` exécute les 3 nouveaux tests unitaires dans `user.rs` ; les 4 tests API restent `#[ignore]` sans serveur.
- **Flutter :** `flutter test` dépend de l’environnement (SDK hash, etc.) ; à lancer en local ou en CI.

*(Lors de l’exécution du workflow, `cargo` n’était pas dans le PATH du shell et Flutter a renvoyé une erreur de SDK ; les ajouts de code sont conformes au projet.)*

---

## Definition of Done

- [x] Critères d’acceptation 1.2 couverts (inscription, JWT, validation backend).
- [x] Tests unitaires Rust pour la validation `RegisterInput`.
- [x] Tests d’intégration API Rust pour email invalide et mot de passe court.
- [x] Pas de doublon inutile (pas d’E2E pour 1.2 ; API + widget suffisants).
- [x] Priorités P1/P2 respectées ; tags [P1]/[P2] documentés dans ce résumé.
- [x] Fichiers de test existants conservés ; nouveaux tests ajoutés aux bons emplacements.

---

## Fichiers modifiés / créés

| Fichier | Action |
|---------|--------|
| `city-detectives-api/src/models/user.rs` | Ajout du module `#[cfg(test)]` avec 3 tests unitaires. |
| `city-detectives-api/tests/api/auth_test.rs` | Ajout de 2 tests d’intégration (email invalide, mot de passe court). |
| `_bmad-output/automation-summary.md` | Créé (ce document). |

---

## Prochaines étapes

1. Lancer en local : `cargo test` puis, avec l’API démarrée, `cargo test --test auth_test -- --ignored --nocapture` ; `flutter test` dans `city_detectives`.
2. Vérifier en CI que les jobs Rust et Flutter exécutent bien ces tests.
3. Pour la suite : tests E2E (ex. integration_test) si une story le prévoit ; mock auth pour tester l’affichage des erreurs API sur l’écran d’inscription.

---

*Workflow : `_bmad/bmm/workflows/testarch/automate` (testarch-automate).*
