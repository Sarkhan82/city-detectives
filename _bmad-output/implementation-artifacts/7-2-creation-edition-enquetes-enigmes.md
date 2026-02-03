# Story 7.2: Création et édition d'enquêtes et d'énigmes

**Story ID:** 7.2  
**Epic:** 7 – Admin & Content Management  
**Story Key:** 7-2-creation-edition-enquetes-enigmes  
**Status:** in-progress  
**Depends on:** Story 7.1  
**Parallelizable with:** Story 2.2  
**Lane:** B  
**FR:** FR62, FR63, FR64  

---

## Story

As an **admin**,  
I want **créer et éditer des enquêtes et des énigmes, et valider la précision du contenu historique**,  
So that **le catalogue reste à jour et fiable**.

---

## Acceptance Criteria

1. **Given** l'admin est sur le dashboard  
   **When** il crée ou modifie une enquête ou une énigme  
   **Then** les champs nécessaires sont disponibles (FR62, FR63)  
   **And** la validation du contenu historique est possible (FR64)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Mutations et API admin pour les enquêtes
  - [x] 1.1 Backend : mutations GraphQL réservées aux admins, ex. `createInvestigation(input)`, `updateInvestigation(id, input)` ; champs alignés sur le modèle existant (titre, description, durée estimée, difficulté, isFree, price/priceCurrency si 6.1 en place, statut brouillon/publié pour 7.3) (FR62).
  - [x] 1.2 Backend : service `investigation_service.rs` (ou admin_service) avec `create_investigation`, `update_investigation` ; validation des champs (validator) ; persistance en base (FR62).
  - [x] 1.3 Schéma GraphQL : input type nommé ex. `CreateInvestigationInput` / `UpdateInvestigationInput` avec champs camelCase ; retour type `Investigation` (FR62).
  - [x] 1.4 Middleware admin : protéger les mutations create/update investigation (même guard que 7.1) (FR62).
- [x] **Task 2** (AC1) – Mutations et API admin pour les énigmes
  - [x] 2.1 Backend : mutations ex. `createEnigma(input)`, `updateEnigma(id, input)` ; champs selon types d’énigmes (type, investigationId, ordre, question, réponses attendues, indices, explication historique, coordonnées pour géo, etc.) (FR63).
  - [x] 2.2 Backend : service `enigma_service.rs` (ou admin) avec `create_enigma`, `update_enigma` ; liaison à une enquête ; validation (FR63).
  - [x] 2.3 Schéma GraphQL : input types nommés pour création/édition énigme ; type `Enigma` (ou existant) avec tous les champs nécessaires à l’édition (FR63).
  - [x] 2.4 Protéger les mutations énigmes par le middleware admin (FR63).
- [ ] **Task 3** (AC1) – Validation du contenu historique (FR64)
  - [x] 3.1 Backend : permettre de marquer qu’une énigme (ou un bloc de contenu) a été validée pour la précision historique (ex. champ `historicalContentValidated: Boolean` ou statut « validé ») ; mutation ex. `validateEnigmaHistoricalContent(id)` ou champ dans `updateEnigma` (FR64).
  - [ ] 3.2 Flutter : dans l’écran d’édition d’une énigme, afficher l’état de validation et un moyen de marquer comme validé (bouton ou case à cocher) (FR64).
- [ ] **Task 4** (AC1) – Interface admin : écrans création/édition
  - [ ] 4.1 Flutter : depuis le dashboard (7.1), accès à « Créer une enquête » et « Liste des enquêtes » (édition au clic) ; formulaire avec tous les champs nécessaires (titre, description, durée, difficulté, isFree, prix si applicable, etc.) (FR62).
  - [ ] 4.2 Flutter : écran liste des énigmes d’une enquête (ou intégré à l’édition enquête) ; création/édition d’une énigme avec champs selon le type (photo, géo, mots, puzzle, …) et option validation contenu historique (FR63, FR64).
  - [ ] 4.3 Providers/Repositories : appels aux mutations `createInvestigation`, `updateInvestigation`, `createEnigma`, `updateEnigma`, et validation historique ; `AsyncValue` pour chargement/erreur ; invalidation après mutation pour rafraîchir les listes (FR62, FR63).
  - [ ] 4.4 Design : cohérent avec le dashboard et le design system ; formulaires lisibles (labels, regroupement logique) (FR62, FR63).
- [ ] **Task 5** – Qualité et conformité
  - [x] 5.1 Backend : tests d’intégration pour create/update investigation et create/update enigma avec JWT admin ; test refus avec JWT non-admin (FR62, FR63).
  - [ ] 5.2 Flutter : tests widget pour formulaires création/édition (champs présents, soumission mockée) (FR62, FR63).
  - [ ] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 7.1, 2.1, 2.2.
  - [ ] 5.4 Accessibilité : labels pour tous les champs de formulaire (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 7.2 = CRUD admin enquêtes et énigmes + validation historique.** S’appuie sur 7.1 (dashboard, accès admin). Réutilise les modèles Investigation et Enigma existants (2.1, 2.2, 4.x) ; on ajoute les mutations de création/édition et l’UI admin. La publication (disponibilité pour les utilisateurs) est en 7.3.
- **Champs enquête** : alignés sur 2.1 (titre, description, durée, difficulté), 2.2 (isFree), 6.1 si fait (price, priceCurrency). Ajouter un statut de publication (draft/published) pour 7.3 (rollback).
- **Champs énigme** : type (photo, geolocation, words, puzzle, …), ordre dans l’enquête, question, réponses/indices, explication historique ; pour géo : coordonnées ; pour photo : référence lieu. FR64 = champ ou action « contenu historique validé ».
- **Ne pas dupliquer** : les queries/listes côté app utilisateur (2.1, 2.2) restent inchangées ; les mutations admin sont distinctes et protégées par rôle.

### Project Structure Notes

- **Flutter** : `lib/features/admin/` – écrans `investigation_edit_screen.dart`, `enigma_edit_screen.dart` (ou formulaire intégré), providers/repositories pour les mutations ; graphql `create_investigation.graphql`, `update_investigation.graphql`, etc.
- **Backend** : `src/services/investigation_service.rs` (create/update), `src/services/enigma_service.rs` (create/update) ; `src/api/graphql/mutations.rs` ; input types dans le schéma ; middleware admin sur ces mutations.
- [Source: architecture.md § Requirements to Structure Mapping, Admin, Enquête, Énigme]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 7, Story 7.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – Project Structure, investigation_service, enigma_service]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]
- [Source: Stories 2.1, 2.2 – champs Investigation ; 4.x – types énigmes]

---

## Architecture Compliance

| Règle | Application pour 7.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/admin/` – écrans édition enquête/énigme, formulaires, mutations GraphQL |
| Structure Backend | `src/services/investigation_service.rs`, `enigma_service.rs` ; mutations dans `api/graphql/mutations.rs` |
| API GraphQL | Input types nommés (CreateInvestigationInput, etc.), champs `camelCase` ; mutations réservées aux admins |
| Validation | Backend = source de vérité (validator) ; messages d’erreur dans les réponses GraphQL |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels formulaires |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Formulaires : widgets standard ou package de formulaire si déjà utilisé (sinon champs texte/select manuels). Aucune dépendance obligatoire supplémentaire pour 7.2.
- **Backend** : Réutilisation de async-graphql, sqlx, validator ; pas de nouvelle dépendance. Création/édition = mutations + services existants étendus.
- [Source: architecture.md – GraphQL, Validation]

---

## File Structure Requirements

- **Flutter** : `lib/features/admin/screens/investigation_edit_screen.dart`, `enigma_edit_screen.dart` (ou composants formulaire) ; `lib/features/admin/graphql/create_investigation.graphql`, `update_investigation.graphql`, `create_enigma.graphql`, `update_enigma.graphql` ; providers pour soumission et liste (dashboard ou liste enquêtes/énigmes).
- **Backend** : `src/services/investigation_service.rs` (ajout create/update), `src/services/enigma_service.rs` (ajout create/update) ; `src/api/graphql/mutations.rs` (createInvestigation, updateInvestigation, createEnigma, updateEnigma, validateEnigmaHistoricalContent ou champ dans update) ; migrations sqlx si nouveaux champs (ex. `historical_content_validated`, `status` sur investigations).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d’intégration pour createInvestigation, updateInvestigation (JWT admin → succès ; JWT user → erreur). Idem pour createEnigma, updateEnigma. Test de la validation du contenu historique (FR64).
- **Flutter** : Tests widget pour écrans/formulaires création et édition (présence des champs, soumission avec mocks) ; pas de régression sur 7.1.
- **Qualité** : `flutter test` et `cargo test` verts ; pas de régression sur 2.1, 2.2, 7.1.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 7.1)

- **Dashboard et accès admin** : 7.1 fournit le dashboard et la route protégée admin. En 7.2, depuis le dashboard, l’admin accède aux écrans de création/édition d’enquêtes et d’énigmes. Réutiliser le même middleware admin (JWT avec rôle) pour protéger les mutations.
- **Ne pas dupliquer** : les queries côté app (listInvestigations, etc.) restent pour les utilisateurs ; les mutations create/update sont réservées aux admins et exposées uniquement dans la feature admin.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Publication et rollback** : gérés en 7.3 ; en 7.2 on peut introduire un statut « brouillon » sur les enquêtes pour préparer 7.3.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- **Task 1–2, 3.1, 5.1 (backend)** : Mutations GraphQL `createInvestigation`, `updateInvestigation`, `createEnigma`, `updateEnigma`, `validateEnigmaHistoricalContent` implémentées et protégées par `require_admin`. Modèle Investigation : champ `status` (draft/published), input types Create/Update. Modèle Enigma : champs optionnels pour édition (geo, photo, hints, explication), `historicalContentValidated`. Services avec store mutable (RwLock) ; validation (validator + règles métier). Tests d'intégration admin : create/update investigation et enigma (succès admin, FORBIDDEN user).
- **Restant** : Task 3.2 (Flutter affichage validation), Task 4 (écrans admin Flutter création/édition), Task 5.2–5.4 (tests Flutter, quality gates, accessibilité).
- **Code review (2026-02-03)** : Corrections appliquées : (1) Tests validateEnigmaHistoricalContent (admin OK, user 403). (2) updateInvestigation rejette difficulte vide. (3) get_investigation_by_id_with_enigmas appelle get_enigmas_for_investigation via spawn_blocking pour éviter blocage async. (4) File List complétée avec sprint-status.yaml. (5) create_enigma valide order_index >= 1.

### File List

- city-detectives-api/src/models/investigation.rs
- city-detectives-api/src/models/enigma.rs
- city-detectives-api/src/services/investigation_service.rs
- city-detectives-api/src/services/admin_service.rs
- city-detectives-api/src/services/enigma_service.rs
- city-detectives-api/src/api/graphql.rs
- city-detectives-api/tests/api/admin_test.rs
- _bmad-output/implementation-artifacts/sprint-status.yaml (suivi : statut story in-progress)

---

## Senior Developer Review (AI)

**Date :** 2026-02-03  
**Issue :** Changes Requested → corrections appliquées automatiquement.

**Résultat :** 2 HIGH et 3 MEDIUM corrigés (tests FR64, validation difficulté vide, spawn_blocking, File List, order_index >= 1). Story toujours **in-progress** (Tasks 4 et 5.2–5.4 restantes).

**Action items résolus :**
- [x] [HIGH] Ajout tests validateEnigmaHistoricalContent (admin OK, user 403)
- [x] [HIGH] updateInvestigation rejette difficulte vide
- [x] [MEDIUM] get_investigation_by_id_with_enigmas utilise spawn_blocking pour EnigmaService
- [x] [MEDIUM] File List + sprint-status.yaml
- [x] [MEDIUM] create_enigma / update_enigma valident order_index >= 1

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
