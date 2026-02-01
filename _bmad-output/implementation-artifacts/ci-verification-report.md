# Rapport de vérification CI – City Detectives

**Date** : 2026-02-01  
**Contexte** : Vérification après nouveau code (Flutter + Rust API).

---

## 1. État du pipeline CI

| Élément | Statut | Détail |
|--------|--------|--------|
| **Fichier** | ✅ | `.github/workflows/quality.yml` présent |
| **Déclencheurs** | ✅ | push/PR sur `main`, `master`, `develop`, `feature/**` + `workflow_dispatch` |
| **Job Flutter** | ✅ | analyze, format, test (avec `--coverage`), timeout 15 min |
| **Job Rust** | ✅ | skip si pas de `Cargo.toml`, puis fmt / clippy / test, cache Cargo |
| **Artefacts** | ⚠️ | Pas d’upload en échec dans la version actuelle (burn-in/artefacts retirés) |

**Modifications constatées depuis la dernière version** :  
Branches étendues à `feature/**`, ajout de `workflow_dispatch`, job Rust avec logique de skip (`skip_rust`), utilisation de `workspaces: city-detectives-api` pour rust-cache. Job burn-in et concurrency retirés.

---

## 2. Code API (Rust)

| Fichier | Rôle | Statut |
|---------|------|--------|
| `main.rs` | Point d’entrée, Axum, CORS, GraphQL, JWT | ✅ Cohérent |
| `auth_service.rs` | Register, bcrypt, JWT, validate_token, 2 tests unitaires | ✅ Cohérent |
| `graphql.rs` | Schema, QueryRoot (health, me), MutationRoot (register), handler | ✅ Cohérent |
| `models/user.rs` | User, RegisterInput (validation email/length) | ✅ Cohérent |
| `api/middleware/auth.rs` | BearerToken, extract_bearer | ✅ Cohérent |
| `tests/api/auth_test.rs` | 2 tests HTTP `#[ignore]` (serveur sur 8080) | ✅ Cohérent |

**Tests** : Les tests unitaires dans `auth_service.rs` sont exécutés par `cargo test`. Les tests d’intégration dans `tests/api/auth_test.rs` sont ignorés par défaut (nécessitent le serveur sur 8080) ; le CI ne les lance pas, ce qui est cohérent avec un pipeline sans serveur démarré.

---

## 3. Vérifications locales (environnement de l’agent)

| Vérification | Résultat | Commentaire |
|--------------|----------|-------------|
| **Flutter format** | ✅ | `dart format --set-exit-if-changed .` → 12 fichiers, 0 modifié |
| **Flutter analyze** | ⏱️ | Timeout côté agent (analyse longue) ; à valider en CI ou en local |
| **Flutter test** | ❌ Local | Erreur « Invalid SDK hash » (environnement Flutter local) ; attendu que la CI (Ubuntu + Flutter 3.38.9) passe |
| **Rust (cargo)** | ❌ Local | `cargo` non disponible dans le PATH de l’agent ; la CI a Rust via `dtolnay/rust-toolchain@stable` |

Conclusion : les échecs constatés sont liés à l’environnement local de l’agent, pas à la structure du code ou du workflow.

---

## 4. Cohérence workflow ↔ projet

| Point | Statut |
|-------|--------|
| Répertoire Flutter | ✅ `working-directory: city_detectives` |
| Répertoire Rust | ✅ `working-directory: city-detectives-api`, skip si pas de `Cargo.toml` |
| Version Flutter | ✅ 3.38.9 (à mettre à jour manuellement après chaque release) |
| Cache | ✅ Flutter `cache: true`, Rust `Swatinem/rust-cache@v2` avec `workspaces: city-detectives-api` |
| Cargo.lock | ⚠️ Absent dans `city-detectives-api` ; recommandé pour builds reproductibles en CI |

---

## 5. Recommandations

1. **Cargo.lock** : Générer et committer `Cargo.lock` dans `city-detectives-api` (`cargo build` puis `git add Cargo.lock`) pour des builds CI reproductibles.
2. **Artefacts en échec** : Si tu veux conserver des artefacts en cas d’échec (comme avant), réintroduire une étape du type « Upload Flutter artifacts on failure » (ex. `city_detectives/coverage`) et éventuellement un job burn-in.
3. **Tests d’intégration API** : Pour exécuter `auth_test` en CI, il faudrait un job qui démarre le serveur sur 8080 puis lance `cargo test --test auth_test -- --ignored --nocapture` ; optionnel pour une première phase.

---

## 6. Synthèse

- **Pipeline** : Aligné avec le nouveau code (Flutter + Rust), branches et skip Rust cohérents.
- **Code API** : Structure claire, tests unitaires présents, tests d’intégration documentés et ignorés par défaut.
- **Prochain pas conseillé** : Pousser une branche et vérifier un run GitHub Actions complet ; ajouter `Cargo.lock` si besoin de reproductibilité.
