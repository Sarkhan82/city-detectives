# Story 2.1: Parcourir et consulter les enquêtes

**Story ID:** 2.1  
**Epic:** 2 – Investigation Discovery & Selection  
**Story Key:** 2-1-parcourir-consulter-enquetes  
**Status:** done  
**Depends on:** Story 1.3  
**Parallelizable with:** Story 7.1  
**Lane:** A  
**FR:** FR6, FR7  

---

## Story

As a **utilisateur**,  
I want **parcourir la liste des enquêtes disponibles et voir les détails (durée, difficulté, description)**,  
So that **je puisse choisir quelle enquête lancer**.

---

## Acceptance Criteria

1. **Given** l'utilisateur a terminé l'onboarding  
   **When** il ouvre l'écran de sélection d'enquêtes  
   **Then** la liste des enquêtes disponibles s'affiche (FR6)  
   **And** pour chaque enquête : durée, difficulté, description sont visibles (FR7)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Backend : modèle et API catalogue enquêtes
  - [x] 1.1 Modèle Investigation (ou équivalent) avec champs : id, titre, description, durée_estimée, difficulté, is_free (pour Story 2.2)
  - [x] 1.2 Query GraphQL `listInvestigations` (ou `investigations`) retournant la liste avec durée, difficulté, description
  - [x] 1.3 Service `investigation_service.rs` : fonction list_investigations ; résolution GraphQL dans `api/graphql.rs`
- [x] **Task 2** (AC1) – Flutter : feature investigation et écran liste
  - [x] 2.1 Créer `lib/features/investigation/` (screens, providers, repositories, graphql)
  - [x] 2.2 Modèle Dart Investigation aligné sur le schéma GraphQL (durée, difficulté, description)
  - [x] 2.3 Repository + provider Riverpod pour charger la liste (AsyncValue<List<Investigation>>)
  - [x] 2.4 Écran liste des enquêtes : afficher pour chaque item durée, difficulté, description (design system « carnet de détective »)
- [x] **Task 3** (AC1) – Navigation et entrée
  - [x] 3.1 Route GoRouter pour l’écran liste (ex. `/investigations` ou `/enquetes`)
  - [x] 3.2 Depuis la fin de l’onboarding (Story 1.3) : navigation vers cet écran liste (ou garder cohérence si 1.3 redirige déjà vers « Voir les enquêtes »)
- [x] **Task 4** – Qualité et conformité
  - [x] 4.1 Backend : test d’intégration pour la query listInvestigations (tests/api/investigations_test.rs ou équivalent)
  - [x] 4.2 Flutter : tests widget pour l’écran liste (présence liste, champs durée/difficulté/description)
  - [x] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 1.1–1.3

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 2.1 = premier écran catalogue.** L’utilisateur a terminé l’onboarding (1.3) ; il arrive sur l’écran qui affiche la liste des enquêtes avec durée, difficulté, description. La distinction gratuit/payant et le « sélectionner pour démarrer » sont dans Story 2.2.
- **Flutter** : Riverpod pour l’état liste (AsyncValue) ; GoRouter pour la route liste ; pas de loader global. Design system « carnet de détective », accessibilité WCAG 2.1 Level A.
- **Backend** : GraphQL comme dans l’architecture (async-graphql, Axum). Schéma cohérent : types PascalCase, champs camelCase en API ; tables/colonnes snake_case en PostgreSQL.

### Project Structure Notes

- **Flutter** : `lib/features/investigation/` – screens (ex. `investigation_list_screen.dart`), providers, repositories, `graphql/` pour les opérations (ex. `list_investigations.graphql`). Réutiliser `lib/core/router/`, `lib/core/graphql/`, `lib/core/config/`.
- **Backend** : `src/services/investigation_service.rs`, `src/api/graphql.rs` (résolution listInvestigations), `src/models/` pour les DTOs. Structure existante : `src/api/graphql/`, `src/services/auth_service.rs` – s’aligner sur les mêmes patterns.
- [Source: architecture.md § Requirements to Structure Mapping – Enquête Discovery & Selection]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 2, Story 2.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – API GraphQL, Project Structure, Frontend Architecture]
- [Source: _bmad-output/project-context.md – Technology Stack, Critical Implementation Rules]

---

## Architecture Compliance

| Règle | Application pour 2.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/investigation/` (screens, providers, repositories, graphql) ; `lib/core/router/` pour routes |
| Structure Backend | `src/services/investigation_service.rs`, `src/api/graphql.rs`, `src/models/` |
| État Flutter | `AsyncValue<List<Investigation>>` pour la liste ; pas de booléen `isLoading` séparé |
| Navigation | GoRouter (routes déclaratives) ; pas de `Navigator.push` direct pour écrans principaux |
| API GraphQL | Réponse format standard `{ data?, errors? }` ; champs camelCase ; IDs opaques (UUID) |
| Quality gates | `dart analyze`, `dart format`, `flutter test` (Flutter) ; `cargo test`, `clippy` (Rust) |
| Accessibilité | WCAG 2.1 Level A ; Semantics/labels sur l’écran liste |

---

## Library / Framework Requirements

- **Flutter** : Riverpod 2.0+, GoRouter, graphql_flutter 5.2.1 (pour query listInvestigations). Packages déjà présents (Story 1.1–1.3). Aucune nouvelle dépendance obligatoire pour 2.1 si le client GraphQL est déjà configuré.
- **Backend** : async-graphql 7.x, async-graphql-axum, sqlx (si les enquêtes viennent de la DB) ou mock en mémoire pour MVP. Aligné sur `architecture.md` – Axum, GraphQL, PostgreSQL + sqlx.
- [Source: project-context.md – Technology Stack ; architecture.md – Backend Technology, API Design]

---

## File Structure Requirements

- **Flutter** : `lib/features/investigation/screens/investigation_list_screen.dart` ; `lib/features/investigation/providers/`, `repositories/`, `graphql/` (ex. `list_investigations.graphql`). Routes dans `lib/core/router/app_router.dart` (ex. `/investigations`).
- **Backend** : `src/services/investigation_service.rs` ; `src/api/graphql.rs` (résolution listInvestigations) ; modèles dans `src/models/` (ex. `investigation.rs`). Migrations sqlx si nouvelle table `investigations`.
- **Config** : Pas de changement `.env` obligatoire pour 2.1 sauf si URL/clef déjà utilisées pour l’API.
- [Source: architecture.md § Project Structure & Boundaries, File Organization Patterns]

---

## Testing Requirements

- **Backend** : Test d’intégration pour la query GraphQL listInvestigations (ex. `tests/api/investigations_test.rs`) – au moins un cas nominal (liste non vide ou vide).
- **Flutter** : Tests widget pour l’écran liste des enquêtes : présence de la liste, affichage durée/difficulté/description pour au moins un item (ou état vide). Structure Given/When/Then pour cas non triviaux.
- **Qualité** : Pas de régression sur Stories 1.1, 1.2, 1.3 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy ; project-context.md – Quality gates]

---

## Previous Story Intelligence (Story 1.3)

- **Navigation post-onboarding** : Story 1.3 prévoit « À la fin de l'onboarding : navigation vers écran liste des enquêtes ou première enquête ». Implémenter la route vers l’écran liste (2.1) et s’assurer que le CTA « Voir les enquêtes » ou équivalent redirige vers `/investigations` (ou le chemin choisi).
- **Structure en place** : `lib/features/onboarding/screens/`, `lib/core/router/app_router.dart`, `lib/core/graphql/`, `lib/core/services/auth_service.dart`, `lib/core/repositories/user_repository.dart`. Ne pas dupliquer ; réutiliser router et client GraphQL pour la nouvelle feature investigation.
- **État et UX** : Utiliser `AsyncValue<T>` pour tout chargement async ; pas de booléen `isLoading`. Design system « carnet de détective », accessibilité WCAG 2.1 Level A (Semantics/labels).
- **Backend** : Story 1.3 indique « Optionnel : query GraphQL première enquête gratuite ou enquêtes (liste minimale) ». En 2.1, la query listInvestigations devient obligatoire ; si un mock ou une table minimale existe déjà, l’étendre ; sinon créer le modèle et le service.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Validation** : Backend = source de vérité pour les données catalogue ; Flutter affiche les erreurs API (messages utilisateur, pas de stack technique).
- **Design** : Design system « carnet de détective » ; carte interactive et feedback visuel riches (pour les stories suivantes) ; pour 2.1, focus sur liste lisible avec durée, difficulté, description.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Story 2.1 implémentée : backend modèle Investigation + query listInvestigations + service mock ; Flutter feature investigation (écran liste, repository, provider Riverpod AsyncValue) ; route /investigations et redirection post-onboarding ; tests d'intégration backend (investigations_test.rs) et tests widget (investigation_list_screen_test.dart). dart analyze, flutter test, cargo test, clippy verts.
- **Correctifs code review (2026-02-01)** : dart format appliqué ; Investigation.fromJson défensif (null, types tolérants) ; test backend in-process listInvestigations (api/graphql.rs, exécutable en CI) ; fichier list_investigations.graphql orphelin supprimé ; message erreur utilisateur (_userFriendlyErrorMessage) ; test widget état erreur ajouté ; Dev Notes alignés sur api/graphql.rs. Fichiers user.rs / auth_test.rs : modifs hors 2.1 (CRLF), non listés dans File List.

### File List

- city-detectives-api/src/models/investigation.rs
- city-detectives-api/src/models/mod.rs
- city-detectives-api/src/services/investigation_service.rs
- city-detectives-api/src/services/mod.rs
- city-detectives-api/src/api/graphql.rs
- city-detectives-api/src/main.rs
- city-detectives-api/Cargo.toml
- city-detectives-api/tests/api/investigations_test.rs
- city_detectives/lib/features/investigation/models/investigation.dart
- city_detectives/lib/features/investigation/repositories/investigation_repository.dart
- city_detectives/lib/features/investigation/providers/investigation_list_provider.dart
- city_detectives/lib/features/investigation/screens/investigation_list_screen.dart
- city_detectives/lib/core/router/app_router.dart
- city_detectives/lib/features/onboarding/screens/onboarding_screen.dart
- city_detectives/test/features/investigation/investigation_list_screen_test.dart
- _bmad-output/implementation-artifacts/sprint-status.yaml
- _bmad-output/implementation-artifacts/2-1-parcourir-consulter-enquetes.md

---

## Change Log

- **2026-02-01** – Code review (AI) : revue adverse effectuée ; 8 findings (2 High, 4 Medium, 2 Low). Correctifs automatiques appliqués (option 1).

---

## Senior Developer Review (AI)

**Reviewer :** Agent (revue adverse)  
**Date :** 2026-02-01  
**Outcome :** Approved (correctifs appliqués)  

### Résumé

- **Git vs File List :** 2 fichiers modifiés (git) non listés dans la File List : `city-detectives-api/src/models/user.rs`, `city-detectives-api/tests/api/auth_test.rs` (changements CRLF ou mineurs).
- **Issues trouvées :** 2 High, 4 Medium, 2 Low (≥ 3 requis).

### 🔴 HIGH

1. **AC / Quality gate – `dart format` non appliqué** [File List – Flutter]  
   La story 4.3 exige « `dart format` vert ». `dart format --set-exit-if-changed` a reformaté 6 fichiers (router, investigation models/providers/repositories/screens, test). Les fichiers n’étaient pas formatés avant la revue → quality gate non respecté.

2. **Robustesse – `Investigation.fromJson` sans défense** [city_detectives/lib/features/investigation/models/investigation.dart]  
   Cast directs (`as String`, `as int`, etc.) sans null-safety ni gestion de champs manquants. Si l’API renvoie `null` ou un type inattendu (ex. `durationEstimate` en string), l’app peut crasher. Project-context : backend = source de vérité ; le client doit néanmoins se protéger contre réponses partielles ou erreurs de schéma.

### 🟡 MEDIUM

3. **Tests backend – tous `#[ignore]`** [city-detectives-api/tests/api/investigations_test.rs]  
   Les deux tests d’intégration sont `#[ignore]`. Ils ne s’exécutent pas dans `cargo test` par défaut, donc la CI ne valide pas `listInvestigations`. La story exige un test d’intégration pour la query ; il manque soit un test exécutable en CI (ex. avec client de test/mock), soit une étape CI explicite avec serveur.

4. **Documentation – Fichier .graphql orphelin** [city_detectives/lib/features/investigation/graphql/list_investigations.graphql]  
   Le fichier `list_investigations.graphql` existe mais n’est pas utilisé : le repository utilise une query en string inline. Risque de désynchronisation schéma / code. Soit utiliser ce fichier (build/codegen), soit le supprimer pour éviter la duplication.

5. **File List – Fichiers modifiés non documentés**  
   `user.rs` et `auth_test.rs` apparaissent modifiés dans `git status` mais ne sont pas dans la File List de la story 2.1. Si les changements sont liés à 2.1, ils doivent être listés ; sinon, préciser qu’ils viennent d’une autre story.

6. **Dev Notes incohérents**  
   Les Dev Notes / File Structure Requirements mentionnent encore « `src/api/graphql/queries.rs` » alors que la résolution est dans `api/graphql.rs`. Aligner la doc avec l’implémentation.

### 🟢 LOW

7. **Tests widget – état erreur non testé** [city_detectives/test/features/investigation/investigation_list_screen_test.dart]  
   Seuls les états « data » et « liste vide » sont couverts. Aucun test pour `asyncList.when(error: ...)` (affichage du message d’erreur). Recommandation : ajouter un test avec provider override en `AsyncValue.error`.

8. **Affichage erreur – message utilisateur** [city_detectives/lib/features/investigation/screens/investigation_list_screen.dart]  
   En erreur, affichage de `err.toString().replaceFirst('Exception: ', '')`. Si l’exception contient une stack ou du technique (ex. linkException), l’utilisateur peut les voir. Project-context : « messages utilisateur, pas de stack technique ». Recommandation : extraire un message court (ex. premier graphqlError.message ou message générique).

### Action Items – correctifs appliqués

- [x] [AI-Review][High] Appliquer `dart format` à tous les fichiers Flutter modifiés et vérifier `dart format --set-exit-if-changed` en CI.
- [x] [AI-Review][High] Rendre `Investigation.fromJson` défensif : champs optionnels, types tolérants (ex. int depuis number ou string), pas de crash sur null/type inattendu.
- [x] [AI-Review][Medium] Test listInvestigations exécutable en CI (test in-process dans api/graphql.rs).
- [x] [AI-Review][Medium] Fichier list_investigations.graphql orphelin supprimé.
- [x] [AI-Review][Medium] Noté : user.rs/auth_test.rs modifs hors 2.1 (CRLF).
- [x] [AI-Review][Medium] Dev Notes alignés avec api/graphql.rs.
- [x] [AI-Review][Low] Test widget état erreur ajouté.
- [x] [AI-Review][Low] Message erreur utilisateur via _userFriendlyErrorMessage.
- d’intégration listInvestigations exécutables en CI (mock serveur ou test unitaire du resolver) ou documenter l’étape CI avec serveur.
 pour l’état erreur de l’écran liste.
- [x] [AI-Review][Low] En cas d’erreur API, n’afficher qu’un message utilisateur (sans stack / détail technique).

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
