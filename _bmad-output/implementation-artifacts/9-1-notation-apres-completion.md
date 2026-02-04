# Story 9.1: Notation après complétion

**Story ID:** 9.1  
**Epic:** 9 – User Feedback & Ratings  
**Story Key:** 9-1-notation-apres-completion  
**Status:** ready-for-dev  
**Depends on:** Story 4.1  
**Parallelizable with:** Story 5.1, Story 6.1, Story 8.1  
**Lane:** C  
**FR:** FR92  

---

## Story

As a **utilisateur**,  
I want **noter une enquête après l'avoir complétée**,  
So that **ma satisfaction soit prise en compte et visible pour les autres**.

---

## Acceptance Criteria

1. **Given** l'utilisateur a complété une enquête  
   **When** il est invité à noter (ou ouvre l'écran de notation)  
   **Then** il peut soumettre une note (FR92)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Backend : stockage et API des notes
  - [ ] 1.1 Backend : table ex. `investigation_ratings` (user_id, investigation_id, rating, created_at) ; contrainte unicité (user_id, investigation_id) pour une note par utilisateur et par enquête ; migration sqlx (FR92).
  - [ ] 1.2 Backend : mutation `submitRating(investigationId, rating)` protégée par JWT ; vérifier que l’utilisateur a bien complété l’enquête (données de progression 5.1) avant d’accepter la note ; rating : échelle à définir (ex. 1–5 étoiles, entier) (FR92).
  - [ ] 1.3 Backend : query pour récupérer la note de l’utilisateur pour une enquête (ex. `getMyRating(investigationId)` ou champs dans une query existante) pour afficher « déjà notée » ou pré-remplir (FR92).
  - [ ] 1.4 Schéma GraphQL : type ou champ de retour cohérent (ex. `Rating` ou champ `rating` sur User/Investigation) ; champs camelCase (FR92).
- [ ] **Task 2** (AC1) – Invitation à noter après complétion
  - [ ] 2.1 Flutter : à la fin d’une enquête (écran de complétion / succès), proposer « Noter cette enquête » (bouton ou bloc dédié) ; ou afficher un modal/écran de notation (FR92).
  - [ ] 2.2 Flutter : composant de notation (ex. étoiles 1–5, ou scale) ; soumission via mutation `submitRating` ; feedback succès/erreur ; AsyncValue pour l’état de soumission (FR92).
  - [ ] 2.3 Si l’utilisateur a déjà noté : afficher sa note et optionnellement « Modifier ma note » (réutiliser submitRating en mise à jour) (FR92).
- [ ] **Task 3** (AC1) – Accès depuis l’historique / profil
  - [ ] 3.1 Depuis l’écran profil ou historique des enquêtes complétées (5.1), permettre d’ouvrir la notation pour une enquête complétée non encore notée (ex. icône ou bouton « Noter ») (FR92).
  - [ ] 3.2 Réutiliser le même composant ou écran de notation que post-complétion ; cohérence UX (FR92).
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d’intégration pour submitRating (utilisateur ayant complété l’enquête → succès ; utilisateur n’ayant pas complété → erreur ou refus) ; test getMyRating (FR92).
  - [ ] 4.2 Flutter : tests widget pour le composant de notation (affichage, soumission mockée) ; pas de régression sur 5.1, 4.1 (FR92).
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts.
  - [ ] 4.4 Accessibilité : labels pour les étoiles ou la scale de notation (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l’architecture.
- **Story 9.1 = notation après complétion (FR92).** S’appuie sur 4.1 (résolution des énigmes, complétion d’enquête) et 5.1 (statut complétion, historique). L’utilisateur ne peut noter que les enquêtes qu’il a complétées ; une seule note par (user, enquête), mise à jour possible.
- **Échelle de notation** : définir en implémentation (ex. 1–5 étoiles, entier) ; cohérent entre backend (contrainte, validation) et Flutter (UI).
- **9.2** ajoutera l’affichage des notes/avis des autres (FR94) et l’écriture d’avis texte (FR93) ; en 9.1 on se limite à « soumettre une note » pour une enquête complétée.

### Project Structure Notes

- **Flutter** : écran ou modal de notation (ex. `lib/features/investigation/widgets/rating_widget.dart` ou `lib/features/feedback/`) ; intégration dans l’écran de complétion d’enquête et dans l’historique (5.1). GraphQL : mutation `submit_rating.graphql`, query `get_my_rating.graphql` si dédiée.
- **Backend** : table `investigation_ratings` ; `src/services/rating_service.rs` ou module dans `investigation_service` / `user_service` ; mutation dans `src/api/graphql/mutations.rs` ; vérification de la complétion via données de progression (FR92).
- [Source: architecture.md § Requirements to Structure Mapping – User Feedback]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 9, Story 9.1]
- [Source: _bmad-output/planning-artifacts/architecture.md – Project Structure, User Feedback]
- [Source: _bmad-output/project-context.md – Technology Stack]
- [Source: Stories 4.1, 5.1 – complétion, historique]

---

## Architecture Compliance

| Règle | Application pour 9.1 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | Feature investigation ou feedback – composant notation, intégration écran complétion et historique |
| Structure Backend | Table investigation_ratings ; service rating ; mutation submitRating |
| API GraphQL | Mutation submitRating(investigationId, rating) ; query getMyRating si besoin ; champs camelCase |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels notation |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, graphql_flutter déjà en place. Widget étoiles ou scale : custom ou package (ex. flutter_rating_bar) si aligné au design system. Aucune dépendance obligatoire imposée.
- **Backend** : sqlx pour persistance ; pas de nouvelle dépendance ; réutilisation des services de progression pour vérifier la complétion (FR92).
- [Source: architecture.md – User Feedback]

---

## File Structure Requirements

- **Flutter** : `lib/features/investigation/widgets/rating_widget.dart` (ou `lib/features/feedback/rating_screen.dart`) ; intégration dans l’écran de fin d’enquête et dans la liste historique (5.1). Fichiers GraphQL dans `lib/features/investigation/graphql/` ou `lib/core/graphql/`.
- **Backend** : migration pour `investigation_ratings` ; `src/services/rating_service.rs` (ou équivalent) ; `src/api/graphql/mutations.rs` (submitRating) ; logique de vérification complétion (query progression ou table complétions).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Test submitRating avec utilisateur ayant complété l’enquête (succès) et sans complétion (refus ou erreur) ; test getMyRating si implémentée.
- **Flutter** : Tests widget pour le composant de notation (affichage, soumission avec mock) ; pas de régression sur 5.1, 4.1.
- **Qualité** : `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Dependency Context (Story 4.1, 5.1)

- **4.1** : Résolution des énigmes et complétion d’enquête ; la « complétion » doit être détectable côté backend (ou côté Flutter avec envoi au backend) pour autoriser la notation.
- **5.1** : Historique des enquêtes complétées ; point d’entrée secondaire pour « Noter » depuis la liste des enquêtes complétées.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **FR92** : Une seule note par utilisateur et par enquête ; prise en compte après complétion. Les notes seront exposées aux autres utilisateurs en 9.2 (FR94).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
