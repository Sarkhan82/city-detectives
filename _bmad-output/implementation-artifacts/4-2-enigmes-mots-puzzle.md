# Story 4.2: Énigmes mots et puzzle

**Story ID:** 4.2  
**Epic:** 4 – Énigmes & Content  
**Story Key:** 4-2-enigmes-mots-puzzle  
**Status:** done  
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

- [x] **Task 1** (AC1) – Backend : validation énigmes mots et puzzle
  - [x] 1.1 Schéma GraphQL : types pour énigmes mots et puzzle (ex. `WordsEnigma`, `PuzzleEnigma` ou extension de l'interface `Enigma`) ; champs : question/consigne, réponse attendue ou règle de validation (FR25, FR26).
  - [x] 1.2 Étendre la mutation de validation (ex. `validateEnigmaResponse`) pour accepter un payload texte/code : ex. `{ enigmaId, textAnswer }` ou `{ enigmaId, codeAnswer }` ; retour = validé / non validé + message (FR28, FR29).
  - [x] 1.3 Service `src/services/enigma_service.rs` : modules `enigma/words.rs`, `enigma/puzzle.rs` (ou logique dans enigma_service) ; validation mots (comparaison normalisée : minuscules, accents, espaces) ; validation puzzle (règle métier : code correct, logique, etc.) (FR25, FR26).
- [x] **Task 2** (AC1) – Flutter : énigme mots
  - [x] 2.1 Créer `lib/features/enigma/types/words/` : écran ou widget « énigme mots » (titre, consigne, champ de saisie texte) (FR25).
  - [x] 2.2 Saisie utilisateur ; envoi au backend pour validation ; affichage retour positif si validé (FR28), message explicite si erreur (FR29).
  - [x] 2.3 UX : feedback immédiat après soumission ; pas de révélation de la réponse attendue en cas d'erreur (sécurité / gameplay).
- [x] **Task 3** (AC1) – Flutter : énigme puzzle
  - [x] 3.1 Créer `lib/features/enigma/types/puzzle/` : écran ou widget « énigme puzzle » (titre, consigne, saisie code ou choix logique selon type de puzzle) (FR26).
  - [x] 3.2 Saisie utilisateur (code, sélection, etc.) ; envoi au backend pour validation ; affichage retour positif si validé (FR28), message explicite si erreur (FR29).
  - [x] 3.3 Adapter l'UI au type de puzzle (champ texte pour code, boutons pour logique, etc.) selon le schéma de l'énigme.
- [x] **Task 4** (AC1) – Intégration écran enquête
  - [x] 4.1 Depuis l'écran enquête en cours (3.1), selon le type de l'énigme courante (mots / puzzle), afficher le widget/écran correspondant (réutiliser le dispatcher ou routeur de types introduit en 4.1).
  - [x] 4.2 Après validation réussie : marquer l'énigme comme complétée, afficher retour positif, passer à l'énigme suivante (même flux que 4.1).
  - [x] 4.3 Design system « carnet de détective » ; feedback visuel riche (FR28, FR29) ; accessibilité WCAG 2.1 Level A.
- [x] **Task 5** – Qualité et conformité
  - [x] 5.1 Backend : test d'intégration pour la validation énigmes mots et puzzle (ex. `tests/api/enigmas_test.rs`) – cas validé / non validé (FR28, FR29).
  - [x] 5.2 Flutter : tests widget pour écran énigme mots (saisie, envoi, affichage résultat) et énigme puzzle (saisie, envoi, affichage résultat) ; mocker API validation.
  - [x] 5.3 `dart analyze`, `dart format`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 4.1.

- **Review Follow-ups (AI)** (code review 2026-02-03)
  - [x] [AI-Review][MEDIUM] Documenter limite MVP puzzle (code texte uniquement) ou prévoir tâche « boutons logique » (Task 3.3).
  - [x] [AI-Review][MEDIUM] Ajouter `dart format` à la quality gate 5.3 / Dev Notes et l’exécuter avant merge.
  - [x] [AI-Review][LOW] Optionnel : maxLength sur TextField words/puzzle.
  - [ ] [AI-Review][LOW] Optionnel : extension remove_accents i18n (words.rs).
  - [ ] [AI-Review][LOW] Optionnel : fakes repository surcharger autres validate*.

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 4.2 = énigmes mots et puzzle.** S'appuie sur 4.1 (structure enigma/types/, validation backend, flux validation + feedback). Ici on ajoute les types **mots** (réponse texte, ex. mot lié à la ville) et **puzzle** (code, logique) : saisie utilisateur, validation backend, même pattern de feedback (FR28, FR29).
- **Limite MVP puzzle (Task 3.3) :** En MVP, l'UI puzzle propose uniquement un champ texte pour le code. Les « boutons pour logique » ou autres variantes seront ajoutés lorsque le schéma ou les données distingueront des sous-types puzzle.
- **Quality gate (Task 5.3) :** Conformément au project-context, la qualité inclut `dart analyze`, **`dart format`**, `flutter test` (Flutter) et `cargo test`, `clippy` (Rust). Exécuter `dart format` avant merge.
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

## Change Log

- **2026-02-03** : Implémentation complète Story 4.2 – Backend : types WordsEnigma/PuzzleEnigma, payload textAnswer/codeAnswer, modules enigma/words.rs et puzzle.rs, tests d'intégration. Flutter : widgets words et puzzle, repository validateWords/validatePuzzle, dispatcher écran enquête, tests widget. Quality gates verts.
- **2026-02-03** : Code review (adversarial) – 0 High, 2 Medium, 3 Low. Changes Requested : Task 3.3 partielle (UI puzzle = code texte uniquement), quality gate 5.3 (dart format non mentionné). Statut repassé en in-progress jusqu’à traitement des points Medium ou création des follow-ups.
- **2026-02-03** : Corrections post-review : Dev Notes (limite MVP puzzle + quality gate dart format), Task 5.3 (dart format ajouté), maxLength 256 sur TextField words/puzzle, commentaire i18n words.rs, dart format exécuté. Follow-ups MEDIUM et maxLength cochés. Statut → done.

---

## Senior Developer Review (AI)

**Date :** 2026-02-03  
**Outcome :** Changes Requested → **Résolu** (corrections appliquées)  
**Rapport détaillé :** `_bmad-output/implementation-artifacts/code-review-4-2-enigmes-mots-puzzle.md`

### Résumé

- **Git vs File List :** Aucune fausse déclaration ; cohérent.
- **AC :** Implémentés (validation et feedback mots/puzzle).
- **Tâches [x] :** Confirmées ; Task 3.3 partielle (voir ci‑dessous).

### Findings

| Sévérité | Description |
|----------|-------------|
| MEDIUM | Task 3.3 partielle : UI puzzle = champ texte code uniquement ; pas de « boutons pour logique ». À documenter ou étendre. |
| MEDIUM | Quality gate 5.3 : project-context exige `dart format` ; non mentionné dans la story. |
| LOW | words.rs : normalisation accents limitée au français (i18n). |
| LOW | Flutter words/puzzle : pas de `maxLength` sur les champs texte. |
| LOW | Fakes repository : autres `validate*` non surchargés (tests OK). |

(Voir **Tasks/Subtasks → Review Follow-ups (AI)** pour les actions à cocher.)

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Backend : types GraphQL WordsEnigma, PuzzleEnigma ; payload ValidateEnigmaPayload étendu avec textAnswer et codeAnswer. Modules `src/services/enigma/words.rs` et `puzzle.rs` pour validation (mots : normalisation minuscules/accents/espaces ; puzzle : comparaison code). Mocks enquête 1 ordre 1 = words (réponse « paris »), enquête 2 ordre 3 = puzzle (code « 1234 »). Tests d'intégration : validate_words_valid_when_correct_answer, validate_words_invalid_when_wrong_answer, validate_puzzle_valid_when_correct_code, validate_puzzle_invalid_when_wrong_code.
- Flutter : WordsEnigmaWidget et PuzzleEnigmaWidget (titre, consigne, TextField, bouton validation, feedback AsyncValue). Repository : validateWords(textAnswer), validatePuzzle(codeAnswer). Dispatcher dans investigation_play_screen : cases « words » et « puzzle ». Tests widget : affichage, saisie, envoi, affichage résultat (repository mocké).
- Quality gates : dart analyze, dart format, flutter test, cargo test, clippy verts ; pas de régression sur 4.1.
- Post code-review : Dev Notes (limite MVP puzzle, quality gate dart format), maxLength 256 sur words/puzzle, commentaire i18n words.rs ; follow-ups MEDIUM et maxLength cochés.

### File List

- city-detectives-api/src/models/enigma.rs (étendu : WordsEnigma, PuzzleEnigma, textAnswer, codeAnswer)
- city-detectives-api/src/services/enigma/mod.rs (nouveau)
- city-detectives-api/src/services/enigma/words.rs (nouveau)
- city-detectives-api/src/services/enigma/puzzle.rs (nouveau)
- city-detectives-api/src/services/enigma_service.rs (étendu : words, puzzle, EnigmaDef expected_text_answer, expected_code_answer)
- city-detectives-api/src/services/mod.rs (pub mod enigma)
- city-detectives-api/tests/api/enigmas_test.rs (tests words/puzzle)
- city_detectives/lib/features/enigma/repositories/enigma_validation_repository.dart (validateWords, validatePuzzle)
- city_detectives/lib/features/enigma/types/words/words_enigma_widget.dart (nouveau)
- city_detectives/lib/features/enigma/types/puzzle/puzzle_enigma_widget.dart (nouveau)
- city_detectives/lib/features/investigation/screens/investigation_play_screen.dart (cases words, puzzle)
- city_detectives/test/features/enigma/types/words/words_enigma_widget_test.dart (nouveau)
- city_detectives/test/features/enigma/types/puzzle/puzzle_enigma_widget_test.dart (nouveau)
- city_detectives/lib/features/enigma/types/words/words_enigma_widget.dart (maxLength 256 post-review)
- city_detectives/lib/features/enigma/types/puzzle/puzzle_enigma_widget.dart (maxLength 256 post-review)
- city-detectives-api/src/services/enigma/words.rs (commentaire i18n post-review)
- _bmad-output/implementation-artifacts/sprint-status.yaml (4-2 → in-progress puis review puis done)

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
