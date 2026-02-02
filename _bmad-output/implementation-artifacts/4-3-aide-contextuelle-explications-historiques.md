# Story 4.3: Aide contextuelle et explications historiques

**Story ID:** 4.3  
**Epic:** 4 – Énigmes & Content  
**Story Key:** 4-3-aide-contextuelle-explications-historiques  
**Status:** ready-for-dev  
**Depends on:** Story 4.1  
**Parallelizable with:** —  
**Lane:** B  
**FR:** FR30, FR31, FR32, FR36, FR37, FR38  

---

## Story

As a **utilisateur**,  
I want **accéder à une aide contextuelle (indices progressifs) si je suis bloqué, et voir les explications historiques après résolution**,  
So that **je puisse avancer tout en apprenant**.

---

## Acceptance Criteria

1. **Given** l'utilisateur est sur une énigme (éventuellement bloqué)  
   **When** il demande de l'aide (bouton ou après inactivité)  
   **Then** des indices progressifs (suggestion → indice → solution) sont proposés (FR30)  
   **And** après résolution, les explications historiques et le contenu éducatif sont affichés (FR31, FR32, FR36–FR38)

---

## Tasks / Subtasks

- [ ] **Task 1** (AC1) – Aide contextuelle : indices progressifs
  - [ ] 1.1 Sur chaque écran énigme (4.1, 4.2), ajouter un bouton « Aide » (ou icône) ; optionnel : proposer l'aide après une durée d'inactivité (ex. 2–3 min) (FR30).
  - [ ] 1.2 Indices progressifs : niveau 1 = suggestion légère, niveau 2 = indice plus direct, niveau 3 = solution. L'utilisateur débloque le niveau suivant à chaque demande (suggestion → indice → solution) (FR30).
  - [ ] 1.3 Backend : exposer les indices par énigme (ex. query `getEnigmaHints(enigmaId)` ou champs `hints` sur le type Enigma : `suggestion`, `hint`, `solution`). Données stockées en DB ou en dur selon contenu (FR30).
  - [ ] 1.4 Flutter : afficher l'indice courant dans un panneau, modal ou zone dédiée ; bouton « Voir l'indice suivant » jusqu'à la solution (FR30).
- [ ] **Task 2** (AC1) – Explications historiques et contenu éducatif après résolution
  - [ ] 2.1 Après validation réussie d'une énigme (4.1, 4.2), afficher un écran ou panneau « Explications » : texte historique, contenu éducatif sur le lieu ou le thème de l'énigme (FR31, FR32, FR36–FR38).
  - [ ] 2.2 Backend : exposer le contenu par énigme (ex. champs `historicalExplanation`, `educationalContent` sur le type Enigma, ou query `getEnigmaExplanation(enigmaId)`). Données en DB ou assets selon contenu (FR31, FR32).
  - [ ] 2.3 Flutter : après le retour « validé » de la mutation de validation, afficher l'explication (écran dédié ou panneau) avec option « Continuer » vers l'énigme suivante (FR31, FR32).
  - [ ] 2.4 Design : design system « carnet de détective » ; contenu lisible (contraste, accessibilité WCAG 2.1 Level A) ; photos/contexte historique des lieux si disponible (FR37).
- [ ] **Task 3** (AC1) – Intégration écran enquête
  - [ ] 3.1 Réutiliser les écrans énigme existants (4.1, 4.2) ; ajouter le bouton Aide et le flux indices sans casser la validation ni la navigation (FR30).
  - [ ] 3.2 Insérer l'étape « Explications » entre validation réussie et passage à l'énigme suivante (ou fin d'enquête) ; pas de bypass obligatoire (l'utilisateur peut « Continuer » pour avancer) (FR31, FR32).
- [ ] **Task 4** – Qualité et conformité
  - [ ] 4.1 Backend : test d'intégration pour la query/champs indices et explications (ex. `tests/api/enigmas_test.rs`) – au moins un cas nominal (FR30, FR31).
  - [ ] 4.2 Flutter : tests widget pour affichage bouton Aide, déroulement des indices (suggestion → indice → solution), et affichage explications après résolution ; mocker API (FR30, FR31).
  - [ ] 4.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 4.1, 4.2.
  - [ ] 4.4 Accessibilité : labels pour bouton Aide et zones explications (WCAG 2.1 Level A).

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 4.3 = aide + explications.** S'appuie sur 4.1 (énigmes photo/géo, validation, flux) et 4.2 (énigmes mots/puzzle). Pas de nouveau type d'énigme : on enrichit les écrans énigme existants avec (1) bouton Aide + indices progressifs, (2) écran/panneau explications après résolution.
- **Flutter** : Réutiliser `lib/features/enigma/` et les types (photo, geolocation, words, puzzle) ; ajouter un widget ou écran partagé pour les indices (bouton Aide, affichage indices) et pour les explications (affichage après validation). Riverpod pour l'état « indice courant », « explication affichée ».
- **Backend** : Schéma GraphQL étendu pour indices et explications (champs sur Enigma ou queries dédiées). Pas de mutation supplémentaire pour la validation ; uniquement lecture des indices et du contenu éducatif.

### Project Structure Notes

- **Flutter** : `lib/features/enigma/` – widget partagé `enigma_help_button.dart` ou `enigma_hints_panel.dart` ; widget ou écran `enigma_explanation_screen.dart` (ou `enigma_explanation_panel.dart`) pour les explications après résolution. Réutiliser les écrans par type (4.1, 4.2) ; intégrer le bouton Aide et le flux explications dans le flux commun (après validation).
- **Backend** : `src/services/enigma_service.rs` (ou modules) : lecture indices et explications par énigme ; `src/api/graphql/queries.rs` (ex. `getEnigmaHints`, `getEnigmaExplanation` ou champs sur `Enigma`). Tables : champs ou table liée pour `hints` (suggestion, hint, solution) et `historical_explanation`, `educational_content` par énigme.
- [Source: architecture.md § Énigme Resolution & Validation, Content & LORE]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 4, Story 4.3]
- [Source: _bmad-output/planning-artifacts/architecture.md – Enigma types, GraphQL]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md – Aide progressive, design]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 4.3 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/enigma/` (widgets partagés aide + explications) ; réutilisation des types 4.1, 4.2 |
| Structure Backend | `src/services/enigma_service.rs`, `src/api/graphql/queries.rs` (indices, explications) |
| État Flutter | `AsyncValue` pour chargement indices/explications ; pas de booléen `isLoading` séparé |
| API GraphQL | Champs ou queries pour indices et explications ; pas de mutation pour l'aide (lecture seule) |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour Aide et explications |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Pas de nouvelle dépendance obligatoire pour 4.3 (affichage texte, boutons, panneaux = widgets Flutter standard).
- **Backend** : Pas de nouvelle dépendance obligatoire ; stockage texte (indices, explications) en DB (colonnes ou table liée).
- [Source: architecture.md – Enigma types]

---

## File Structure Requirements

- **Flutter** : `lib/features/enigma/widgets/enigma_help_button.dart` (ou `enigma_hints_panel.dart`) ; `lib/features/enigma/screens/enigma_explanation_screen.dart` (ou panneau). Fichiers GraphQL : query `getEnigmaHints`, `getEnigmaExplanation` ou champs sur `Enigma` dans les queries existantes.
- **Backend** : Résolveurs GraphQL pour indices et explications ; champs en base par énigme (ex. `enigmas.hint_suggestion`, `hint_hint`, `hint_solution`, `historical_explanation`, `educational_content` ou table `enigma_content`).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour la lecture des indices et explications par énigme (ex. `tests/api/enigmas_test.rs`) – au moins un cas nominal (FR30, FR31).
- **Flutter** : Tests widget pour bouton Aide, affichage des indices (niveaux 1–3), et affichage des explications après résolution ; mocker les queries GraphQL (FR30, FR31).
- **Qualité** : Pas de régression sur 4.1, 4.2 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 4.1, 4.2)

- **Écrans énigme** : 4.1 (photo, géo) et 4.2 (mots, puzzle) fournissent les écrans par type et le flux validation → feedback → énigme suivante. En 4.3, ajouter sur chaque écran énigme un bouton « Aide » et le panneau indices ; insérer l'écran/panneau explications **après** le retour « validé » et **avant** le passage à l'énigme suivante.
- **Ne pas dupliquer** : un seul widget/panneau d'indices et un seul écran/panneau d'explications réutilisables pour tous les types d'énigmes ; le contenu (indices, explications) vient du backend par énigme.
- **Validation** : Ne pas modifier la mutation de validation (4.1, 4.2) ; uniquement ajouter l'affichage des explications côté Flutter après réception du succès.

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **UX** : Aide progressive (suggestion → indice → solution) ; contenu éducatif et historique aligné avec le design system « carnet de détective » (ux-design-specification).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
