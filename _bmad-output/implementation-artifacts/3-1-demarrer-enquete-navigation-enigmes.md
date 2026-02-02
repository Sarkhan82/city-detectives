# Story 3.1: Démarrer une enquête et navigation entre énigmes

**Story ID:** 3.1  
**Epic:** 3 – Core Gameplay & Navigation  
**Story Key:** 3-1-demarrer-enquete-navigation-enigmes  
**Status:** done  
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

- [x] **Task 1** (AC1) – Backend : enquête + liste ordonnée d'énigmes
  - [x] 1.1 Query GraphQL (ex. `getInvestigationById` ou `investigation(id)`) avec liste d'énigmes ordonnée (id, ordre, type, titre/description minimale pour affichage)
  - [x] 1.2 Modèle/table énigmes si pas déjà présent (ex. `enigmas` avec `investigation_id`, `order_index`) ; résolution dans `investigation_service` ou `enigma_service`
  - [x] 1.3 Pas de « session » persistante obligatoire pour 3.1 : le client peut recharger l'enquête + énigmes ; Story 3.3 ajoutera sauvegarde/progression
- [x] **Task 2** (AC1) – Flutter : écran enquête en cours et navigation énigmes
  - [x] 2.1 Depuis l'écran liste/détail (Story 2.2), CTA « Démarrer » → naviguer vers écran « enquête en cours » (ex. route `/investigations/:id/play` ou `/investigation/:id/enigmas`)
  - [x] 2.2 Charger l'enquête + liste ordonnée des énigmes (AsyncValue) ; afficher la première énigme ou un écran d'intro si défini (FR12)
  - [x] 2.3 Navigation entre énigmes : liste/stepper ou boutons Suivant / Précédent ; l'utilisateur peut passer d'une énigme à l'autre (FR13)
  - [x] 2.4 Affichage minimal par énigme pour 3.1 : titre, ordre (ex. « Énigme 1/5 »), placeholder pour le contenu (résolution réelle des énigmes = Epic 4)
- [x] **Task 3** (AC1) – Routes et état
  - [x] 3.1 Route GoRouter pour l'écran « enquête en cours » (paramètre investigation id) ; garder cohérence avec 2.2 (sélection puis démarrage)
  - [x] 3.2 Provider Riverpod pour l'état « enquête en cours » (investigation + liste énigmes + index énigme courante) ; état immuable, mise à jour via Notifier
- [x] **Task 4** – Qualité et conformité
  - [x] 4.1 Backend : test d'intégration pour la query enquête + énigmes (ex. `tests/api/investigations_test.rs` ou `enigmas_test.rs`)
  - [x] 4.2 Flutter : tests widget pour l'écran enquête (affichage première énigme ou intro, navigation suivant/précédent)
  - [x] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 2.1, 2.2
- [x] **Review Follow-ups (AI)**
  - [x] [AI-Review][MEDIUM] Ajouter un test widget pour l'état erreur de l'écran play (affichage message + bouton Retour) [investigation_play_screen_test.dart]
  - [x] [AI-Review][MEDIUM] Documenter l'absence de table DB `enigmas` et de migration sqlx (mock uniquement pour 3.1 ; prévoir pour story persistance) [Dev Notes ou architecture]

---

## Senior Developer Review (AI)

**Date :** 2026-02-02  
**Reviewer :** Senior Developer (adversarial code review)  
**Outcome :** Changes Requested  

**Résumé :** Revendications de la story vérifiées contre le code et git. AC et tâches marquées [x] sont implémentées. Plusieurs points de qualité identifiés ; 2 correctifs appliqués automatiquement.

**Corrections appliquées pendant la review :**
- **HIGH** : Risque de crash si `currentIndex >= enigmas.length` (état obsolète ou hot reload) → index clampé (`safeIndex`) et callbacks basés sur `safeIndex` [investigation_play_screen.dart].
- **MEDIUM** : Bouton Retour de l’AppBar sans `Semantics`/label pour lecteurs d’écran (WCAG 2.1 Level A) → `Semantics(label: 'Retour…', button: true)` ajouté [investigation_play_screen.dart].
- **LOW** : Duplication de phrase en fin de story → supprimée.

**Action items restants (Review Follow-ups) :** les 2 items ont été traités (test état erreur ajouté ; note Dev Notes sur mock/table `enigmas`).

**Git vs File List :** Fichiers modifiés/créés (backend + Flutter + test) correspondent à la File List de la story. Aucune revendication fausse.

### Review (2e pass – 2026-02-02)

**Outcome:** Approve  

**Vérifications :** AC1 implémenté (première énigme affichée, navigation Suivant/Précédent). Toutes les tâches et Review Follow-ups confirmés en code (safeIndex, Semantics AppBar, test état erreur, note Dev Notes mock/table). Git vs File List cohérent.

**Issues restantes (LOW – optionnel) :**
- Boutons « Retour » dans les états erreur et « Enquête introuvable » sans `Semantics(button: true, label: …)` explicite (cohérence accessibilité).
- Pas de test widget pour le cas `data == null` (enquête introuvable).
- Référence story à `queries.rs` alors que le code est dans `graphql.rs` (doc uniquement).

Aucun blocant ; story prête pour merge. Statut → **done**.

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 3.1 = premier pas du gameplay.** L'utilisateur a sélectionné une enquête (2.2) et la démarre ; il voit la première énigme (ou un écran d'intro) et peut naviguer entre les énigmes. La résolution des énigmes (photo, géo, mots, puzzle) et la progression/carte sont dans les stories suivantes (3.2, Epic 4).
- **Flutter** : Riverpod pour l'état enquête en cours (investigation + énigmes + index) ; GoRouter pour la route avec paramètre (id enquête). Design system « carnet de détective », accessibilité WCAG 2.1 Level A.
- **Backend** : GraphQL cohérent avec l'existant (types PascalCase, champs camelCase). Schéma : Investigation avec liste d'Enigma (ordre, type, champs minimaux pour affichage).
- **Backend – Données 3.1 :** Pour cette story, enquêtes et énigmes sont fournis **en mock en mémoire** (pas de table `enigmas` ni migration sqlx). La structure du modèle Enigma et de la query `investigation(id)` est prête pour une future story de persistance (ex. Story 3.3 ou dédiée) qui ajoutera la table `enigmas`, les migrations et le chargement depuis la DB.

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

- Backend : modèle Enigma, type InvestigationWithEnigmas, query GraphQL `investigation(id)` avec énigmes ordonnées ; InvestigationService avec IDs mock fixes et `get_investigation_by_id_with_enigmas`. Test in-process dans graphql.rs.
- Flutter : modèles Enigma et InvestigationWithEnigmas, repository `getInvestigationById`, providers `investigationWithEnigmasProvider` et `currentEnigmaIndexProvider`, écran InvestigationPlayScreen (chargement AsyncValue, stepper Énigme 1/N, carte énigme, Précédent/Suivant). Route `/investigations/:id/start` pointe vers InvestigationPlayScreen.
- Tests : backend `investigation_by_id_returns_investigation_with_enigmas` ; Flutter 4 tests widget (première énigme, Suivant, Précédent, loading). Tous les tests passent ; clippy et flutter test verts.

### File List

**Backend (city-detectives-api)**  
- src/models/enigma.rs (new)
- src/models/investigation.rs (modified – InvestigationWithEnigmas)
- src/models/mod.rs (modified – pub mod enigma)
- src/services/investigation_service.rs (modified – get_investigation_by_id_with_enigmas, mock IDs)
- src/api/graphql.rs (modified – query investigation(id), test)

**Flutter (city_detectives)**  
- lib/features/investigation/models/enigma.dart (new)
- lib/features/investigation/models/investigation_with_enigmas.dart (new)
- lib/features/investigation/repositories/investigation_repository.dart (modified – getInvestigationById)
- lib/features/investigation/providers/investigation_play_provider.dart (new)
- lib/features/investigation/screens/investigation_play_screen.dart (new)
- lib/core/router/app_router.dart (modified – route start → InvestigationPlayScreen)

**Tests**  
- city-detectives-api: src/api/graphql.rs (test investigation_by_id_returns_investigation_with_enigmas)
- city_detectives/test/features/investigation/screens/investigation_play_screen_test.dart (new)

### Change Log

- 2026-02-02 : Story 3.1 implémentée – Backend query investigation(id) + Enigma, Flutter écran enquête en cours (InvestigationPlayScreen), navigation Suivant/Précédent, tests backend et widget.
- 2026-02-02 : Code review (adversarial) – Correctifs : clamp index (crash), Semantics bouton Retour, suppression doublon texte. Statut → in-progress ; 2 action items [AI-Review] ajoutés.
- 2026-02-02 : Review follow-ups traités : test widget état erreur (play screen), note Dev Notes sur mock/table enigmas. Statut → review.
- 2026-02-02 : Code review 2e pass – Outcome Approve. Statut → done.

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
