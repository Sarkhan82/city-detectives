# Story 3.1: Démarrer une enquête et navigation entre énigmes

**Story ID:** 3.1  
**Epic:** 3 – Core Gameplay & Navigation  
**Story Key:** 3-1-demarrer-enquete-navigation-enigmes  
**Status:** ready-for-dev  
**Depends on:** Story 2.2  
**Parallelizable with:** Story 7.3  
**Lane:** A  
**FR:** FR12, FR13  

---

## Story

As a **utilisateur**,  
I want **démarrer une enquête et naviguer entre les énigmes (liste ou flux)**,  
So that **je puisse avancer dans l'enquête étape par étape**.

---

## Acceptance Criteria

1. **Given** une enquête est sélectionnée  
   **When** l'utilisateur démarre l'enquête  
   **Then** la première énigme (ou écran d'intro) s'affiche (FR12)  
   **And** l'utilisateur peut passer d'une énigme à l'autre (FR13)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Backend : enquête + liste ordonnée d'énigmes
  - [ ] 1.1 Query GraphQL (ex. `getInvestigationById` ou `investigation(id)`) avec liste d'énigmes ordonnée (id, ordre, type, titre/description minimale pour affichage)
  - [ ] 1.2 Modèle/table énigmes si pas déjà présent (ex. `enigmas` avec `investigation_id`, `order_index`) ; résolution dans `investigation_service` ou `enigma_service`
  - [ ] 1.3 Pas de « session » persistante obligatoire pour 3.1 : le client peut recharger l'enquête + énigmes ; Story 3.3 ajoutera sauvegarde/progression
- [ ] **Task 2** (AC1) – Flutter : écran enquête en cours et navigation énigmes
  - [ ] 2.1 Depuis l'écran liste/détail (Story 2.2), CTA « Démarrer » → naviguer vers écran « enquête en cours » (ex. route `/investigations/:id/play` ou `/investigation/:id/enigmas`)
  - [ ] 2.2 Charger l'enquête + liste ordonnée des énigmes (AsyncValue) ; afficher la première énigme ou un écran d'intro si défini (FR12)
  - [ ] 2.3 Navigation entre énigmes : liste/stepper ou boutons Suivant / Précédent ; l'utilisateur peut passer d'une énigme à l'autre (FR13)
  - [ ] 2.4 Affichage minimal par énigme pour 3.1 : titre, ordre (ex. « Énigme 1/5 »), placeholder pour le contenu (résolution réelle des énigmes = Epic 4)
- [ ] **Task 3** (AC1) – Routes et état
  - [ ] 3.1 Route GoRouter pour l'écran « enquête en cours » (paramètre investigation id) ; garder cohérence avec 2.2 (sélection puis démarrage)
  - [ ] 3.2 Provider Riverpod pour l'état « enquête en cours » (investigation + liste énigmes + index énigme courante) ; état immuable, mise à jour via Notifier
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d'intégration pour la query enquête + énigmes (ex. `tests/api/investigations_test.rs` ou `enigmas_test.rs`)
  - [ ] 4.2 Flutter : tests widget pour l'écran enquête (affichage première énigme ou intro, navigation suivant/précédent)
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 2.1, 2.2

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 3.1 = premier pas du gameplay.** L'utilisateur a sélectionné une enquête (2.2) et la démarre ; il voit la première énigme (ou un écran d'intro) et peut naviguer entre les énigmes. La résolution des énigmes (photo, géo, mots, puzzle) et la progression/carte sont dans les stories suivantes (3.2, Epic 4).
- **Flutter** : Riverpod pour l'état enquête en cours (investigation + énigmes + index) ; GoRouter pour la route avec paramètre (id enquête). Design system « carnet de détective », accessibilité WCAG 2.1 Level A.
- **Backend** : GraphQL cohérent avec l'existant (types PascalCase, champs camelCase). Schéma : Investigation avec liste d'Enigma (ordre, type, champs minimaux pour affichage).

### Project Structure Notes

- **Flutter** : `lib/features/investigation/` – écran « enquête en cours » (ex. `investigation_play_screen.dart` ou `investigation_enigmas_screen.dart`), providers pour état enquête + énigmes, repositories si besoin. Réutiliser `lib/core/router/`, `lib/core/graphql/`. Préparer `lib/features/enigma/` si besoin de widgets partagés (affichage carte énigme) sans implémenter encore les types (photo, géo, etc.) = Epic 4.
- **Backend** : `src/services/investigation_service.rs` (ou `enigma_service.rs`) pour récupérer enquête + énigmes ordonnées ; `src/api/graphql/queries.rs`. Modèles Investigation, Enigma ; tables `investigations`, `enigmas` avec `investigation_id`, `order_index`.
- [Source: architecture.md § Requirements to Structure Mapping – Enquête Gameplay & Navigation, Énigme Resolution]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 3, Story 3.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – API GraphQL, Project Structure, Frontend Architecture]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]

---

## Architecture Compliance

| Règle | Application pour 3.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/investigation/` (screens, providers, repositories) ; route avec paramètre (id) |
| Structure Backend | `src/services/investigation_service.rs`, `src/api/graphql/queries.rs`, modèles Investigation, Enigma |
| État Flutter | `AsyncValue` pour chargement enquête+énigmes ; Notifier pour index énigme courante ; pas de booléen `isLoading` séparé |
| Navigation | GoRouter (routes déclaratives, paramètre :id) ; pas de `Navigator.push` direct pour écrans principaux |
| API GraphQL | Réponse format standard `{ data?, errors? }` ; champs camelCase ; IDs opaques (UUID) |
| Quality gates | `dart analyze`, `dart format`, `flutter test` (Flutter) ; `cargo test`, `clippy` (Rust) |
| Accessibilité | WCAG 2.1 Level A ; Semantics/labels sur écran enquête et navigation |

---

## Library / Framework Requirements

- **Flutter** : Riverpod 2.0+, GoRouter (paramètres de route), graphql_flutter 5.2.1 pour query enquête + énigmes. Packages déjà présents (Stories 1.x, 2.x). Aucune nouvelle dépendance obligatoire pour 3.1.
- **Backend** : async-graphql 7.x, async-graphql-axum, sqlx. Aligné sur `architecture.md` – Axum, GraphQL, PostgreSQL + sqlx.
- [Source: project-context.md – Technology Stack ; architecture.md – Backend Technology, API Design]

---

## File Structure Requirements

- **Flutter** : `lib/features/investigation/screens/` – ex. `investigation_play_screen.dart` ou `investigation_enigmas_screen.dart` ; providers dans `lib/features/investigation/providers/` ; routes dans `lib/core/router/app_router.dart` (ex. `/investigations/:id/play`).
- **Backend** : `src/services/investigation_service.rs` (get_investigation_with_enigmas ou équivalent), `src/api/graphql/queries.rs` ; modèles dans `src/models/` (investigation.rs, enigma.rs ou module commun). Migrations sqlx pour table `enigmas` si nouvelle.
- **Config** : Pas de changement `.env` obligatoire pour 3.1.
- [Source: architecture.md § Project Structure & Boundaries, File Organization Patterns]

---

## Testing Requirements

- **Backend** : Test d'intégration pour la query GraphQL enquête + énigmes (ex. getInvestigationById avec liste énigmes ordonnée) – au moins un cas nominal.
- **Flutter** : Tests widget pour l'écran enquête en cours : affichage première énigme (ou intro), présence des contrôles de navigation (suivant/précédent ou liste), changement d'énigme. Structure Given/When/Then pour cas non triviaux.
- **Qualité** : Pas de régression sur Stories 2.1, 2.2 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy ; project-context.md – Quality gates]

---

## Dependency Context (Story 2.2)

- **Story 2.2** fournit : liste des enquêtes avec gratuit/payant, sélection d'une enquête, CTA « Démarrer » (ou équivalent). En 3.1, ce CTA mène vers l'écran « enquête en cours » avec l'id de l'enquête sélectionnée.
- **Ne pas dupliquer** : réutiliser le modèle Investigation et les appels GraphQL déjà mis en place en 2.1/2.2 ; étendre si besoin (ex. query détaillée avec énigmes pour l'écran play).
- **Cohérence** : après « Démarrer », l'utilisateur doit arriver sur la première énigme (ou écran d'intro) sans étape intermédiaire superflue.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Validation** : Backend = source de vérité pour enquête et ordre des énigmes ; Flutter affiche les erreurs API (messages utilisateur).
- **Design** : Design system « carnet de détective » ; feedback visuel sur la navigation (indicateur d'étape, boutons clairs) ; carte et progression détaillée = Story 3.2.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
