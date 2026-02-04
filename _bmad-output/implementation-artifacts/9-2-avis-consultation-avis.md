# Story 9.2: Avis et consultation des avis (V1.0+)

**Story ID:** 9.2  
**Epic:** 9 – User Feedback & Ratings  
**Story Key:** 9-2-avis-consultation-avis  
**Status:** ready-for-dev  
**Depends on:** Story 9.1  
**Parallelizable with:** Story 5.2, Story 6.2, Story 8.2  
**Lane:** C  
**FR:** FR93, FR94  

---

## Story

As a **utilisateur**,  
I want **écrire un avis sur une enquête et consulter les notes et avis des autres utilisateurs**,  
So that **je puisse choisir mes prochaines enquêtes en connaissance de cause**.

---

## Acceptance Criteria

1. **Given** l'utilisateur a complété une enquête (ou consulte une enquête)  
   **When** il écrit un avis ou consulte les avis  
   **Then** il peut soumettre un avis texte (FR93)  
   **And** les notes et avis des autres utilisateurs sont visibles (FR94)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Backend : avis texte et agrégat notes/avis
  - [ ] 1.1 Backend : table ex. `investigation_reviews` (user_id, investigation_id, review_text, created_at) ; contrainte unicité (user_id, investigation_id) pour un avis par utilisateur et par enquête ; migration sqlx (FR93).
  - [ ] 1.2 Backend : mutation `submitReview(investigationId, reviewText)` protégée par JWT ; vérifier que l’utilisateur a complété l’enquête (comme en 9.1) ; validation du texte (longueur min/max, caractères autorisés) (FR93).
  - [ ] 1.3 Backend : query ex. `getInvestigationRatingsAndReviews(investigationId)` retournant : note moyenne (et nombre de notes) issue de `investigation_ratings` (9.1), liste des avis (texte, auteur anonymisé ou pseudo, date) ; pagination ou limite pour la liste des avis (FR94).
  - [ ] 1.4 Schéma GraphQL : types nommés ex. `InvestigationReviewsSummary` (averageRating, totalRatings, reviews), `Review` (reviewText, authorDisplayName ou anonyme, createdAt) ; champs camelCase (FR93, FR94).
- [ ] **Task 2** (AC1) – Soumission d’avis (Flutter)
  - [ ] 2.1 Flutter : après complétion d’une enquête ou depuis l’écran détail/historique, permettre d’écrire un avis texte (champ texte multiligne) ; soumission via mutation `submitReview` ; une seule soumission par enquête (mise à jour possible si défini) (FR93).
  - [ ] 2.2 Affichage « Vous avez déjà laissé un avis » si l’utilisateur a déjà soumis ; option « Modifier mon avis » si backend le supporte (FR93).
  - [ ] 2.3 Validation côté UI (longueur) et affichage des erreurs renvoyées par l’API (backend = source de vérité) (FR93).
- [ ] **Task 3** (AC1) – Consultation des notes et avis (FR94)
  - [ ] 3.1 Flutter : sur l’écran détail d’une enquête (2.1) ou écran dédié, afficher la note moyenne et le nombre de notes (données 9.1 agrégées) ; afficher la liste des avis (texte, auteur si exposé, date) (FR94).
  - [ ] 3.2 Charger les données via query `getInvestigationRatingsAndReviews` ; AsyncValue pour chargement/erreur ; liste scrollable ou paginée (FR94).
  - [ ] 3.3 Design : cohérent avec le design system ; lisibilité des avis (typographie, séparation) (FR94).
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d’intégration pour submitReview (complété → succès ; non complété → refus) ; test getInvestigationRatingsAndReviews (agrégat + liste avis) (FR93, FR94).
  - [ ] 4.2 Flutter : tests widget pour l’affichage note moyenne et liste avis ; pour le formulaire de soumission d’avis (mock API) (FR93, FR94).
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 9.1, 2.1.
  - [ ] 4.4 Accessibilité : labels pour zone de texte avis, note moyenne, liste avis (WCAG 2.1 Level A). Modération : définir si les avis sont modérés (hors scope MVP acceptable).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 9.2 = avis texte (FR93) + consultation notes et avis (FR94).** S’appuie sur 9.1 (notes déjà stockées dans `investigation_ratings`). On ajoute les avis texte et une query qui agrège notes + avis pour l’affichage sur la fiche enquête.
- **Anonymat / affichage auteur** : décider si les avis affichent un pseudo, « Utilisateur » anonyme, ou user_id ; documenter dans le schéma (authorDisplayName ou équivalent).
- **Modération** : pour le MVP, pas obligatoire ; prévoir une longueur max et des règles de contenu (validator) pour limiter les abus.

### Project Structure Notes

- **Flutter** : écran détail enquête (2.1) étendu avec section « Notes et avis » ; formulaire d’avis (modal ou écran) depuis détail ou après complétion. Feature `lib/features/investigation/` ou `lib/features/feedback/` ; GraphQL `get_investigation_ratings_and_reviews.graphql`, `submit_review.graphql`.
- **Backend** : table `investigation_reviews` ; `src/services/rating_service.rs` ou `review_service.rs` (submit_review, get_ratings_and_reviews) ; query dans `src/api/graphql/queries.rs` ; agrégation des notes (9.1) + liste des avis (FR93, FR94).
- [Source: architecture.md § Requirements to Structure Mapping – User Feedback]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 9, Story 9.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – Project Structure, User Feedback]
- [Source: _bmad-output/project-context.md – Technology Stack]
- [Source: Stories 9.1 (notation), 2.1 (détail enquête)]

---

## Architecture Compliance

| Règle | Application pour 9.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | Section notes/avis sur détail enquête ; formulaire avis ; feature investigation ou feedback |
| Structure Backend | Table investigation_reviews ; service review/rating ; query getInvestigationRatingsAndReviews |
| API GraphQL | Types nommés (InvestigationReviewsSummary, Review) ; mutation submitReview ; champs camelCase |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels avis et liste |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, graphql_flutter déjà en place. Aucune nouvelle dépendance obligatoire.
- **Backend** : sqlx pour persistance ; validator pour longueur/contenu de l’avis ; pas de nouvelle dépendance (FR93, FR94).
- [Source: architecture.md – User Feedback]

---

## File Structure Requirements

- **Flutter** : extension de l’écran détail enquête (2.1) ou composant `ratings_and_reviews_section.dart` ; formulaire `review_form.dart` ou équivalent. Fichiers GraphQL dans `lib/features/investigation/graphql/` ou `lib/features/feedback/`.
- **Backend** : migration pour `investigation_reviews` ; `src/services/review_service.rs` (ou extension rating_service) ; `src/api/graphql/mutations.rs` (submitReview), queries (getInvestigationRatingsAndReviews) ; agrégation des notes depuis `investigation_ratings` (9.1).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test submitReview (avec/sans complétion) ; test getInvestigationRatingsAndReviews (moyenne correcte, liste des avis).
- **Flutter** : Tests widget pour section notes/avis et formulaire d’avis (mocks) ; pas de régression sur 9.1, 2.1.
- **Qualité** : `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 9.1)

- **9.1** fournit les notes (table `investigation_ratings`, mutation submitRating). En 9.2 on réutilise ces données pour afficher la note moyenne et le nombre de notes dans la query getInvestigationRatingsAndReviews ; on ajoute les avis texte (table `investigation_reviews`, mutation submitReview) et leur affichage.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **FR93** : Un avis texte par utilisateur et par enquête (après complétion). **FR94** : Notes et avis des autres visibles sur la fiche enquête pour aider au choix.

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
