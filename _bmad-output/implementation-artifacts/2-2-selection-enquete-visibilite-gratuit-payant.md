# Story 2.2: Sélection d'enquête et visibilité gratuit/payant

**Story ID:** 2.2  
**Epic:** 2 – Investigation Discovery & Selection  
**Story Key:** 2-2-selection-enquete-visibilite-gratuit-payant  
**Status:** ready-for-dev  
**Depends on:** Story 2.1  
**Parallelizable with:** Story 7.2  
**Lane:** A  
**FR:** FR8, FR9  

---

## Story

As a **utilisateur**,  
I want **sélectionner une enquête pour la démarrer et voir clairement lesquelles sont gratuites ou payantes**,  
So that **je sache quoi attendre avant de lancer**.

---

## Acceptance Criteria

1. **Given** la liste des enquêtes est affichée  
   **When** l'utilisateur choisit une enquête  
   **Then** il peut la démarrer (FR8)  
   **And** le libellé gratuit vs payant est visible pour chaque enquête (FR9)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Backend : visibilité gratuit/payant et démarrage
  - [ ] 1.1 S'assurer que le modèle Investigation (ou équivalent) expose `isFree` (ou `is_free` en DB) ; la query `listInvestigations` doit le retourner (Story 2.1 peut déjà l'avoir)
  - [ ] 1.2 Si nécessaire : mutation ou query pour « démarrer une enquête » (ex. `startInvestigation(id)`) retournant un token de session ou un état ; sinon navigation Flutter seule avec id enquête
  - [ ] 1.3 Pas de changement obligatoire si 2.1 a déjà is_free dans l'API ; sinon ajouter le champ au schéma GraphQL et au modèle
- [ ] **Task 2** (AC1) – Flutter : libellé gratuit/payant et sélection
  - [ ] 2.1 Sur l'écran liste des enquêtes (Story 2.1), afficher pour chaque item un libellé visible « Gratuit » ou « Payant » (badge, chip ou texte selon design system « carnet de détective »)
  - [ ] 2.2 Mapper le champ `isFree` (GraphQL) vers l'affichage ; gérer le cas où le champ est absent (fallback « Payant » ou depuis API)
  - [ ] 2.3 Au tap sur une enquête : navigation vers écran de démarrage ou détail puis CTA « Démarrer » ; la sélection permet de lancer l'enquête (FR8)
- [ ] **Task 3** (AC1) – Navigation et cohérence
  - [ ] 3.1 Route(s) GoRouter pour « détail enquête » et/ou « démarrer enquête » (ex. `/investigations/:id` ou `/investigations/:id/start`) selon architecture choisie en 2.1
  - [ ] 3.2 Depuis la liste : tap sur une enquête → navigation vers détail ou démarrage ; CTA « Démarrer l'enquête » depuis le détail si applicable
  - [ ] 3.3 Story 3.1 gérera l'écran de jeu ; pour 2.2, la navigation peut aboutir à un écran placeholder « Démarrer » ou à l'entrée du flux d'enquête (à définir avec 3.1)
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d'intégration pour le champ is_free dans listInvestigations (ou test existant étendu) ; pas de régression sur 2.1
  - [ ] 4.2 Flutter : tests widget pour la liste avec libellé Gratuit/Payant visible et tap → navigation
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 1.1–2.1

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 2.2 = suite de 2.1.** La liste des enquêtes existe (2.1) ; 2.2 ajoute la visibilité gratuit/payant et l'action « choisir pour démarrer ». Le libellé doit être clair et accessible (WCAG 2.1 Level A).
- **Flutter** : Réutiliser l'écran liste et le provider de 2.1 ; ajouter l'affichage du badge Gratuit/Payant et le geste de sélection (tap → route détail ou start). AsyncValue pour tout chargement ; pas de loader global.
- **Backend** : Si 2.1 a déjà exposé `isFree` dans listInvestigations, aucun changement obligatoire. Sinon ajouter le champ au modèle et à la query GraphQL (camelCase en API).

### Project Structure Notes

- **Flutter** : `lib/features/investigation/` – réutiliser `investigation_list_screen.dart` (2.1), ajouter badge Gratuit/Payant et navigation au tap ; éventuellement `investigation_detail_screen.dart` ou route `/investigations/:id` pour détail + CTA Démarrer.
- **Backend** : `src/models/` (Investigation avec is_free si pas déjà fait), `src/api/graphql/queries.rs` (listInvestigations avec champ isFree). Pas de nouveau service obligatoire si 2.1 couvre la liste.
- [Source: architecture.md § Requirements to Structure Mapping – Enquête Discovery & Selection]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 2, Story 2.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – API GraphQL, Frontend Architecture]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]

---

## Architecture Compliance

| Règle | Application pour 2.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, champs API `camelCase` (serde rename) |
| Structure Flutter | `lib/features/investigation/` (screens, providers, repositories, graphql) ; réutiliser 2.1 |
| Structure Backend | Modèle Investigation avec `is_free` ; query listInvestigations inchangée ou étendue |
| État Flutter | `AsyncValue` pour liste ; pas de booléen `isLoading` séparé |
| Navigation | GoRouter (routes déclaratives) ; `/investigations`, `/investigations/:id` ou équivalent |
| API GraphQL | Champ `isFree` (camelCase) dans type Investigation ; réponse standard `{ data?, errors? }` |
| Quality gates | `dart analyze`, `dart format`, `flutter test` ; `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; Semantics/labels sur libellé Gratuit/Payant et CTA Démarrer |

---

## Library / Framework Requirements

- **Flutter** : Riverpod 2.0+, GoRouter, graphql_flutter 5.2.1 (déjà utilisés en 2.1). Aucune nouvelle dépendance obligatoire pour 2.2.
- **Backend** : async-graphql 7.x, async-graphql-axum ; pas de nouveau crate obligatoire si is_free ajouté au modèle existant.
- [Source: project-context.md – Technology Stack ; architecture.md – Backend Technology]

---

## File Structure Requirements

- **Flutter** : Fichiers modifiés/créés dans `lib/features/investigation/` (écran liste étendu, éventuellement détail) ; routes dans `lib/core/router/app_router.dart`. Fichiers GraphQL en `snake_case.graphql` si nouvelle query.
- **Backend** : `src/models/investigation.rs` (ou équivalent) avec champ `is_free` ; `src/api/graphql/queries.rs` si résolution listInvestigations à étendre.
- **Config** : Pas de changement `.env` obligatoire pour 2.2.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test d'intégration vérifiant que listInvestigations retourne bien un champ isFree (ou is_free mappé en camelCase) pour au moins une enquête gratuite et une payante.
- **Flutter** : Tests widget pour l'écran liste : présence du libellé « Gratuit » ou « Payant » selon les données ; tap sur un item déclenche la navigation attendue. Structure Given/When/Then pour cas non triviaux.
- **Qualité** : Pas de régression sur Stories 1.1 à 2.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy ; project-context.md – Quality gates]

---

## Previous Story Intelligence (Story 2.1)

- **Liste des enquêtes** : Story 2.1 met en place l'écran liste avec durée, difficulté, description et la query GraphQL listInvestigations. Le modèle Investigation en 2.1 inclut déjà `is_free` (Task 1.1 de 2.1) ; 2.2 exploite ce champ pour l'affichage et ajoute la sélection/démarrage.
- **Structure en place** : `lib/features/investigation/screens/investigation_list_screen.dart`, providers, repositories, graphql (list_investigations.graphql), route `/investigations`. Ne pas dupliquer ; étendre l'écran liste pour badge Gratuit/Payant et navigation au tap.
- **Backend** : Si listInvestigations existe avec is_free, aucun changement API obligatoire. Sinon ajouter le champ au schéma et au modèle Rust (snake_case en DB, camelCase en GraphQL).
- **Navigation** : Depuis onboarding (1.3), « Voir les enquêtes » mène à l'écran liste (2.1). En 2.2, depuis la liste, le tap sur une enquête mène au détail ou au démarrage (route à définir en cohérence avec Story 3.1).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Validation** : Backend = source de vérité pour is_free et données catalogue ; Flutter affiche les erreurs API.
- **Design** : Design system « carnet de détective » ; libellé Gratuit/Payant visible et contrasté ; CTA « Démarrer » clair.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
