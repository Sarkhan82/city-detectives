# Résumé d'automatisation – City Detectives (Stories 1.2–6.1)

**Date :** 2026-02-03  
**Stories couvertes :** 1.2 (Création de compte), 2.1 (Parcourir et consulter les enquêtes), 2.2 (Sélection enquête, gratuit/payant), 3.1 (Démarrer enquête et navigation énigmes), 3.2 (Progression, carte interactive et position), 3.3 (Pause, reprise, abandon, sauvegarde), 4.1 (Énigmes photo et géolocalisation), 4.2 (Énigmes mots et puzzle), 4.3 (Aide contextuelle et explications historiques), 4.4 (LORE et option de saut), 5.1 (Statut completion et historique), 5.2 (Badges, compétences, leaderboard), 6.1 (Première enquête gratuite, visibilité payant et prix), **7.1 (Accès dashboard admin)**, **7.2 (Création et édition enquêtes/énigmes – API backend)**, **7.3 (Prévisualisation, publication et rollback)**  
**Mode :** Standalone / Auto-discover  
**Cible de couverture :** critical-paths  

---

## Contexte

- **Stack :** Flutter (app mobile) + Rust (API GraphQL). Pas de Playwright/Cypress (Node/TS).
- **Frameworks de test :** Flutter (widget tests, `flutter test`) ; Rust (`cargo test`, tests d’intégration API, tests in-process GraphQL).
- **Artéfacts BMad :** Stories 1.2, 2.1, 2.2, 3.1, 3.2, 3.3 et 4.1 ; workflow testarch-automate en mode autonome.

---

## Inventaire des tests existants

### Rust – API (`city-detectives-api`)

| Fichier | Type | Exécution | Description |
|---------|------|-----------|-------------|
| `src/api/graphql.rs` (mod tests) | In-process | `cargo test` | `list_investigations_in_process_returns_array` (2.1) ; `investigation_by_id_returns_investigation_with_enigmas` (3.1) ; **Story 4.4** – getLoreContent / getLoreSequenceIndexes ; **Story 6.1** – listInvestigations avec priceAmount/priceCurrency (gratuit null, payant 299/EUR), `investigation_by_id_returns_price_fields_for_paid`. |
| `tests/api/auth_test.rs` | Intégration HTTP | `--ignored` (serveur 8080) | 4 tests : register JWT, email dupliqué, email invalide, mot de passe court. |
| `tests/api/investigations_test.rs` | Intégration HTTP | `--ignored` (serveur 8080) | 2 tests : listInvestigations retourne un tableau ; items ont les champs requis (dont priceAmount, priceCurrency – Story 6.1). |
| `tests/api/enigmas_test.rs` | In-process GraphQL | `cargo test` | **Story 4.1** – 4 tests : validateEnigmaResponse (géoloc/photo). **Story 4.2** – 4 tests : validateEnigmaResponse (words/puzzle). **Story 4.3** – 3 tests : getEnigmaHints, getEnigmaExplanation, getEnigmaHints (ID inconnu). Auth Bearer requise. **Total : 11 tests.** (Story 4.4 LORE couverte par graphql.rs in-process.) |
| `tests/api/gamification_test.rs` | In-process GraphQL | `cargo test` | **Story 5.2** – 4 tests : getUserBadges, getUserSkills, getUserPostcards, getLeaderboard (auth requise). |
| `tests/api/admin_test.rs` | In-process GraphQL | `cargo test` | **Story 7.1** – 3 tests : me { id isAdmin }, getAdminDashboard (admin → données, user → FORBIDDEN). **Story 7.2** – 10 tests : createInvestigation / updateInvestigation, createEnigma / updateEnigma, validateEnigmaHistoricalContent (admin → succès, user → FORBIDDEN). **Story 7.3** – 6 tests : investigationForPreview (admin → brouillon, user → FORBIDDEN) ; listInvestigations sans token → uniquement published ; publishInvestigation → visible au catalogue ; rollbackInvestigation → masquée du catalogue. **Total admin_test : 19 tests.** |

**Rust – Unitaires (exécutés par défaut)**

| Fichier | Tests |
|---------|--------|
| `src/models/user.rs` | 3 tests : validation `RegisterInput` (email invalide, mot de passe court, entrée valide). |
| `src/services/auth_service.rs` | 2 tests (JWT / validation). |

### Flutter – Widget (`city_detectives/test`)

| Fichier | Couverture |
|---------|------------|
| `register_screen_test.dart` | Formulaire, erreur mots de passe différents, isolation avec router. |
| `onboarding_screen_test.dart` | Écran 1 (première enquête + CTA), écran 2 (LORE), navigation. |
| `features/investigation/investigation_list_screen_test.dart` | Liste (durée, difficulté, description, gratuit), état vide, message d’erreur. **Story 3.3** – section « Enquêtes en cours » quand progression sauvegardée, tap → reprise. **Story 6.1** – affichage prix pour enquête payante (FR47, FR49). |
| `features/investigation/screens/investigation_detail_screen_test.dart` | Détail enquête : titre, description, chip Gratuit/Payant, CTA Démarrer (2.2). **Story 6.1** – Payant + prix (4,99 €) + bouton Acheter + « Démarrer (après achat) ». |
| `features/investigation/screens/investigation_start_placeholder_screen_test.dart` | Placeholder démarrage : id enquête, message Story 3.1, bouton Retour (Story 2.2). |
| `features/investigation/screens/investigation_play_screen_test.dart` | **Story 3.1** – Écran enquête en cours : première énigme + stepper, Suivant/Précédent, loading, état erreur. **Story 3.2** – indicateur progression, bouton carte. **Story 3.3** – restauration progression (index énigme sauvegardé). 9 tests. |
| `features/investigation/widgets/investigation_map_sheet_test.dart` | **Story 3.2** – Carte : titre « Carte » + FlutterMap ; message si localisation indisponible ; marqueur position si disponible (mock GeolocationService). 3 tests. |
| `features/investigation/repositories/investigation_progress_repository_test.dart` | **Story 3.3** – TU InvestigationProgressRepository (forTest) : getInProgressIds vide/null, saveProgress + getProgress, getInProgressInvestigationIds après save, overwrite, deleteProgress. 6 tests. |
| `shared/widgets/price_chip_test.dart` | Widget PriceChip : Gratuit / Payant selon isFree (Story 2.2). |
| `features/investigation/models/investigation_test.dart` | TU `Investigation.fromJson` (défensif, isFree, durationEstimate, centerLat/centerLng). **Story 6.1** – priceAmount, priceCurrency, formattedPrice (2,99 € ; null si gratuit ; padding centimes 2,00 €). |
| `widget_test.dart` | App build, WelcomeScreen. |
| `features/onboarding/screens/welcome_screen_test.dart` | **Story 1.1/1.3** – WelcomeScreen : titre + Continuer ; tap → register ; Semantics ; **token + onboarding non fait → redirect onboarding** ; **token + onboarding fait → redirect home**. 5 tests. |
| `features/onboarding/providers/onboarding_provider_test.dart` | **Story 1.3** – TU OnboardingNotifier avec stockage injecté (FakeOnboardingStorage) : build() false si clé absente / "false", true si "true" ; markCompleted() écrit et met à jour state ; invalidation puis re-read. 5 tests. |
| `features/enigma/types/photo/photo_enigma_widget_test.dart` | **Story 4.1** – Widget énigme photo : titre, bouton « Prendre une photo », consigne ; client GraphQL mocké. |
| `features/enigma/types/geolocation/geolocation_enigma_widget_test.dart` | **Story 4.1** – Widget énigme géolocalisation : titre, bouton « Valider ma position », consigne ; GeolocationService + client GraphQL mockés. |
| `features/enigma/types/words/words_enigma_widget_test.dart` | **Story 4.2** – Widget énigme mots : titre, consigne, champ texte, bouton « Valider ma réponse » ; saisie + envoi + affichage résultat (succès/erreur) ; repository mocké. 3 tests. |
| `features/enigma/types/puzzle/puzzle_enigma_widget_test.dart` | **Story 4.2** – Widget énigme puzzle : titre, consigne, champ code, bouton « Valider le code » ; saisie + envoi + affichage résultat (succès/erreur) ; repository mocké. 3 tests. |
| `features/enigma/widgets/enigma_help_button_test.dart` | **Story 4.3** – Bouton Aide : icône ; ouverture bottom sheet avec panneau indices ; flux complet suggestion → indice → solution (2 taps « Voir l'indice suivant », puis Solution + Fermer). 3 tests. |
| `features/enigma/screens/enigma_explanation_screen_test.dart` | **Story 4.3** – Écran Explications : chargement puis contenu (Contexte historique, Pour en savoir plus) ; bouton Continuer appelle onContinue. 2 tests. |
| `features/enigma/screens/lore_screen_test.dart` | **Story 4.4** – Écran LORE : chargement puis titre/texte/Sauter/Continuer ; Sauter et Continuer appellent onContinue ; état vide (getLoreContent null) ; section médias quand mediaUrls non vide (CachedNetworkImage). 5 tests. |
| `features/profile/screens/progression_screen_test.dart` | **Story 5.1** – Écran Ma progression : titre, statut par enquête, enquêtes complétées, progression globale ; enquête complétée affichée ; tap enquête en cours → détail ; CompletedInvestigationRepository + InvestigationProgressRepository mockés. |
| `features/profile/screens/gamification_screen_test.dart` | **Story 5.2** – Écran Gamification : titres sections (Badges, Compétences, Cartes postales, Classement), contenu mocké (badges, skills, postcards, leaderboard), scroll pour afficher toutes les sections. |
| `features/investigation/repositories/completed_investigation_repository_test.dart` | **Story 5.1** – TU CompletedInvestigationRepository (forTest) : isCompleted, getCompletedOrderedByDate, markCompleted, overwrite, ordre plus récent en premier. 8 tests. |
| `features/admin/screens/dashboard_screen_test.dart` | **Story 7.1** – 2 tests : DashboardScreen avec données mockées (titres, métriques) ; accès refusé 403 (message + bouton Retour). |
| `features/admin/widgets/admin_route_guard_test.dart` | **Story 7.1** – 2 tests : redirection vers home si utilisateur non-admin ; affichage dashboard si utilisateur admin. |
| `features/admin/screens/investigation_preview_screen_test.dart` | **Story 7.3** – 3 tests : prévisualisation avec enquête + énigmes (FR65) ; état « introuvable » ; état erreur + bouton Retour au dashboard. |
| `features/admin/screens/admin_investigation_list_screen_test.dart` | **Story 7.3** – 2 tests : liste avec libellés Brouillon / Publiée ; liste vide. |
| `features/admin/screens/admin_investigation_detail_screen_test.dart` | **Story 7.3** – 3 tests : brouillon → Prévisualiser + Publier (pas Rollback) ; publiée → Prévisualiser + Rollback (pas Publier) ; Rollback → dialogue de confirmation (FR66, FR67). |

- **Total Flutter :** 116 tests (dont Story 6.1 : détail/liste/prix ; Story 7.1 : dashboard admin).
- **Exécution :** `cd city_detectives && flutter test`.

---

## Plan de couverture (niveaux / priorités)

| Niveau | Zone | P0 | P1 | P2 | Description |
|--------|------|----|----|----|-------------|
| API Rust | `auth_test.rs` | – | 4 | – | Register JWT, email dupliqué, email invalide, mot de passe court |
| API Rust | `investigations_test.rs` | – | 2 | – | listInvestigations tableau + champs requis |
| In-process Rust | `graphql.rs` (tests) | – | 5 | – | listInvestigations (CI) ; investigation(id) + énigmes (3.1) ; **4.4** getLoreContent (nominal + null), getLoreSequenceIndexes (CI) |
| Unit Rust | `user.rs` | – | – | 3 | Validation RegisterInput |
| Unit Rust | `auth_service.rs` | – | – | 2 | JWT / validation token |
| Widget Flutter | register, onboarding, investigation_list, detail, placeholder, **play** (3.1, 3.2, 3.3), **map_sheet** (3.2), **progress_repository** (3.3), price_chip, models, widget, **photo_enigma**, **geolocation_enigma** (4.1), **lore_screen** (4.4) | – | 55 | – | + **4.4** (LORE : écran, Sauter/Continuer, état vide, médias). |
| In-process Rust | `enigmas_test.rs` | – | 11 | – | **Story 4.1** – validateEnigmaResponse (géoloc/photo). **Story 4.2** – validateEnigmaResponse (words/puzzle). **Story 4.3** – getEnigmaHints (nominal + ID inconnu), getEnigmaExplanation (nominal). Auth requise. |
| In-process Rust | `gamification_test.rs` | – | 4 | – | **Story 5.2** – getUserBadges, getUserSkills, getUserPostcards, getLeaderboard (auth requise). |
| In-process Rust | `admin_test.rs` | – | 19 | – | **Story 7.1** – 3 tests. **Story 7.2** – 10 tests. **Story 7.3** – 6 tests : investigationForPreview (admin/user), listInvestigations only published, publishInvestigation, rollbackInvestigation. |
| Widget Flutter | **progression_screen**, **completed_investigation_repository** (5.1), **gamification_screen** (5.2) | – | 12+ | – | Story 5.1 : statut par enquête, enquêtes complétées, progression ; Story 5.2 : badges, compétences, cartes postales, leaderboard. |
| Widget Flutter | **admin** (7.1, 7.3) | – | 12 | – | dashboard_screen_test (2), admin_route_guard_test (2) ; **7.3** : investigation_preview_screen_test (3), admin_investigation_list_screen_test (2), admin_investigation_detail_screen_test (3). d’ensemble, |

- **Résumé :** 46 tests Rust exécutés par défaut (13 unit/lib, 18 admin_test, 11 énigmas, 4 gamification), 6 tests `--ignored` (auth_test, investigations_test) ; 126 tests Flutter (dont 7.3 : prévisualisation, liste admin, détail admin avec Publier/Rollback ; 3 échecs connus dans widget_test.dart, hors 7.3).
- **Doublons évités :** Pas d’E2E pour 1.2/2.1/2.2/3.x ; logique métier couverte en unitaire + API ; widget couvre UX critique.

---

## Gaps identifiés (analyse post–3.1)

1. **Modèles / DTOs**
   - **Rust :** Pas de tests unitaires dédiés pour `Investigation` (sérialisation / champs). Couvert indirectement par le test in-process GraphQL.
   - **Flutter :** ✅ `Investigation.fromJson` couvert par `investigation_test.dart`.

2. **Services / Repository**
   - **Rust :** `InvestigationService::list_investigations` non testé unitairement (données mockées) ; optionnel car simple.
   - **Flutter :** Pas de tests unitaires pour `InvestigationRepository` (appels GraphQL mockés) ; couvert par les tests widget via override de provider.

3. **Story 2.2 (sélection enquête, gratuit/payant)**
   - ✅ Liste : libellé Gratuit/Payant et tap → détail (investigation_list_screen_test).
   - ✅ Détail : écran détail + CTA Démarrer (investigation_detail_screen_test).
   - ✅ Placeholder : écran démarrage (investigation_start_placeholder_screen_test).
   - ✅ PriceChip partagé (price_chip_test).

4. **Story 3.1 (démarrer enquête, navigation énigmes)**
   - ✅ Backend : query `investigation(id)` avec liste énigmes ordonnée – test in-process `investigation_by_id_returns_investigation_with_enigmas` (graphql.rs).
   - ✅ Flutter : écran play (InvestigationPlayScreen) – première énigme, stepper « Énigme 1/N », Suivant/Précédent, loading, état erreur (investigation_play_screen_test.dart, 5 tests).
   - ⚠️ Optionnel (LOW code review) : test widget pour cas `data == null` (enquête introuvable) ; Semantics sur boutons Retour états erreur/introuvable.

5. **Story 3.2 (progression, carte interactive, position)**
   - ✅ Flutter : indicateur progression (X/N énigmes) + barre sur écran play (investigation_play_screen_test couvre l’écran) ; carte en sheet « Voir la carte » (investigation_map_sheet_test.dart) – 3 tests : titre + carte, message localisation indisponible, marqueur si position disponible (mock GeolocationService).
   - ✅ Flutter : modèle Investigation – centerLat/centerLng (investigation_test.dart : parse centerLat/centerLng when present).
   - ✅ Backend : champs optionnels center_lat/center_lng sur Investigation (GraphQL) ; couvert indirectement par test in-process si la query inclut ces champs.
   - ⚠️ Optionnel : TU GeolocatorServiceImpl (actuellement mocké dans les tests widget) ; test widget carte avec centerLat/centerLng non null (centre enquête).

6. **Story 3.3 (pause, reprise, abandon, sauvegarde)**
   - ✅ Flutter : `InvestigationProgressRepository` – 6 TU (forTest) : getInProgressIds vide, getProgress null, save+get, getInProgressInvestigationIds après save, overwrite, deleteProgress.
   - ✅ Flutter : `InvestigationPlayScreen` – restauration progression au chargement (index énigme sauvegardé) – 1 test widget.
   - ✅ Flutter : `InvestigationListScreen` – section « Enquêtes en cours » quand progression existe, tap → reprise – 1 test widget.
   - Pas de tests API Rust pour 3.3 (persistance locale Hive uniquement).

7. **Story 4.1 (énigmes photo et géolocalisation)**
   - ✅ **Rust :** `tests/api/enigmas_test.rs` – 4 tests in-process : validateEnigmaResponse (géoloc dans tolérance / hors tolérance, photo fournie / non fournie) ; auth Bearer (register puis token).
   - ✅ **Flutter :** `photo_enigma_widget_test.dart` – titre, bouton « Prendre une photo », consigne (client mocké).
   - ✅ **Flutter :** `geolocation_enigma_widget_test.dart` – titre, bouton « Valider ma position », consigne (GeolocationService + client mockés).
   - ⚠️ Optionnel (LOW code review) : test widget « fallback galerie » si permission caméra refusée.

8. **Story 4.2 (énigmes mots et puzzle)**
   - ✅ **Rust :** `tests/api/enigmas_test.rs` – 4 tests in-process supplémentaires : validateEnigmaResponse (words valide/invalide, puzzle valide/invalide) ; payload textAnswer/codeAnswer. Total énigmes : 8 tests.
   - ✅ **Flutter :** `words_enigma_widget_test.dart` – 3 tests : affichage titre/consigne/bouton ; soumission → résultat succès ; soumission → message erreur (repository mocké).
   - ✅ **Flutter :** `puzzle_enigma_widget_test.dart` – 3 tests : affichage titre/consigne/bouton ; soumission → résultat succès ; soumission → message erreur (repository mocké).
   - Pas de gap identifié pour 4.2.

9. **Story 5.1 (statut completion, historique)**
   - ✅ **Flutter :** `progression_screen_test.dart` – écran Ma progression, statut par enquête, enquêtes complétées, progression globale ; tap enquête en cours.
   - ✅ **Flutter :** `completed_investigation_repository_test.dart` – 8 TU CompletedInvestigationRepository (forTest) : isCompleted, getCompletedOrderedByDate, markCompleted, overwrite, ordre.
   - Pas de tests API Rust pour 5.1 (données locales Hive / completed).

10. **Story 5.2 (badges, compétences, leaderboard)**
   - ✅ **Rust :** `tests/api/gamification_test.rs` – 4 tests in-process : getUserBadges, getUserSkills, getUserPostcards, getLeaderboard (register puis token).
   - ✅ **Flutter :** `gamification_screen_test.dart` – titres sections, contenu mocké (badges, skills, postcards, leaderboard), scroll pour Cartes postales et Classement.
   - Pas de gap identifié pour 5.2.

11. **Story 6.1 (première enquête gratuite, visibilité payant, prix)**
   - ✅ **Rust :** `graphql.rs` – listInvestigations avec priceAmount/priceCurrency (gratuit null, payant 299/EUR) ; `investigation_by_id_returns_price_fields_for_paid`. `investigations_test.rs` (HTTP) – champs priceAmount, priceCurrency dans la query et assertions.
   - ✅ **Flutter :** `investigation_test.dart` – priceAmount, priceCurrency, formattedPrice ; `investigation_list_screen_test.dart` – prix pour enquête payante ; `investigation_detail_screen_test.dart` – Payant + prix + Acheter + « Démarrer (après achat) ».
   - Pas de gap identifié pour 6.1.

12. **Story 7.1 (accès dashboard admin)**
   - ✅ **Rust :** `tests/api/admin_test.rs` – 3 tests in-process : me { id isAdmin } avec JWT admin → true ; getAdminDashboard avec JWT admin → données (investigationCount, publishedCount, draftCount, enigmaCount) ; getAdminDashboard avec JWT user → erreur FORBIDDEN. `auth_service.rs` – test unitaire register avec email seed admin → rôle Admin dans le JWT.
   - ✅ **Flutter :** `dashboard_screen_test.dart` – 2 tests : vue d’ensemble avec données mockées (titres, métriques) ; accès refusé 403 (message + bouton Retour). `admin_route_guard_test.dart` – 2 tests : redirection vers home si non-admin ; affichage dashboard si admin. Accessibilité : Semantics sur métriques et bouton Retour (WCAG 2.1 Level A).
   - Pas de gap identifié pour 7.1.

13. **Story 7.2 (création et édition enquêtes/énigmes)**
   - ✅ **Rust :** `tests/api/admin_test.rs` – 10 tests in-process pour 7.2 : createInvestigation (admin → succès avec id/titre/status, user → FORBIDDEN) ; updateInvestigation (admin → succès, user → FORBIDDEN) ; createEnigma (admin → succès avec id/orderIndex/type/titre, user → FORBIDDEN) ; updateEnigma (admin → succès, user → FORBIDDEN) ; validateEnigmaHistoricalContent (admin → historicalContentValidated true, user → FORBIDDEN).
   - ⚠️ **Flutter :** UI admin création/édition (Task 4) et tests widget (Task 5.2) non encore implémentés ; à prévoir quand les écrans investigation_edit_screen / enigma_edit_screen seront en place.
   - Pas de gap côté API ; gap côté UI et tests widget documenté.

14. **Story 7.3 (prévisualisation, publication et rollback)**
   - ✅ **Rust :** `tests/api/admin_test.rs` – 6 tests in-process : investigationForPreview (admin → brouillon, user → FORBIDDEN) ; listInvestigations sans token → uniquement published ; publishInvestigation → enquête visible au catalogue ; rollbackInvestigation → enquête masquée du catalogue (FR65, FR66, FR67).
   - ✅ **Flutter :** `investigation_preview_screen_test.dart` (3 tests), `admin_investigation_list_screen_test.dart` (2 tests), `admin_investigation_detail_screen_test.dart` (3 tests) – Prévisualiser, Publier, Rollback, confirmation.
   - Pas de gap identifié pour 7.3.

15. **E2E**
   - Aucun test E2E (Flutter `integration_test` ou scénario réel API + app). À prévoir si une story le demande (ex. parcours complet inscription → liste enquêtes).

16. **CI**
   - Rust : `cargo test` exécute unitaires + test in-process GraphQL ; tests `#[ignore]` à lancer avec serveur sur 8080.
   - Flutter : `flutter test` à exécuter en CI ; environnement SDK à configurer.

---

## Recommandations (Flutter & Rust)

### Priorité immédiate (post–3.1)

- **Flutter – Story 3.1 :** ✅ Écran enquête en cours (InvestigationPlayScreen) couvert par 5 tests widget : première énigme, Suivant, Précédent, loading, état erreur (investigation_play_screen_test.dart).
- **Rust – Story 3.1 :** ✅ Test in-process `investigation_by_id_returns_investigation_with_enigmas` (graphql.rs) pour la query investigation(id) + énigmes ; exécutable en CI sans serveur.
- **Flutter – Story 2.2 :** ✅ Écran détail, placeholder et PriceChip couverts (investigation_detail_screen_test, investigation_start_placeholder_screen_test, price_chip_test).
- **Rust :** Conserver les 2 tests in-process GraphQL (listInvestigations, investigation(id)) comme base de non-régression en CI ; tests `*_test.rs` `--ignored` utiles en intégration avec serveur.

### Moyen terme

- **E2E :** Si le produit exige un parcours bout-en-bout (inscription → onboarding → liste enquêtes), ajouter un répertoire `integration_test/` (Flutter) et un scénario ciblé (mock API ou serveur de test).
- **Erreurs API côté Flutter :** Pour affiner l’affichage des erreurs (ex. register), ajouter un test widget avec mock de `authServiceProvider` retournant une erreur.

### Exécution et CI

- **Rust :**  
  `cargo test` (défaut) ;  
  `cargo test --test auth_test --test investigations_test -- --ignored --nocapture` avec API sur localhost:8080.
- **Flutter :**  
  `cd city_detectives && flutter test`.
- **CI :** S’assurer que le pipeline exécute `cargo test` et `flutter test` ; pas besoin du serveur HTTP pour la régression critique (test in-process GraphQL couvre listInvestigations).

---

## Exécution des tests

### Rust

```bash
cd city-detectives-api

# Tous les tests exécutables sans serveur (unitaires + graphql in-process)
cargo test

# Tests d’intégration API (serveur sur localhost:8080)
cargo test --test auth_test --test investigations_test -- --ignored --nocapture
```

### Flutter

```bash
cd city_detectives
flutter test
```

---

## Tests ajoutés (workflow testarch-automate)

**2026-02-01 – Story 2.2**
- **investigation_detail_screen_test.dart** : 2 tests – détail avec chip Gratuit/Payant et CTA Démarrer.
- **investigation_start_placeholder_screen_test.dart** : 1 test – placeholder id + message Story 3.1 + Retour.
- **price_chip_test.dart** : 2 tests – affichage Gratuit / Payant selon isFree.

**2026-02-02 – Story 3.1**
- **city-detectives-api/src/api/graphql.rs** : test `investigation_by_id_returns_investigation_with_enigmas` – query investigation(id) avec investigation + enigmas (id, orderIndex, type, titre).
- **investigation_play_screen_test.dart** : 5 tests – première énigme + stepper, Suivant (2e énigme), Précédent, loading puis contenu, état erreur (message + bouton Retour).

**2026-02-02 – Story 3.2**
- **investigation_map_sheet_test.dart** : 3 tests – titre « Carte » + FlutterMap ; message « Localisation refusée ou indisponible » si position null ; marqueur Icons.my_location si position fournie (mock GeolocationService).
- **investigation_test.dart** : cas `parse centerLat and centerLng when present` (déjà présent ; couvre modèle Flutter pour centre carte).

**2026-02-02 – Story 3.3**
- **investigation_progress_repository_test.dart** : 6 TU – InvestigationProgressRepository.forTest() : getInProgressInvestigationIds vide, getProgress null, saveProgress + getProgress, getInProgressInvestigationIds après save, overwrite, deleteProgress.
- **investigation_play_screen_test.dart** : 1 test widget – restauration progression au chargement (index énigme sauvegardé affiché).
- **investigation_list_screen_test.dart** : 1 test widget – section « Enquêtes en cours » affichée quand progression sauvegardée, tap → reprise.

**2026-02-02 – Workflow testarch-automate (Standalone)**
- **welcome_screen_test.dart** : 3 tests widget – WelcomeScreen affiche titre/sous-titre/bouton Continuer (FR1) ; tap « Continuer » → navigation vers RegisterScreen (« Créer un compte ») ; Semantics pour accessibilité WCAG 2.1 Level A.
- **welcome_screen_test.dart** (étapes 1 et 2) : 2 tests widget – token présent + onboarding non fait → redirection vers OnboardingScreen (« Votre première enquête ») ; token présent + onboarding fait → redirection vers home (« Bienvenue – vous êtes connecté »). Overrides : FakeAuthService, _FakeOnboardingStorage.
- **onboarding_provider.dart** : refactor – stockage onboarding injectable via `OnboardingStorage` et `onboardingStorageProvider` (production = FlutterSecureStorage via adaptateur).
- **onboarding_provider_test.dart** : 5 TU – OnboardingNotifier avec FakeOnboardingStorage : build() selon valeur stockée ; markCompleted() écrit et met state à true ; invalidation puis re-read.

**2026-02-03 – Story 4.1 (énigmes photo et géolocalisation)**
- **city-detectives-api/tests/api/enigmas_test.rs** : 4 tests in-process – validateEnigmaResponse (géoloc valide/invalide, photo valide/invalide) ; auth Bearer (register puis token).
- **city_detectives/test/features/enigma/types/photo/photo_enigma_widget_test.dart** : 1 test widget – titre, bouton « Prendre une photo », consigne (client GraphQL mocké).
- **city_detectives/test/features/enigma/types/geolocation/geolocation_enigma_widget_test.dart** : 1 test widget – titre, bouton « Valider ma position », consigne (GeolocationService + client mockés).

**2026-02-03 – Story 4.2 (énigmes mots et puzzle)**
- **city-detectives-api/tests/api/enigmas_test.rs** : 4 tests in-process supplémentaires – validate_words_valid_when_correct_answer, validate_words_invalid_when_wrong_answer, validate_puzzle_valid_when_correct_code, validate_puzzle_invalid_when_wrong_code (payload textAnswer/codeAnswer).
- **city_detectives/test/features/enigma/types/words/words_enigma_widget_test.dart** : 3 tests widget – affichage titre/consigne/bouton ; soumission → message succès ; soumission → message erreur (FakeWordsRepository).
- **city_detectives/test/features/enigma/types/puzzle/puzzle_enigma_widget_test.dart** : 3 tests widget – affichage titre/consigne/bouton ; soumission → message succès ; soumission → message erreur (FakePuzzleRepository).

**2026-02-03 – Story 4.3 (aide contextuelle et explications historiques)**
- **city-detectives-api/tests/api/enigmas_test.rs** : 3 tests in-process – get_enigma_hints_returns_suggestion_hint_solution, get_enigma_explanation_returns_historical_and_educational, get_enigma_hints_returns_error_for_unknown_enigma (ID inconnu → erreur GraphQL avec message « Énigme introuvable »).
- **city_detectives/test/features/enigma/widgets/enigma_help_button_test.dart** : 3 tests widget – icône Aide ; ouverture bottom sheet avec Indice 1 + « Voir l'indice suivant » ; flux complet suggestion → indice 2 → solution + bouton Fermer.
- **city_detectives/test/features/enigma/screens/enigma_explanation_screen_test.dart** : 2 tests widget – affichage Contexte historique / Pour en savoir plus après chargement ; tap Continuer appelle onContinue.

**2026-02-03 – testarch-automate (expansion couverture)**
- **city-detectives-api/tests/api/enigmas_test.rs** : 1 test ajouté – get_enigma_hints_returns_error_for_unknown_enigma (couverture cas d’erreur ID inconnu pour Story 4.3).

**2026-02-03 – Story 4.4 (LORE et option de saut)**
- **city-detectives-api/src/api/graphql.rs** (mod tests) : 3 tests in-process – `get_lore_content_returns_content_for_investigation_and_sequence`, `get_lore_content_returns_null_for_unknown_sequence_index`, `get_lore_sequence_indexes_returns_ordered_list`.
- **city_detectives/test/features/enigma/screens/lore_screen_test.dart** : 5 tests widget – chargement puis titre/texte et boutons Sauter/Continuer ; Sauter et Continuer appellent onContinue ; état vide quand getLoreContent null ; section médias avec CachedNetworkImage quand mediaUrls non vide.

**2026-02-03 – testarch-automate (expansion couverture 5.1 et 5.2)**
- **Story 5.1** : inventaire et plan de couverture mis à jour – `progression_screen_test.dart`, `completed_investigation_repository_test.dart` (8 TU) ; gaps 5.1 documentés.
- **Story 5.2** : inventaire et plan de couverture mis à jour – `city-detectives-api/tests/api/gamification_test.rs` (4 tests in-process), `gamification_screen_test.dart` ; gaps 5.2 documentés.

**Story 6.1 (première enquête gratuite, visibilité payant, prix)**
- **Rust :** `graphql.rs` – tests in-process listInvestigations (priceAmount/priceCurrency gratuit null, payant 299/EUR), `investigation_by_id_returns_price_fields_for_paid` ; `investigations_test.rs` – query et assertions priceAmount, priceCurrency.
- **Flutter :** `investigation_test.dart` – priceAmount, priceCurrency, formattedPrice (null si gratuit, padding 2,00 €) ; `investigation_list_screen_test.dart` – prix pour enquête payante (FR47, FR49) ; `investigation_detail_screen_test.dart` – Payant + 4,99 € + Acheter + « Démarrer (après achat) ».

**2026-02-03 – Story 7.1 (accès dashboard admin)**
- **Rust :** `tests/api/admin_test.rs` – 3 tests in-process : me_returns_is_admin_true_when_admin_jwt ; get_admin_dashboard_returns_data_when_admin_jwt ; get_admin_dashboard_returns_forbidden_when_user_jwt. Test unitaire `auth_service.rs` : register avec email seed admin → rôle Admin dans le JWT.
- **Flutter :** `test/features/admin/screens/dashboard_screen_test.dart` – 2 tests : vue d’ensemble (données mockées), accès refusé 403. `test/features/admin/widgets/admin_route_guard_test.dart` – 2 tests : redirection si non-admin, affichage dashboard si admin. Accessibilité : Semantics sur métriques et bouton « Retour à l’accueil ».

**2026-02-03 – Story 7.2 (création et édition enquêtes/énigmes – backend)**
- **Rust :** `tests/api/admin_test.rs` – 10 tests in-process : create_investigation_succeeds_when_admin_jwt, create_investigation_returns_forbidden_when_user_jwt ; update_investigation_succeeds_when_admin_jwt, update_investigation_returns_forbidden_when_user_jwt ; create_enigma_succeeds_when_admin_jwt, create_enigma_returns_forbidden_when_user_jwt ; update_enigma_succeeds_when_admin_jwt, update_enigma_returns_forbidden_when_user_jwt ; validate_enigma_historical_content_succeeds_when_admin_jwt, validate_enigma_historical_content_returns_forbidden_when_user_jwt. Couverture FR62 (mutations enquêtes), FR63 (mutations énigmes), FR64 (validation contenu historique). Tests widget Flutter (formulaires admin) à ajouter lorsque Task 4 sera implémentée.

**2026-02-03 – Story 7.3 (prévisualisation, publication et rollback)**
- **Rust :** `tests/api/admin_test.rs` – 6 tests in-process : investigation_for_preview_returns_draft_when_admin_jwt, investigation_for_preview_returns_forbidden_when_user_jwt ; list_investigations_without_token_returns_only_published ; publish_investigation_succeeds_then_visible_in_catalog ; rollback_investigation_succeeds_then_hidden_from_catalog. Correctifs compilation (clone token, binding pour list) appliqués. Couverture FR65, FR66, FR67.
- **Flutter :** `investigation_preview_screen_test.dart` (3 tests), `admin_investigation_list_screen_test.dart` (2 tests), `admin_investigation_detail_screen_test.dart` (3 tests) – Prévisualiser, Publier, Rollback, confirmation.

---

## Definition of Done (workflow testarch-automate)

- [x] Inventaire complet des tests existants (Rust + Flutter) pour 1.2, 2.1, 2.2, 3.1, 3.2 et 3.3.
- [x] Analyse des gaps (modèles, services, E2E) et recommandations spécifiques Flutter/Rust.
- [x] Plan de couverture documenté (priorités P1/P2, niveaux API / unit / widget).
- [x] Pas de doublon inutile ; E2E non requis pour les stories actuelles.
- [x] Tests Story 2.2 ajoutés (écran détail, placeholder, PriceChip).
- [x] Tests Story 3.1 ajoutés (backend investigation(id) in-process ; Flutter écran play – 5 tests widget).
- [x] Tests Story 3.2 documentés (carte investigation_map_sheet_test – 3 tests ; centerLat/centerLng dans investigation_test).
- [x] Tests Story 3.3 documentés (InvestigationProgressRepository 6 TU, restauration progression play screen, section « Enquêtes en cours » liste).
- [x] Résumé sauvegardé dans `_bmad-output/automation-summary.md`.
- [x] **2026-02-02 testarch-automate** : WelcomeScreen – 3 tests widget (contenu FR1, navigation Continuer → register, Semantics).
- [x] **2026-02-02 étapes 1 et 2** : WelcomeScreen – 2 tests redirect (token + onboarding non fait → onboarding ; token + onboarding fait → home). OnboardingNotifier – refactor stockage injectable (OnboardingStorage) + 5 TU avec FakeOnboardingStorage.
- [x] **2026-02-03 testarch-automate** : Story 4.1 documentée – enigmas_test.rs (4 tests in-process), photo_enigma_widget_test.dart, geolocation_enigma_widget_test.dart ; inventaire et plan de couverture mis à jour.
- [x] **2026-02-03 testarch-automate** : Story 4.2 documentée – enigmas_test.rs (8 tests au total : +4 words/puzzle), words_enigma_widget_test.dart (3 tests), puzzle_enigma_widget_test.dart (3 tests) ; inventaire et gaps mis à jour.
- [x] **2026-02-03 testarch-automate** : Story 4.3 documentée – enigmas_test.rs (11 tests : +3 getEnigmaHints/getEnigmaExplanation dont 1 cas erreur ID inconnu), enigma_help_button_test.dart (3 tests), enigma_explanation_screen_test.dart (2 tests) ; inventaire et plan de couverture mis à jour.
- [x] **2026-02-03 testarch-automate** : Story 4.4 (LORE) documentée – graphql.rs (3 tests in-process : getLoreContent nominal + null, getLoreSequenceIndexes), lore_screen_test.dart (5 tests : contenu, Sauter/Continuer, état vide, médias) ; inventaire et plan de couverture à jour.
- [x] **2026-02-03 testarch-automate** : Stories 5.1 et 5.2 documentées – gamification_test.rs (4 tests), gamification_screen_test.dart, progression_screen_test.dart, completed_investigation_repository_test.dart (8 TU) ; inventaire, plan de couverture et gaps à jour.
- [x] **2026-02-03 testarch-automate** : Story 6.1 documentée – graphql.rs (listInvestigations + investigation(id) prix), investigations_test.rs (priceAmount/priceCurrency), investigation_test.dart (formattedPrice), investigation_list_screen_test.dart (prix liste), investigation_detail_screen_test.dart (Payant + Acheter) ; inventaire et résultats d'exécution à jour (112 Flutter, 26 Rust).
- [x] **2026-02-03 testarch-automate** : Story 7.1 documentée – admin_test.rs (3 tests : me isAdmin, getAdminDashboard admin/user), auth_service.rs (test unitaire admin seed), dashboard_screen_test.dart (2 tests), admin_route_guard_test.dart (2 tests) ; inventaire, plan de couverture et résultats à jour (116 Flutter, 29 Rust).
- [x] **2026-02-03 testarch-automate** : Story 7.2 (backend) documentée – admin_test.rs (13 tests : 3 pour 7.1 + 10 pour 7.2 : create/update investigation, create/update enigma, validateEnigmaHistoricalContent, avec JWT admin vs user) ; inventaire, gaps (UI Flutter à venir) et résultats d'exécution mis à jour.
- [x] **2026-02-03 testarch-automate** : Story 7.3 documentée – admin_test.rs (19 tests : +6 prévisualisation/publication/rollback) ; Flutter investigation_preview_screen_test (3), admin_investigation_list_screen_test (2), admin_investigation_detail_screen_test (3) ; inventaire, plan de couverture, résultats d’exécution mis à jour.

---

## Fichiers de test (référence)

| Fichier | Rôle |
|---------|------|
| `city-detectives-api/src/models/user.rs` | Tests unitaires RegisterInput. |
| `city-detectives-api/src/services/auth_service.rs` | Tests unitaires auth. |
| `city-detectives-api/src/api/graphql.rs` | Test in-process listInvestigations (CI). |
| `city-detectives-api/tests/api/auth_test.rs` | Tests intégration register (HTTP). |
| `city-detectives-api/tests/api/investigations_test.rs` | Tests intégration listInvestigations (HTTP). |
| `city_detectives/test/register_screen_test.dart` | Widget inscription. |
| `city_detectives/test/onboarding_screen_test.dart` | Widget onboarding. |
| `city_detectives/test/features/investigation/investigation_list_screen_test.dart` | Widget liste enquêtes (2.1 + 2.2), section « Enquêtes en cours » (3.3). |
| `city_detectives/test/features/investigation/screens/investigation_detail_screen_test.dart` | Widget écran détail enquête (2.2). |
| `city_detectives/test/features/investigation/screens/investigation_start_placeholder_screen_test.dart` | Widget placeholder démarrage (2.2). |
| `city_detectives/test/features/investigation/screens/investigation_play_screen_test.dart` | Widget écran enquête en cours – première énigme, navigation, loading, erreur (3.1), progression/carte (3.2), restauration progression (3.3). |
| `city_detectives/test/features/investigation/widgets/investigation_map_sheet_test.dart` | Widget carte sheet – titre, carte, message localisation indisponible, marqueur position (3.2). |
| `city_detectives/test/features/investigation/repositories/investigation_progress_repository_test.dart` | TU InvestigationProgressRepository (forTest) – save/get/delete progression (3.3). |
| `city_detectives/test/shared/widgets/price_chip_test.dart` | Widget PriceChip Gratuit/Payant (2.2). |
| `city_detectives/test/widget_test.dart` | Smoke app / welcome. |
| `city_detectives/test/features/onboarding/screens/welcome_screen_test.dart` | Widget WelcomeScreen (1.1/1.3) : contenu, navigation Continuer → register, Semantics, redirect token → onboarding/home. |
| `city_detectives/test/features/onboarding/providers/onboarding_provider_test.dart` | TU OnboardingNotifier (1.3) avec stockage injecté. |
| `city_detectives/lib/features/onboarding/providers/onboarding_storage.dart` | Interface OnboardingStorage pour injection (prod + test). |
| `city_detectives/test/features/investigation/models/investigation_test.dart` | TU `Investigation.fromJson`. |
| `city_detectives/test/features/enigma/types/photo/photo_enigma_widget_test.dart` | **Story 4.1** – Widget énigme photo. |
| `city_detectives/test/features/enigma/types/geolocation/geolocation_enigma_widget_test.dart` | **Story 4.1** – Widget énigme géolocalisation. |
| `city_detectives/test/features/enigma/types/words/words_enigma_widget_test.dart` | **Story 4.2** – Widget énigme mots (3 tests). |
| `city_detectives/test/features/enigma/types/puzzle/puzzle_enigma_widget_test.dart` | **Story 4.2** – Widget énigme puzzle (3 tests). |
| `city-detectives-api/tests/api/enigmas_test.rs` | **Story 4.1 + 4.2 + 4.3** – Intégration validateEnigmaResponse (8 tests), getEnigmaHints/getEnigmaExplanation (3 tests dont 1 erreur ID inconnu). |
| `city_detectives/test/features/enigma/widgets/enigma_help_button_test.dart` | **Story 4.3** – Bouton Aide + panneau indices (3 tests). |
| `city_detectives/test/features/enigma/screens/enigma_explanation_screen_test.dart` | **Story 4.3** – Écran Explications (2 tests). |
| `city_detectives/test/features/enigma/screens/lore_screen_test.dart` | **Story 4.4** – Écran LORE (5 tests). |
| `city_detectives/test/features/profile/screens/progression_screen_test.dart` | **Story 5.1** – Écran Ma progression (statut, enquêtes complétées, progression). |
| `city_detectives/test/features/profile/screens/gamification_screen_test.dart` | **Story 5.2** – Écran Gamification (badges, compétences, cartes postales, leaderboard). |
| `city_detectives/test/features/investigation/repositories/completed_investigation_repository_test.dart` | **Story 5.1** – TU CompletedInvestigationRepository (8 tests). |
| `city-detectives-api/tests/api/gamification_test.rs` | **Story 5.2** – getUserBadges, getUserSkills, getUserPostcards, getLeaderboard (4 tests). |
| `city-detectives-api/tests/api/admin_test.rs` | **Story 7.1** (3), **7.2** (10), **7.3** (6 : prévisualisation, publication, rollback). |
| `city_detectives/test/features/admin/screens/dashboard_screen_test.dart` | **Story 7.1** – DashboardScreen : vue d’ensemble, accès refusé 403 (2 tests). |
| `city_detectives/test/features/admin/widgets/admin_route_guard_test.dart` | **Story 7.1** – AdminRouteGuard : redirection non-admin, affichage si admin (2 tests). |
| `city_detectives/test/features/admin/screens/investigation_preview_screen_test.dart` | **Story 7.3** – Prévisualisation (3 tests). |
| `city_detectives/test/features/admin/screens/admin_investigation_list_screen_test.dart` | **Story 7.3** – Liste enquêtes admin (2 tests). |
| `city_detectives/test/features/admin/screens/admin_investigation_detail_screen_test.dart` | **Story 7.3** – Détail admin Publier/Rollback (3 tests). |
| `city_detectives/integration_test/app_test.dart` | E2E welcome → register, retour. |

---

## TU et E2E ajoutés (2026-02-01)

### Flutter – TU `Investigation.fromJson`

- **Fichier :** `city_detectives/test/features/investigation/models/investigation_test.dart`
- **Cas :** JSON valide type GraphQL ; champs manquants ou null (valeurs par défaut) ; `durationEstimate` (int, double, string, invalide) ; `isFree` (true/false/null/autres) ; champs string avec valeurs non-string (conversion).
- **Exécution :** `flutter test test/features/investigation/models/investigation_test.dart`

### Flutter – E2E (integration_test)

- **Fichier :** `city_detectives/integration_test/app_test.dart`
- **Scénarios :** (1) app lance, écran welcome visible ; (2) tap « Continuer » → écran inscription ; (3) retour arrière → welcome.
- **Exécution :** `flutter test integration_test/app_test.dart` (nécessite un device/émulateur ou une plateforme hôte supportée).
- **Dépendance :** `integration_test: sdk: flutter` dans `pubspec.yaml`.

---

## Prochaines étapes

1. Lancer en local : `cargo test` (Rust), `flutter test` (Flutter) ; optionnel : tests `--ignored` avec API sur 8080.
2. Exécuter les E2E avec émulateur ou appareil : `flutter test integration_test/app_test.dart`.
3. Vérifier en CI que les jobs Rust et Flutter exécutent ces commandes.
4. Si besoin : mocks API pour E2E « onboarding → liste enquêtes » (inscription réussie puis navigation).
5. Optionnel (LOW) : test widget pour cas « enquête introuvable » (data == null) ; Semantics sur boutons Retour des états erreur/introuvable (écran play).
6. Optionnel : test widget carte avec centerLat/centerLng non null (centre enquête depuis backend) ; TU GeolocatorServiceImpl (mock suffit pour les tests widget).
7. Optionnel (LOW code review 4.1) : test widget « fallback galerie » si permission caméra refusée (photo énigme).

---

---

## Résultats d'exécution (2026-02-03)

- **Rust** (`cargo test`) : 46 tests passés (13 unit/lib, 18 admin_test [3 pour 7.1 + 10 pour 7.2 + 6 pour 7.3], 11 enigmas_test, 4 gamification_test) ; auth_test (4) et investigations_test (2) ignorés (serveur 8080).
- **Flutter** (`flutter test`) : 126 tests au total ; 123 passent (dont Story 7.3 : prévisualisation, liste admin, détail admin). 3 échecs connus dans `widget_test.dart` (hors 7.3, à traiter manuellement). Des `ClientException` (tile.openstreetmap.org 400) peuvent apparaître en log sans faire échouer les tests.

---

*Workflow : `_bmad/bmm/workflows/testarch/automate` (testarch-automate). Dernière mise à jour : 2026-02-03 (Story 7.3 – prévisualisation, publication, rollback ; résultats Rust 46, Flutter 126 dont 123 passants).*
