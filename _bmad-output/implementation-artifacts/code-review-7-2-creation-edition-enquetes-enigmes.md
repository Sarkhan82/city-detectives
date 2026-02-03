# Code Review – Story 7.2 : Création et édition d'enquêtes et d'énigmes

**Story:** 7-2-creation-edition-enquetes-enigmes  
**Story file:** `_bmad-output/implementation-artifacts/7-2-creation-edition-enquetes-enigmes.md`  
**Review date:** 2026-02-03  
**Reviewer:** Revue adverse (Senior Developer)

---

## Git vs File List

- **Fichiers modifiés (git):**  
  `city-detectives-api/src/api/graphql.rs`, `models/investigation.rs`, `models/enigma.rs`, `services/investigation_service.rs`, `services/admin_service.rs`, `services/enigma_service.rs`, `tests/api/admin_test.rs`,  
  plus `_bmad-output/implementation-artifacts/7-2-creation-edition-enquetes-enigmes.md`, `sprint-status.yaml`.
- **File List (story):** Les 7 fichiers backend/API listés ci-dessus sont bien documentés.
- **Écart:** `sprint-status.yaml` est modifié pour cette story mais n’apparaît pas dans la File List (fichier de suivi, pas de code métier) → **1 écart de documentation**.

---

## Synthèse des constats

| Sévérité | Nombre |
|----------|--------|
| CRITICAL | 0 |
| HIGH     | 2 |
| MEDIUM   | 3 |
| LOW      | 3 |
| **Total**| **8** |

---

## CRITICAL

_Aucun._ Les tâches marquées [x] correspondent bien à du code présent (mutations, services, tests create/update investigation et enigma).

---

## HIGH

### 1. Pas de test pour `validateEnigmaHistoricalContent` (FR64)

- **Fichier:** `city-detectives-api/tests/api/admin_test.rs`
- **Constat:** Les Testing Requirements de la story demandent un « Test de la validation du contenu historique (FR64) ». La mutation `validateEnigmaHistoricalContent(enigmaId)` est implémentée et protégée admin, mais il n’existe aucun test d’intégration (succès avec JWT admin, refus avec JWT user).
- **Action:** Ajouter au moins deux tests : `validate_enigma_historical_content_succeeds_when_admin_jwt` et `validate_enigma_historical_content_returns_forbidden_when_user_jwt`.

### 2. `updateInvestigation` accepte une difficulté vide

- **Fichier:** `city-detectives-api/src/services/investigation_service.rs` (lignes 161–162)
- **Constat:** Pour l’update, `difficulte` est fusionné avec  
  `input.difficulte.clone().unwrap_or_else(|| existing.difficulte.clone())`.  
  Si le client envoie `difficulte: ""`, la valeur conservée est une chaîne vide, ce qui contredit FR62 (champ requis / cohérent).
- **Action:** Lorsque `input.difficulte` est `Some(s)`, rejeter si `s.is_empty()` (par ex. `Err("La difficulté ne peut pas être vide".to_string())`).

---

## MEDIUM

### 3. Blocage potentiel en contexte async (EnigmaService)

- **Fichiers:** `city-detectives-api/src/services/enigma_service.rs` (std::sync::RwLock), appelé depuis `investigation_service.rs` dans `get_investigation_by_id_with_enigmas` (async).
- **Constat:** `EnigmaService` utilise `std::sync::RwLock` ; `get_enigmas_for_investigation` est synchrone et peut bloquer. Elle est appelée depuis un résolver async sans `spawn_blocking`, ce qui peut dégrader la réactivité sous charge.
- **Action:** À terme, soit passer à `tokio::sync::RwLock` et des méthodes async dans `EnigmaService`, soit appeler la partie bloquante dans `tokio::task::spawn_blocking` pour ne pas bloquer le runtime async.

### 4. File List : `sprint-status.yaml` non mentionné

- **Constat:** Le fichier `_bmad-output/implementation-artifacts/sprint-status.yaml` a été modifié (story passée en in-progress) dans le cadre de cette story mais n’apparaît pas dans la Dev Agent Record → File List.
- **Action:** Ajouter une ligne dans la File List ou une note dans les Completion Notes indiquant que `sprint-status.yaml` a été mis à jour pour le suivi de la story.

### 5. CreateEnigmaInput : pas de validation de `order_index`

- **Fichier:** `city-detectives-api/src/services/enigma_service.rs` (create_enigma), modèle `CreateEnigmaInput` dans `models/enigma.rs`.
- **Constat:** Les mocks utilisent des `order_index` 1-based. Aucune règle n’impose `order_index >= 1` à la création ; un `order_index: 0` est accepté et peut créer des incohérences d’affichage ou de tri.
- **Action:** En création, valider `order_index >= 1` (et éventuellement une borne max) et retourner une erreur explicite si la valeur est invalide.

---

## LOW

### 6. CreateInvestigationInput : statut invalide ignoré

- **Fichier:** `city-detectives-api/src/services/investigation_service.rs` (create_investigation), `parse_status`.
- **Constat:** Si le client envoie `status: "invalid"` ou une typo, `parse_status` renvoie `None` et le code utilise `InvestigationStatus::Draft` par défaut. Le client ne sait pas que sa valeur a été ignorée.
- **Action:** Si `input.status` est `Some(s)` et que `parse_status(s)` est `None`, retourner une erreur du type « Statut invalide : attendu 'draft' ou 'published' » au lieu de silencieusement forcer draft.

### 7. Doc / structure : `mutations.rs` vs `graphql.rs`

- **Constat:** Les File Structure Requirements et Dev Notes mentionnent « mutations dans `src/api/graphql/mutations.rs` », alors que toutes les mutations sont définies dans `src/api/graphql.rs`.
- **Action:** Mettre à jour la story (ou l’architecture) pour refléter que les mutations sont dans `graphql.rs` (ou prévoir un futur découpage en `mutations.rs` et l’indiquer).

### 8. list_investigations : clone complet du Vec

- **Fichier:** `city-detectives-api/src/services/investigation_service.rs` (list_investigations).
- **Constat:** `list_investigations` fait `guard.clone()` sur tout le `Vec<Investigation>`. Acceptable pour le MVP avec peu d’enquêtes, mais ne scale pas sans pagination ou vue en lecture plus légère.
- **Action:** Documenter la limite (MVP) ou prévoir une pagination / curseur dans une prochaine itération.

---

## Validation des AC et tâches [x]

- **AC1 (champs disponibles + validation historique) :**  
  Côté backend, les champs nécessaires sont exposés (investigations et énigmes) et la validation du contenu historique est possible via `historicalContentValidated` et `validateEnigmaHistoricalContent`. L’AC est **partiellement** satisfaite : il manque l’UI Flutter (Task 4) et l’affichage de la validation dans l’écran d’édition (Task 3.2).
- **Tâches marquées [x] :** Vérifiées dans le code (mutations, services, input types, garde admin, tests create/update investigation et enigma). Aucune tâche [x] sans implémentation correspondante.

---

## Recommandations de suite

1. ~~Corriger les **HIGH**~~ ✅ Fait (tests FR64 + validation difficulté en update).
2. ~~Traiter les **MEDIUM**~~ ✅ Fait (spawn_blocking, File List, order_index >= 1).
3. Optionnel : appliquer les **LOW** pour cohérence et maintenabilité.

---

## Corrections appliquées (option 1 – correction automatique)

- **HIGH 1** : Ajout de `validate_enigma_historical_content_succeeds_when_admin_jwt` et `validate_enigma_historical_content_returns_forbidden_when_user_jwt` dans `admin_test.rs`.
- **HIGH 2** : Dans `update_investigation`, rejet de `difficulte: Some("")` avec erreur « La difficulté ne peut pas être vide ».
- **MEDIUM 3** : `get_investigation_by_id_with_enigmas` appelle désormais `get_enigmas_for_investigation` via `tokio::task::spawn_blocking` pour éviter de bloquer le runtime async.
- **MEDIUM 4** : File List de la story complétée avec `sprint-status.yaml` (suivi).
- **MEDIUM 5** : Validation `order_index >= 1` dans `create_enigma` et `update_enigma` (erreur explicite si 0).

_Revue générée par le workflow code-review (adversarial)._
