# Code Review – Story 4.2 : Énigmes mots et puzzle

**Story Key:** 4-2-enigmes-mots-puzzle  
**Reviewer:** Senior Developer (adversarial)  
**Date:** 2026-02-03  
**Fichier story:** `_bmad-output/implementation-artifacts/4-2-enigmes-mots-puzzle.md`

---

## 1. Contexte et périmètre

- **Story :** 4.2 – Énigmes mots et puzzle (FR25, FR26, FR28, FR29)
- **Statut story :** review
- **Fichiers revus :** File List de la story (code source uniquement ; hors `_bmad-output/`, générés Windows)
- **Git :** changements non commités alignés avec la File List ; `city_detectives/windows/flutter/generated_*` modifiés mais exclus du périmètre (générés)

---

## 2. Validation des critères d’acceptation

| AC | Statut | Preuve |
|----|--------|--------|
| AC1 : énigme mots ou puzzle affichée → soumission → validation et feedback affichés | IMPLEMENTED | Backend : `validateEnigmaResponse` avec `textAnswer`/`codeAnswer` ; Flutter : `WordsEnigmaWidget`, `PuzzleEnigmaWidget` ; dispatcher `words`/`puzzle` ; feedback via `AsyncValue` et message API |

---

## 3. Audit des tâches marquées [x]

- **Task 1 (1.1–1.3) :** Schéma WordsEnigma/PuzzleEnigma, payload étendu, modules `enigma/words.rs` et `puzzle.rs` – confirmé dans le code.
- **Task 2 (2.1–2.3) :** Widget mots, envoi backend, feedback sans révélation de la réponse – confirmé.
- **Task 3 (3.1–3.2) :** Widget puzzle, envoi, feedback – confirmé. **3.3 partiel** : seul le champ texte pour le code est implémenté ; pas de « boutons pour logique ».
- **Task 4 (4.1–4.3) :** Dispatcher, flux complété, feedback et Semantics – confirmé.
- **Task 5 (5.1–5.3) :** Tests backend + widget, quality gates – confirmé. **5.3** : `dart format` non mentionné dans la story alors qu’exigé dans project-context.

---

## 4. Findings (adversarial)

### Discrepancies Git vs File List

- **Fichiers modifiés hors File List (exclus volontairement) :** `city_detectives/windows/flutter/generated_plugin_registrant.cc`, `generated_plugins.cmake` – générés ; pas d’ajout requis dans la File List, à garder exclus en CI si besoin.
- **Conclusion :** Aucune fausse déclaration ; File List cohérente avec le code source livré.

---

### HIGH

*Aucun.* Les AC sont implémentés, les tâches [x] correspondent au code (avec les nuances 3.3 et 5.3 en MEDIUM/LOW).

---

### MEDIUM

1. **Task 3.3 partielle – UI puzzle (3.3)**  
   **Fichier :** `city_detectives/lib/features/enigma/types/puzzle/puzzle_enigma_widget.dart`  
   La story demande d’« adapter l’UI au type de puzzle (champ texte pour code, **boutons pour logique**, etc.) selon le schéma de l’énigme ». Seul le champ texte pour le code est en place ; pas de variante « logique » avec boutons.  
   **Recommandation :** Documenter la limite (MVP = code texte uniquement) dans la story / Dev Notes, ou prévoir une évolution lorsque le schéma distinguera des sous-types puzzle.

2. **Quality gate 5.3 – dart format (5.3)**  
   **Référence :** `_bmad-output/project-context.md` exige `dart analyze` + **`dart format`** + `flutter test`. La story 5.3 ne mentionne que `dart analyze`, `flutter test`, `cargo test`, `clippy`.  
   **Recommandation :** Exécuter `dart format` avant merge et ajouter « dart format » dans la formulation de la tâche 5.3 (ou dans les Dev Notes) pour alignement avec le project-context.

---

### LOW

3. **Normalisation mots – i18n (words.rs)**  
   **Fichier :** `city-detectives-api/src/services/enigma/words.rs`  
   `remove_accents` ne gère qu’un sous-ensemble de caractères (français : àâä, éèêë, îï, ôö, ùûü, ç, œ). Caractères comme ñ, ń, etc. ne sont pas gérés.  
   **Recommandation :** Acceptable pour un MVP français ; documenter la limite ou étendre si extension i18n.

4. **Limite de saisie Flutter (words/puzzle)**  
   **Fichiers :** `words_enigma_widget.dart`, `puzzle_enigma_widget.dart`  
   Aucun `maxLength` sur les `TextField`. Risque limité (backend ne stocke pas, comparaison immédiate), mais une limite raisonnable (ex. 200–500 caractères) améliore l’UX et évite des payloads inutilement gros.  
   **Recommandation :** Ajouter `maxLength` (et éventuellement `maxLengthEnforcement`) pour cohérence et robustesse.

5. **Tests widget – fakes repository**  
   **Fichiers :** `words_enigma_widget_test.dart`, `puzzle_enigma_widget_test.dart`  
   `_FakeWordsRepository` / `_FakePuzzleRepository` ne surchargent que `validateWords` / `validatePuzzle`. Les autres méthodes (ex. `validateGeolocation`, `validatePhoto`) utilisent le client factice et échoueraient si appelées. Les tests actuels n’appellent que la méthode mockée, donc pas de régression.  
   **Recommandation :** Optionnel : surcharger les autres `validate*` pour retourner un résultat par défaut ou throw, pour isoler clairement les tests.

---

## 5. Synthèse

- **Git vs Story :** 0 écart bloquant.
- **Issues :** 0 High, 2 Medium, 3 Low.
- **AC :** Implémentés.
- **Tâches [x] :** Correspondent au code (3.3 et 5.3 partiellement couverts par les findings Medium/Low ci-dessus).

**Verdict :** **Changes Requested** – pas de blocage, mais traiter ou documenter les 2 points MEDIUM avant de passer en « done » (ou les inscrire en follow-ups si report explicite).

---

## 6. Actions recommandées

1. **MEDIUM 1 (3.3) :** Soit documenter « MVP = puzzle code texte uniquement » dans la story, soit planifier une tâche pour « boutons logique » lorsque le schéma le permettra.
2. **MEDIUM 2 (5.3) :** Exécuter `dart format` et mettre à jour la story/Dev Notes pour inclure `dart format` dans la quality gate.
3. **LOW :** À traiter selon priorité (maxLength, i18n, fakes) en backlog ou dans une story dédiée.

---

_Review effectuée selon le workflow code-review (adversarial)._
