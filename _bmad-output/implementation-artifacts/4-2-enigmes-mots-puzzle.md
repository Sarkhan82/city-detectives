# Story 4.2: Énigmes mots et puzzle

**Story ID:** 4.2  
**Epic:** 4 – Énigmes & Content  
**Story Key:** 4-2-enigmes-mots-puzzle  
**Status:** ready-for-dev  
**Depends on:** Story 4.1  
**Parallelizable with:** Story 7.4  
**Lane:** B  
**FR:** FR25, FR26, FR28, FR29  

---

## Story

As a **utilisateur**,  
I want **résoudre des énigmes à base de mots (mots liés à la ville) et des puzzles (codes, logique)**,  
So that **je puisse varier les types de défis**.

---

## Acceptance Criteria

1. **Given** une énigme mots ou puzzle est affichée  
   **When** l'utilisateur soumet la bonne réponse  
   **Then** la validation et le feedback sont affichés (FR25, FR26, FR28, FR29)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Backend : validation énigmes mots et puzzle
  - [ ] 1.1 Schéma GraphQL : types pour énigmes mots et puzzle (ex. `WordsEnigma`, `PuzzleEnigma` ou extension de l'interface `Enigma`) ; champs : question/consigne, réponse attendue ou règle de validation (FR25, FR26).
  - [ ] 1.2 Étendre la mutation de validation (ex. `validateEnigmaResponse`) pour accepter un payload texte/code : ex. `{ enigmaId, textAnswer }` ou `{ enigmaId, codeAnswer }` ; retour = validé / non validé + message (FR28, FR29).
  - [ ] 1.3 Service `src/services/enigma_service.rs` : modules `enigma/words.rs`, `enigma/puzzle.rs` (ou logique dans enigma_service) ; validation mots (comparaison normalisée : minuscules, accents, espaces) ; validation puzzle (règle métier : code correct, logique, etc.) (FR25, FR26).
- [ ] **Task 2** (AC1) – Flutter : énigme mots
  - [ ] 2.1 Créer `lib/features/enigma/types/words/` : écran ou widget « énigme mots » (titre, consigne, champ de saisie texte) (FR25).
  - [ ] 2.2 Saisie utilisateur ; envoi au backend pour validation ; affichage retour positif si validé (FR28), message explicite si erreur (FR29).
  - [ ] 2.3 UX : feedback immédiat après soumission ; pas de révélation de la réponse attendue en cas d'erreur (sécurité / gameplay).
- [ ] **Task 3** (AC1) – Flutter : énigme puzzle
  - [ ] 3.1 Créer `lib/features/enigma/types/puzzle/` : écran ou widget « énigme puzzle » (titre, consigne, saisie code ou choix logique selon type de puzzle) (FR26).
  - [ ] 3.2 Saisie utilisateur (code, sélection, etc.) ; envoi au backend pour validation ; affichage retour positif si validé (FR28), message explicite si erreur (FR29).
  - [ ] 3.3 Adapter l'UI au type de puzzle (champ texte pour code, boutons pour logique, etc.) selon le schéma de l'énigme.
- [ ] **Task 4** (AC1) – Intégration écran enquête
  - [ ] 4.1 Depuis l'écran enquête en cours (3.1), selon le type de l'énigme courante (mots / puzzle), afficher le widget/écran correspondant (réutiliser le dispatcher ou routeur de types introduit en 4.1).
  - [ ] 4.2 Après validation réussie : marquer l'énigme comme complétée, afficher retour positif, passer à l'énigme suivante (même flux que 4.1).
  - [ ] 4.3 Design system « carnet de détective » ; feedback visuel riche (FR28, FR29) ; accessibilité WCAG 2.1 Level A.
- [ ] **Task 5** – Qualité et conformité
  - [ ] 5.1 Backend : test d'intégration pour la validation énigmes mots et puzzle (ex. `tests/api/enigmas_test.rs`) – cas validé / non validé (FR28, FR29).
  - [ ] 5.2 Flutter : tests widget pour écran énigme mots (saisie, envoi, affichage résultat) et énigme puzzle (saisie, envoi, affichage résultat) ; mocker API validation.
  - [ ] 5.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 4.1.

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 4.2 = énigmes mots et puzzle.** S'appuie sur 4.1 (structure enigma/types/, validation backend, flux validation + feedback). Ici on ajoute les types **mots** (réponse texte, ex. mot lié à la ville) et **puzzle** (code, logique) : saisie utilisateur, validation backend, même pattern de feedback (FR28, FR29).
- **Flutter** : Structure par type sous `lib/features/enigma/types/words/` et `lib/features/enigma/types/puzzle/` (architecture). Réutiliser le dispatcher/routing des types d'énigmes (4.1) et la mutation `validateEnigmaResponse` (payload étendu pour texte/code).
- **Backend** : Même mutation ou variante ; validation côté serveur (source de vérité). Pas d'exposition de la réponse attendue dans les réponses API (sécurité).

### Project Structure Notes

- **Flutter** : `lib/features/enigma/types/words/` (screens, widgets) ; `lib/features/enigma/types/puzzle/` (idem). Réutiliser `lib/features/enigma/` (dispatcher types, providers, graphql) de 4.1.
- **Backend** : `src/services/enigma_service.rs` ; modules `src/services/enigma/words.rs`, `puzzle.rs` ; mutation `validateEnigmaResponse` étendue pour payload texte/code.
- [Source: architecture.md § Énigme Resolution & Validation, types words/, puzzle/]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 4, Story 4.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – Enigma types, GraphQL]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 4.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/enigma/types/words/`, `lib/features/enigma/types/puzzle/` |
| Structure Backend | `src/services/enigma_service.rs`, modules enigma/words.rs, puzzle.rs |
| État Flutter | `AsyncValue` pour envoi/resultat validation ; pas de booléen `isLoading` séparé |
| API GraphQL | Types nommés (WordsEnigma, PuzzleEnigma ou interface) ; mutation validateEnigmaResponse (payload texte/code) |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour champs de saisie et messages |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Pas de nouvelle dépendance obligatoire pour 4.2 (champs de saisie = widgets Flutter standard ou Material).
- **Backend** : Pas de nouvelle dépendance obligatoire ; validation texte (normalisation, comparaison) en Rust standard ; logique puzzle selon règles métier.
- [Source: architecture.md – Enigma types]

---

## File Structure Requirements

- **Flutter** : `lib/features/enigma/types/words/` – ex. `words_enigma_screen.dart`, `words_enigma_widget.dart` ; `lib/features/enigma/types/puzzle/` – ex. `puzzle_enigma_screen.dart`, `puzzle_enigma_widget.dart`. Fichiers GraphQL : réutiliser ou étendre la mutation de 4.1 (validateEnigmaResponse avec variables texte/code).
- **Backend** : `src/services/enigma/words.rs`, `src/services/enigma/puzzle.rs` ; résolution dans enigma_service ; schéma GraphQL étendu pour types mots et puzzle.
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour validation énigme mots (réponse correcte / incorrecte) et énigme puzzle (code correct / incorrect) (FR28, FR29).
- **Flutter** : Tests widget pour écran énigme mots (saisie, soumission, affichage résultat) et énigme puzzle (saisie, soumission, affichage résultat) ; mocker client GraphQL.
- **Qualité** : Pas de régression sur 4.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 4.1)

- **Structure enigma** : 4.1 introduit `lib/features/enigma/types/photo/` et `lib/features/enigma/types/geolocation/`, un dispatcher ou routeur qui affiche le bon type selon l'énigme courante, et la mutation `validateEnigmaResponse`. En 4.2, étendre le dispatcher pour les types mots et puzzle ; réutiliser la même mutation (payload étendu : textAnswer ou codeAnswer).
- **Flux validation** : Envoi → backend → validé / non validé + message ; affichage feedback ; marquer énigme complétée et passer à la suivante. Ne pas dupliquer ce flux ; le réutiliser pour mots et puzzle.
- **Ne pas dupliquer** : Un seul point d'entrée de validation (mutation) ; différenciation par type d'énigme côté backend (enigma_service dispatch par type).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **Validation** : Backend = source de vérité ; ne pas exposer la réponse attendue dans les réponses API (sécurité / gameplay).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
