# Résumé d'automatisation – City Detectives (Stories 1.2, 2.1, 2.2)

**Date :** 2026-02-01  
**Stories couvertes :** 1.2 (Création de compte), 2.1 (Parcourir et consulter les enquêtes), 2.2 (Sélection enquête, gratuit/payant)  
**Mode :** Standalone / Auto-discover  
**Cible de couverture :** critical-paths  

---

## Contexte

- **Stack :** Flutter (app mobile) + Rust (API GraphQL). Pas de Playwright/Cypress (Node/TS).
- **Frameworks de test :** Flutter (widget tests, `flutter test`) ; Rust (`cargo test`, tests d’intégration API, tests in-process GraphQL).
- **Artéfacts BMad :** Stories 1.2, 2.1 et 2.2 ; workflow testarch-automate en mode autonome.

---

## Inventaire des tests existants

### Rust – API (`city-detectives-api`)

| Fichier | Type | Exécution | Description |
|---------|------|-----------|-------------|
| `src/api/graphql.rs` (mod tests) | In-process | `cargo test` | `list_investigations_in_process_returns_array` – query listInvestigations sans HTTP, exécutable en CI. |
| `tests/api/auth_test.rs` | Intégration HTTP | `--ignored` (serveur 8080) | 4 tests : register JWT, email dupliqué, email invalide, mot de passe court. |
| `tests/api/investigations_test.rs` | Intégration HTTP | `--ignored` (serveur 8080) | 2 tests : listInvestigations retourne un tableau ; items ont les champs requis. |

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
| `features/investigation/investigation_list_screen_test.dart` | Liste (durée, difficulté, description, gratuit), état vide, message d’erreur utilisateur. |
| `features/investigation/screens/investigation_detail_screen_test.dart` | Détail enquête : titre, description, chip Gratuit/Payant, CTA Démarrer (Story 2.2). |
| `features/investigation/screens/investigation_start_placeholder_screen_test.dart` | Placeholder démarrage : id enquête, message Story 3.1, bouton Retour (Story 2.2). |
| `shared/widgets/price_chip_test.dart` | Widget PriceChip : Gratuit / Payant selon isFree (Story 2.2). |
| `features/investigation/models/investigation_test.dart` | TU `Investigation.fromJson` (défensif, isFree, durationEstimate). |
| `widget_test.dart` | App build, WelcomeScreen. |

- **Total Flutter :** 27 tests widget (plusieurs `testWidgets` par fichier).
- **Exécution :** `cd city_detectives && flutter test`.

---

## Plan de couverture (niveaux / priorités)

| Niveau | Zone | P0 | P1 | P2 | Description |
|--------|------|----|----|----|-------------|
| API Rust | `auth_test.rs` | – | 4 | – | Register JWT, email dupliqué, email invalide, mot de passe court |
| API Rust | `investigations_test.rs` | – | 2 | – | listInvestigations tableau + champs requis |
| In-process Rust | `graphql.rs` (tests) | – | 1 | – | listInvestigations sans serveur (CI) |
| Unit Rust | `user.rs` | – | – | 3 | Validation RegisterInput |
| Unit Rust | `auth_service.rs` | – | – | 2 | JWT / validation token |
| Widget Flutter | register, onboarding, investigation_list, detail, placeholder, price_chip, models, widget | – | 27 | – | Écrans 1.2, 1.3, 2.1, 2.2 (liste, détail, placeholder, PriceChip) |

- **Résumé :** 7 tests API/in-process Rust (1 exécutable en CI), 5 tests unitaires Rust, 27 tests widget Flutter.
- **Doublons évités :** Pas d’E2E pour 1.2/2.1/2.2 ; logique métier couverte en unitaire + API ; widget couvre UX critique.

---

## Gaps identifiés (analyse post–2.2)

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

4. **E2E**
   - Aucun test E2E (Flutter `integration_test` ou scénario réel API + app). À prévoir si une story le demande (ex. parcours complet inscription → liste enquêtes).

5. **CI**
   - Rust : `cargo test` exécute unitaires + test in-process GraphQL ; tests `#[ignore]` à lancer avec serveur sur 8080.
   - Flutter : `flutter test` à exécuter en CI ; environnement SDK à configurer.

---

## Recommandations (Flutter & Rust)

### Priorité immédiate (post–2.2)

- **Flutter – Story 2.2 :** ✅ Écran détail, placeholder et PriceChip couverts par widget tests (investigation_detail_screen_test, investigation_start_placeholder_screen_test, price_chip_test).
- **Rust :** Conserver le test in-process `list_investigations_in_process_returns_array` comme base de non-régression GraphQL en CI ; les tests `investigations_test.rs` restent utiles en intégration avec serveur.

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

## Tests ajoutés (workflow testarch-automate – 2026-02-01, Story 2.2)

- **investigation_detail_screen_test.dart** : 2 tests – détail avec chip Gratuit/Payant et CTA Démarrer.
- **investigation_start_placeholder_screen_test.dart** : 1 test – placeholder id + message Story 3.1 + Retour.
- **price_chip_test.dart** : 2 tests – affichage Gratuit / Payant selon isFree.

---

## Definition of Done (workflow testarch-automate)

- [x] Inventaire complet des tests existants (Rust + Flutter) pour 1.2, 2.1 et 2.2.
- [x] Analyse des gaps (modèles, services, E2E) et recommandations spécifiques Flutter/Rust.
- [x] Plan de couverture documenté (priorités P1/P2, niveaux API / unit / widget).
- [x] Pas de doublon inutile ; E2E non requis pour les stories actuelles.
- [x] Tests Story 2.2 ajoutés (écran détail, placeholder, PriceChip).
- [x] Résumé sauvegardé dans `_bmad-output/automation-summary.md`.

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
| `city_detectives/test/features/investigation/investigation_list_screen_test.dart` | Widget liste enquêtes (2.1 + 2.2). |
| `city_detectives/test/features/investigation/screens/investigation_detail_screen_test.dart` | Widget écran détail enquête (2.2). |
| `city_detectives/test/features/investigation/screens/investigation_start_placeholder_screen_test.dart` | Widget placeholder démarrage (2.2). |
| `city_detectives/test/shared/widgets/price_chip_test.dart` | Widget PriceChip Gratuit/Payant (2.2). |
| `city_detectives/test/widget_test.dart` | Smoke app / welcome. |
| `city_detectives/test/features/investigation/models/investigation_test.dart` | TU `Investigation.fromJson`. |
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

---

*Workflow : `_bmad/bmm/workflows/testarch/automate` (testarch-automate).*
