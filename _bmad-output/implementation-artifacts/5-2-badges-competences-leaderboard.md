# Story 5.2: Badges, compétences et leaderboard (V1.0+)

**Story ID:** 5.2  
**Epic:** 5 – Progression & Gamification  
**Story Key:** 5-2-badges-competences-leaderboard  
**Status:** done  
**Depends on:** Story 5.1  
**Parallelizable with:** Story 6.2, Story 8.2, Story 9.2  
**Lane:** B  
**FR:** FR42, FR43, FR44, FR45  
**Note:** V1.0+ – gamification avancée ; peut être implémentée avec structure minimale et données mock si priorité MVP.

---

## Story

As a **utilisateur**,  
I want **voir mes badges et accomplissements, ma progression de compétences détective, les cartes postales virtuelles et le classement leaderboard**,  
So that **je sois motivé à progresser**.

---

## Acceptance Criteria

1. **Given** l'utilisateur a débloqué des accomplissements (V1.0+)  
   **When** il consulte la section gamification  
   **Then** badges, compétences détective, cartes postales et leaderboard sont visibles (FR42–FR45)

---

## Tasks / Subtasks

- [x] **Task 1** (AC1) – Badges et accomplissements
  - [x] 1.1 Afficher les badges débloqués par l'utilisateur (ex. « Première enquête », « 5 énigmes résolues », « Ville explorée ») (FR42).
  - [x] 1.2 Backend : exposer les badges par utilisateur (ex. query `getUserBadges(userId)` ou champs sur `UserProgress` : liste de badge_ids ou équivalent). Données : définition des badges (critères, icône, libellé) ; déblocage basé sur la progression (enquêtes complétées, énigmes résolues, etc.) (FR42).
  - [x] 1.3 Flutter : section « Badges » ou « Accomplissements » sur l'écran profil/gamification (5.1) ; grille ou liste des badges (débloqués visibles, non débloqués en grisé ou cachés selon UX) (FR42).
- [x] **Task 2** (AC1) – Progression de compétences détective
  - [x] 2.1 Afficher la progression des compétences détective (ex. niveaux, barres de progression par compétence : exploration, résolution, rapidité, etc.) (FR43).
  - [x] 2.2 Backend : exposer les compétences par utilisateur (ex. query `getUserSkills(userId)` ou champs sur `UserProgress` : niveau, XP ou équivalent). Règles de progression dérivées de la progression (énigmes résolues, enquêtes complétées) (FR43).
  - [x] 2.3 Flutter : section « Compétences » sur l'écran gamification ; indicateurs visuels (barres, niveaux) (FR43).
- [x] **Task 3** (AC1) – Cartes postales virtuelles
  - [x] 3.1 Afficher les cartes postales virtuelles collectées (lieux découverts pendant les enquêtes) (FR44).
  - [x] 3.2 Backend : exposer les cartes postales par utilisateur (ex. query `getUserPostcards(userId)` ou champs sur `UserProgress` : liste de lieux/énigmes « découverts »). Données : image, lieu, date de déblocage (FR44).
  - [x] 3.3 Flutter : section « Cartes postales » sur l'écran gamification ; galerie ou grille (débloquées avec image, non débloquées placeholder) (FR44).
- [x] **Task 4** (AC1) – Leaderboard
  - [x] 4.1 Afficher le classement leaderboard (ex. par enquête, global : score ou temps ou nombre d'énigmes) (FR45).
  - [x] 4.2 Backend : exposer le leaderboard (ex. query `getLeaderboard(investigationId?)` ou `getGlobalLeaderboard()` : liste utilisateurs avec score/rang). Données : agrégation des scores ou métriques (complétions, temps, etc.) (FR45).
  - [x] 4.3 Flutter : section « Leaderboard » sur l'écran gamification ; liste ou tableau (rang, pseudo ou userId, score) ; position de l'utilisateur mise en évidence (FR45).
- [x] **Task 5** (AC1) – Section gamification et navigation
  - [x] 5.1 Créer une section « Gamification » ou « Accomplissements » accessible depuis le profil/progression (5.1) : onglet, sous-écran ou route ex. `/profile/gamification` (FR42–FR45).
  - [x] 5.2 Regrouper badges, compétences, cartes postales et leaderboard sur cet écran ; design system « carnet de détective » ; accessibilité WCAG 2.1 Level A (FR42–FR45).
- [x] **Task 6** – Qualité et conformité
  - [x] 6.1 Backend : test d'intégration pour les queries badges, compétences, cartes postales, leaderboard si implémentées (ex. `tests/api/gamification_test.rs` ou équivalent) – au moins un cas nominal (FR42–FR45).
  - [x] 6.2 Flutter : tests widget pour l'écran gamification (présence sections badges, compétences, cartes postales, leaderboard) ; mocker API (FR42–FR45).
  - [x] 6.3 `dart analyze`, `flutter test`, `cargo test`, `clippy` verts ; pas de régression sur 5.1.
  - [x] 6.4 Accessibilité : labels pour badges, compétences, cartes postales, leaderboard (WCAG 2.1 Level A).

  - **Review Follow-ups (AI)** (code review 2026-02-03 – corrigés automatiquement)
  - [x] [AI-Review][HIGH] Mettre en évidence la position de l'utilisateur dans le leaderboard (Task 4.3 / FR45) [gamification_screen.dart : _LeaderboardSection]
  - [x] [AI-Review][MEDIUM] Tests widget : assertions pour sections « Cartes postales » et « Classement » [gamification_screen_test.dart]
  - [x] [AI-Review][MEDIUM] Gestion d'erreur : message + Réessayer pour Compétences, Cartes postales, Leaderboard [gamification_screen.dart]
  - [x] [AI-Review][LOW] Supprimer ou utiliser le type `Badge` (code mort) [gamification.rs]
  - [x] [AI-Review][LOW] IDs mock postcards fixes (Uuid::new_v4 → constantes) [gamification_service.rs]
  - [x] [AI-Review][LOW] Semantics par ligne leaderboard pour accessibilité [gamification_screen.dart]

  - **Review Follow-ups (AI) – second passage** (2026-02-03)
  - [x] [AI-Review][MEDIUM] Semantics (label + button: true) sur bouton Réessayer dans _SectionError [gamification_screen.dart]
  - [x] [AI-Review][MEDIUM] loadingBuilder / errorBuilder (ou placeholder) pour Image.network dans _PostcardsSection [gamification_screen.dart]
  - [x] [AI-Review][MEDIUM] Test widget : cas leaderboard « Vous » + assertion mise en évidence / sémantique [gamification_screen_test.dart]
  - [x] [AI-Review][LOW] Mock leaderboard : UUID fixes pour rangs 1 et 2 [gamification_service.rs]
  - [x] [AI-Review][LOW] Semantics régional sur _SectionError [gamification_screen.dart]
  - [x] [AI-Review][LOW] Commentaire module gamification.rs (FR42–FR45) [gamification.rs]

---

## Dev Notes

- **Implémentation alignée avec project-context et architecture.**  
  Références obligatoires : `_bmad-output/project-context.md`, `_bmad-output/planning-artifacts/architecture.md`. Les AC ne doivent pas contredire l'architecture.
- **Story 5.2 = gamification avancée (V1.0+).** S'appuie sur 5.1 (écran profil/progression). Badges, compétences, cartes postales et leaderboard (FR42–FR45) peuvent être implémentés avec une structure minimale : modèles backend, queries GraphQL, écran Flutter avec sections ; données mock ou dérivées de la progression (5.1, 4.1, 4.2) pour le MVP/V1.0.
- **Flutter** : Feature `lib/features/profile/` (architecture) ; écran ou section « Gamification » (badges, compétences, cartes postales, leaderboard). Réutiliser l'écran profil/progression (5.1) ; ajouter onglet ou route gamification (FR42–FR45).
- **Backend** : Modèles et queries pour badges, compétences, cartes postales, leaderboard ; règles de déblocage basées sur la progression (enquêtes complétées, énigmes résolues). Peut être simplifié pour V1.0 (ex. badges basés sur completed_investigation_count, leaderboard sur liste fictive ou agrégation minimale).

### Project Structure Notes

- **Flutter** : `lib/features/profile/screens/gamification_screen.dart` (ou section dans `profile_screen.dart`) ; providers pour badges, compétences, cartes postales, leaderboard. Route ex. `/profile/gamification` dans `lib/core/router/app_router.dart` (FR42–FR45).
- **Backend** : `src/services/gamification_service.rs` ou extension `user_service` ; queries GraphQL `getUserBadges`, `getUserSkills`, `getUserPostcards`, `getLeaderboard`. Tables : `badges`, `user_badges`, `user_skills`, `user_postcards`, `leaderboard_entries` ou équivalent (FR42–FR45).
- [Source: architecture.md § Progression & Gamification, profile/]

### References

- [Source: _bmad-output/planning-artifacts/epics.md – Epic 5, Story 5.2]
- [Source: _bmad-output/planning-artifacts/architecture.md – profile/, Progression]
- [Source: _bmad-output/project-context.md – Technology Stack]

---

## Architecture Compliance

| Règle | Application pour 5.2 |
|-------|----------------------|
| Nommage Dart | Classes `PascalCase`, fichiers `snake_case.dart`, variables/fonctions `camelCase` |
| Nommage Rust | Types `PascalCase`, fichiers `snake_case.rs`, fonctions/variables `snake_case` |
| Structure Flutter | `lib/features/profile/` (screens gamification, providers) ; route `/profile/gamification` |
| Structure Backend | `src/services/` (gamification_service ou user_service) ; queries GraphQL getUserBadges, getLeaderboard, etc. |
| État Flutter | `AsyncValue` pour chargement badges, compétences, cartes postales, leaderboard ; pas de booléen `isLoading` séparé |
| API GraphQL | Queries pour gamification ; champs camelCase ; IDs opaques (FR42–FR45) |
| Quality gates | `dart analyze`, `flutter test`, `cargo test`, `clippy` |
| Accessibilité | WCAG 2.1 Level A ; labels pour sections gamification |

---

## Library / Framework Requirements

- **Flutter** : Riverpod, GoRouter, graphql_flutter déjà en place. Pas de nouvelle dépendance obligatoire pour 5.2 (affichage grilles, listes, barres de progression = widgets Flutter standard).
- **Backend** : Pas de nouvelle dépendance obligatoire ; agrégations et règles métier en Rust (FR42–FR45).
- [Source: architecture.md – profile/, Progression]

---

## File Structure Requirements

- **Flutter** : `lib/features/profile/screens/gamification_screen.dart` ; `lib/features/profile/providers/` (badges_provider, skills_provider, postcards_provider, leaderboard_provider) ; route dans `lib/core/router/app_router.dart`. Fichiers GraphQL : queries `getUserBadges`, `getUserSkills`, `getUserPostcards`, `getLeaderboard`.
- **Backend** : `src/services/gamification_service.rs` (ou modules badges, skills, postcards, leaderboard) ; `src/api/graphql/queries.rs`. Migrations sqlx si tables badges, user_badges, user_skills, user_postcards, leaderboard_entries (FR42–FR45).
- [Source: architecture.md § Project Structure & Boundaries]

---

## Testing Requirements

- **Backend** : Tests d'intégration pour les queries gamification (badges, compétences, cartes postales, leaderboard) si implémentées (ex. `tests/api/gamification_test.rs`) – au moins un cas nominal (FR42–FR45).
- **Flutter** : Tests widget pour l'écran gamification (présence sections badges, compétences, cartes postales, leaderboard) ; mocker les queries GraphQL (FR42–FR45).
- **Qualité** : Pas de régression sur 5.1 ; `flutter test` et `cargo test` verts.
- [Source: architecture.md – Testing Strategy]

---

## Previous Story Intelligence (Story 5.1)

- **Écran profil/progression** : 5.1 fournit l'écran avec statut par enquête, progression globale, historique complété. En 5.2, ajouter un accès à la section « Gamification » (onglet, bouton ou route `/profile/gamification`) et afficher badges, compétences, cartes postales, leaderboard (FR42–FR45).
- **Données** : Réutiliser la progression (5.1, Hive/API) pour dériver les déblocages (badges basés sur enquêtes complétées, énigmes résolues ; compétences sur même logique ; cartes postales sur lieux/énigmes découverts ; leaderboard sur agrégation scores ou métriques) (FR42–FR45).
- **Ne pas dupliquer** : un seul écran gamification ; une seule source pour les règles de déblocage (backend ou logique partagée).

---

## Project Context Reference

- **Référence canonique** : `_bmad-output/project-context.md` et `_bmad-output/planning-artifacts/architecture.md`.
- **V1.0+** : Story marquée V1.0+ dans les epics ; implémentation possible avec structure minimale et données mock pour livraison progressive (FR42–FR45).

---

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

- Implémentation complète Story 5.2 (FR42–FR45). Backend : GamificationService avec données mock pour getUserBadges, getUserSkills, getUserPostcards, getLeaderboard. GraphQL : queries protégées (token). Flutter : écran Gamification (badges en grille, compétences avec barres de progression, cartes postales en grille, leaderboard en liste), route /profile/gamification, lien depuis écran progression. Tests : gamification_test.rs (4 tests), gamification_screen_test.dart (sections + accessibilité). Accessibilité : Semantics/labels sur toutes les sections.
- Correctifs code review second passage (2026-02-03) : _SectionError avec Semantics régional + Semantics sur bouton Réessayer ; Image.network avec loadingBuilder/errorBuilder ; test leaderboard « Vous » (présence ligne + score) ; mock leaderboard UUID fixes ; commentaire module gamification.rs FR42–FR45.

### File List

- city-detectives-api/src/models/gamification.rs (new)
- city-detectives-api/src/models/mod.rs (modified)
- city-detectives-api/src/services/gamification_service.rs (new)
- city-detectives-api/src/services/mod.rs (modified)
- city-detectives-api/src/api/graphql.rs (modified)
- city-detectives-api/src/main.rs (modified)
- city-detectives-api/src/lib.rs (modified)
- city-detectives-api/tests/api/gamification_test.rs (new)
- city-detectives-api/tests/api/enigmas_test.rs (modified)
- city-detectives-api/Cargo.toml (modified)
- city_detectives/lib/features/profile/models/user_badge.dart (new)
- city_detectives/lib/features/profile/models/user_skill.dart (new)
- city_detectives/lib/features/profile/models/user_postcard.dart (new)
- city_detectives/lib/features/profile/models/leaderboard_entry.dart (new)
- city_detectives/lib/features/profile/repositories/gamification_repository.dart (new)
- city_detectives/lib/features/profile/providers/badges_provider.dart (new)
- city_detectives/lib/features/profile/screens/gamification_screen.dart (new)
- city_detectives/lib/features/profile/screens/progression_screen.dart (modified)
- city_detectives/lib/core/router/app_router.dart (modified)
- city_detectives/test/features/profile/screens/gamification_screen_test.dart (new)
- _bmad-output/implementation-artifacts/sprint-status.yaml (modified)
- _bmad-output/implementation-artifacts/5-2-badges-competences-leaderboard.md (modified)

_(Corrections code review : gamification_screen.dart, gamification_screen_test.dart, gamification.rs, gamification_service.rs modifiés.)_  
_(Second passage : gamification_screen.dart, gamification_screen_test.dart, gamification_service.rs, gamification.rs.)_

### Change Log

- 2026-02-03 : Implémentation Story 5.2 – badges, compétences, cartes postales, leaderboard (backend + Flutter), tests, accessibilité.
- 2026-02-03 : Corrections code review – mise en évidence leaderboard (Vous), gestion erreur sections, tests Cartes postales/Classement, suppression type Badge, IDs mock postcards fixes.
- 2026-02-03 : Correctifs second passage (option 1) – Semantics _SectionError, Image.network loading/error, test leaderboard Vous, UUID fixes leaderboard mock, commentaire gamification.rs. Status → done.

---

## Senior Developer Review (AI)

**Date :** 2026-02-03  
**Reviewer :** Senior Developer (adversarial code review)  
**Outcome :** Changes Requested

### Résumé

Revue adverse effectuée sur la story 5-2-badges-competences-leaderboard. **6 problèmes identifiés** (1 HIGH, 3 MEDIUM, 2 LOW). Les critères d’acceptation sont globalement couverts, mais la tâche 4.3 (mise en évidence de la position utilisateur dans le leaderboard) n’est pas implémentée, et les tests / gestion d’erreur sont incomplets.

### Git vs File List

- Fichiers modifiés/nouveaux (git) : cohérents avec le File List de la story.
- Aucun fichier source 5.2 manquant dans le File List.

### Action Items

- [ ] **[HIGH] [Task 4.3 / FR45]** Mettre en évidence la position de l’utilisateur dans le leaderboard (sous-task 4.3). Actuellement la liste affiche rang, pseudo, score mais aucune mise en évidence visuelle de la ligne du joueur courant (fond, bordure ou champ `isCurrentUser` + style). Backend mock met "Vous" en displayName pour le rang 3 ; l’UI doit au minimum styliser cette ligne (ex. `ListTile` avec `tileColor` ou `shape` distinct). [gamification_screen.dart : _LeaderboardSection]
- [ ] **[MEDIUM] [Task 6.2]** Tests widget : ajouter des assertions pour les sections « Cartes postales » et « Classement » (ou faire défiler puis vérifier) pour satisfaire « présence sections badges, compétences, cartes postales, leaderboard ». Actuellement le test ne vérifie que Badges et Compétences. [gamification_screen_test.dart]
- [ ] **[MEDIUM]** Gestion d’erreur : en erreur API, les sections Compétences, Cartes postales et Leaderboard utilisent `SizedBox.shrink()` sans message ni bouton Réessayer. Aligner sur la section Badges (message + bouton Réessayer) ou au minimum afficher un message court. [gamification_screen.dart]
- [ ] **[LOW]** Supprimer ou utiliser le type `Badge` dans `models/gamification.rs` (actuellement défini mais jamais utilisé). [city-detectives-api/src/models/gamification.rs]
- [ ] **[LOW]** IDs mock des cartes postales : `get_user_postcards` utilise `Uuid::new_v4()` à chaque appel, les IDs changent à chaque requête. Pour un mock déterministe, utiliser des IDs fixes. [gamification_service.rs]
- [ ] **[LOW]** Accessibilité leaderboard : ajouter un `Semantics` (ou `MergeSemantics`) par ligne du classement avec un label explicite (ex. « Rang 1, Détective A, 1250 points ») pour les lecteurs d’écran. [gamification_screen.dart : _LeaderboardSection]

### Décision

**Changes Requested** – Corriger les points HIGH et MEDIUM avant de repasser en review ou de marquer la story done.

### Corrections appliquées (2026-02-03)

- **HIGH** : _LeaderboardSection – mise en évidence de la ligne « Vous » (tileColor, shape, title en gras) ; Semantics par ligne (« Rang X, Nom, Y points, c’est vous »).
- **MEDIUM** : Tests widget – scroll + assertions sur « Cartes postales », « Place du centre », « Classement ».
- **MEDIUM** : _SectionError ajouté ; Compétences, Cartes postales, Leaderboard affichent message + bouton Réessayer en erreur.
- **LOW** : Type `Badge` supprimé (gamification.rs). IDs mock postcards fixes (constantes). Semantics leaderboard déjà inclus dans le correctif HIGH.

---

## Senior Developer Review (AI) – Second passage

**Date :** 2026-02-03  
**Reviewer :** Senior Developer (adversarial code review, second pass)  
**Outcome :** Changes Requested → **Résolu** (correctifs automatiques second passage appliqués, status → done).

### Contexte

- **Story :** 5-2-badges-competences-leaderboard  
- **Git vs File List :** Les changements 5-2 ne figurent pas dans le `git diff` courant (workspace sur 6-1 ou 5-2 déjà committée). Revue effectuée sur le File List de la story.
- **Vérification des correctifs du premier passage :** Tous les 6 points précédents sont bien en place (leaderboard « Vous », _SectionError, tests Cartes postales/Classement, pas de type Badge, IDs postcards fixes, Semantics par ligne leaderboard).

### Nouveaux problèmes identifiés (second passage)

**🟡 MEDIUM**

1. **Bouton Réessayer de _SectionError sans Semantics (WCAG)**  
   Le widget _SectionError affiche un message et un FilledButton « Réessayer » mais le bouton n’a pas de `Semantics` (label + `button: true`). La section Badges utilise « Réessayer le chargement des badges » avec Semantics ; les sections Compétences, Cartes postales et Leaderboard passent par _SectionError et perdent cette annonce pour les lecteurs d’écran.  
   *Fichier :* `city_detectives/lib/features/profile/screens/gamification_screen.dart` (_SectionError, ~l.416–420).

2. **Image.network sans loading ni error**  
   _PostcardsSection utilise `Image.network(p.imageUrl!)` sans `loadingBuilder` ni `errorBuilder`. En cas d’URL lente ou invalide, l’UX est dégradée (écran vide ou erreur non gérée).  
   *Fichier :* `city_detectives/lib/features/profile/screens/gamification_screen.dart` (~l.308–311).

3. **Test widget ne couvre pas la mise en évidence « Vous » (Task 4.3)**  
   Le test gamification_screen_test mocke un leaderboard avec une seule entrée « Détective A ». Il n’y a pas de cas avec `displayName == 'Vous'` ni d’assertion sur le style (tileColor, bordure) ou la sémantique « c’est vous ». La Task 4.3 (position utilisateur mise en évidence) n’est donc pas vérifiée par les tests.  
   *Fichier :* `city_detectives/test/features/profile/screens/gamification_screen_test.dart`.

**🟢 LOW**

4. **Leaderboard mock : user_id non déterministes pour les rangs 1 et 2**  
   `get_leaderboard` utilise `Uuid::new_v4().to_string()` pour les deux premières entrées (l.101, 107). Seul le rang 3 utilise `_user_id`. Pour des tests ou snapshots reproductibles, utiliser des UUID fixes (comme pour les postcards).  
   *Fichier :* `city-detectives-api/src/services/gamification_service.rs` (~l.100–111).

5. **_SectionError : pas de Semantics sur la zone d’erreur**  
   La colonne message + bouton n’est pas enveloppée dans un Semantics décrivant la zone (ex. « Erreur : [message]. Bouton Réessayer. ») pour une annonce cohérente en one-shot.  
   *Fichier :* `city_detectives/lib/features/profile/screens/gamification_screen.dart` (_SectionError).

6. **Commentaire de module gamification.rs**  
   Le bandeau indique « Story 5.2 – FR42 » alors que le fichier couvre aussi FR43, FR44, FR45 (UserSkill, UserPostcard, LeaderboardEntry).  
   *Fichier :* `city-detectives-api/src/models/gamification.rs` (l.1).

### Action Items (second passage)

- [ ] [AI-Review][MEDIUM] Ajouter Semantics (label + button: true) sur le bouton Réessayer dans _SectionError [gamification_screen.dart]
- [ ] [AI-Review][MEDIUM] Ajouter loadingBuilder / errorBuilder (ou placeholder) pour Image.network dans _PostcardsSection [gamification_screen.dart]
- [ ] [AI-Review][MEDIUM] Test widget : ajouter un cas avec entrée leaderboard « Vous » et assertion sur mise en évidence ou sémantique « c’est vous » [gamification_screen_test.dart]
- [ ] [AI-Review][LOW] Remplacer Uuid::new_v4() par des constantes pour les rangs 1 et 2 du mock leaderboard [gamification_service.rs]
- [ ] [AI-Review][LOW] Envelopper _SectionError dans un Semantics régional (message + bouton) [gamification_screen.dart]
- [ ] [AI-Review][LOW] Mettre à jour le commentaire de module (FR42–FR45) [gamification.rs]

---

### Change Log (suite)

- **2026-02-03** – Code review second passage : 3 MEDIUM, 3 LOW. Status maintenu en review ; action items ajoutés.

---

*Ultimate context engine analysis completed – comprehensive developer guide created.*
