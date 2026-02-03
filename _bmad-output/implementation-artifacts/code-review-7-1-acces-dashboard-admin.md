# Code Review – Story 7.1 : Accès dashboard admin

**Story :** 7-1-acces-dashboard-admin  
**Fichier :** `_bmad-output/implementation-artifacts/7-1-acces-dashboard-admin.md`  
**Date :** 2026-02-03  
**Reviewer :** Revue adverse (Senior Developer persona)

---

## 1. Git vs File List

- **Fichiers modifiés par git (non committés) :**  
  `7-1-acces-dashboard-admin.md`, `sprint-status.yaml`, `Cargo.toml`, `graphql.rs`, `lib.rs`, `main.rs`, `user.rs`, `auth_service.rs`, `mod.rs`, `enigmas_test.rs`, `gamification_test.rs`, `user_repository.dart`, `app_router.dart`, `auth_provider.dart` + fichiers/dossiers nouveaux (admin_service.rs, admin_test.rs, core/screens/, features/admin/, test/features/admin/).
- **Écarts identifiés :**
  - **Dans git mais absents de la File List :** `city-detectives-api/tests/api/enigmas_test.rs`, `city-detectives-api/tests/api/gamification_test.rs` (ajout de `AdminService` à `create_schema` pour la 7.1).
- **Conclusion :** 2 fichiers modifiés pour cette story ne sont pas documentés dans la Dev Agent Record → File List.

---

## 2. Validation des AC

| AC | Statut | Preuve |
|----|--------|--------|
| AC1 : Compte admin authentifié → connexion au dashboard → vue d’ensemble affichée | IMPLEMENTED | `getAdminDashboard` protégée par `require_admin()` ; `DashboardScreen` affiche `DashboardOverview` ; `AdminRouteGuard` restreint l’accès. |

---

## 3. Audit des tâches [x]

- **Task 1.1–1.4 :** Implémenté (User.role, JWT role, require_admin, me { id, isAdmin }, lien Flutter si isAdmin).
- **Task 2.1–2.3 :** Implémenté (getAdminDashboard, AdminService, type DashboardOverview).
- **Task 3.1–3.4 :** Implémenté (écran, route protégée, provider/repository, AsyncValue, 403, design).
- **Task 4.1–4.4 :** Implémenté (admin_test.rs, dashboard_screen_test.dart, quality gates, Semantics sur métriques).

Aucune tâche marquée [x] sans preuve dans le code.

---

## 4. Problèmes identifiés (3–10)

### HIGH

*Aucun.* Les AC sont couverts et les tâches [x] correspondent au code.

### MEDIUM

1. **File List incomplète (documentation)**  
   - **Fichiers concernés :** `city-detectives-api/tests/api/enigmas_test.rs`, `city-detectives-api/tests/api/gamification_test.rs`.  
   - **Constat :** Modifiés pour passer `AdminService` à `create_schema` dans le cadre de la 7.1, mais non listés dans la section File List de la story.  
   - **Action :** Ajouter ces deux fichiers à la File List dans le Dev Agent Record.

2. **Absence de test pour la query `me` et le rôle admin**  
   - **Fichier :** `city-detectives-api` (tests).  
   - **Constat :** Aucun test ne vérifie que `me { id isAdmin }` retourne `isAdmin: true` pour un token émis avec l’email seed admin. Le client Flutter s’appuie sur ce contrat pour afficher le lien dashboard.  
   - **Action :** Ajouter un test (ex. dans `admin_test.rs` ou `auth_test.rs`) : register avec `admin@city-detectives.local`, appeler `me` avec ce token, vérifier `isAdmin === true`.

3. **AdminRouteGuard : erreur traitée comme non-admin**  
   - **Fichier :** `city_detectives/lib/features/admin/widgets/admin_route_guard.dart`.  
   - **Constat :** En cas d’erreur sur `currentUserProvider` (réseau, 500, token expiré), le guard redirige vers home comme pour un non-admin. Un admin légitime peut donc être redirigé en cas d’erreur temporaire, sans message ni retry.  
   - **Action :** Documenter ce comportement (ou, à terme, afficher un message d’erreur / bouton réessayer au lieu de rediriger silencieusement).

### LOW

4. **Configuration du seed admin en dur**  
   - **Fichier :** `city-detectives-api/src/services/auth_service.rs` (const `ADMIN_SEED_EMAIL`).  
   - **Constat :** Email admin fixe. En production, une variable d’environnement (ex. `ADMIN_SEED_EMAIL`) ou une liste configurable serait préférable.  
   - **Action :** Optionnel pour le MVP ; documenter ou prévoir un TODO pour la prod.

5. **Accessibilité du bouton « Retour à l’accueil » (dashboard)**  
   - **Fichier :** `city_detectives/lib/features/admin/screens/dashboard_screen.dart` (IconButton dans l’AppBar).  
   - **Constat :** Seul un `tooltip` est fourni ; pour WCAG 2.1 Level A, un `Semantics(label: 'Retour à l\'accueil')` (ou équivalent) sur le bouton améliore l’annonce pour les lecteurs d’écran.  
   - **Action :** Envelopper l’IconButton dans un `Semantics` avec un label explicite.

6. **Pas de test widget pour AdminRouteGuard**  
   - **Fichier :** `city_detectives/test/features/admin/`.  
   - **Constat :** Aucun test ne vérifie que `AdminRouteGuard` redirige vers home lorsque `currentUser?.isAdmin != true`. Les tests mockent directement `DashboardScreen`.  
   - **Action :** Ajouter un test (ex. override de `currentUserProvider` avec `isAdmin: false` et vérification de la redirection vers home).

7. **Pas de test unitaire auth pour le rôle admin dans le JWT**  
   - **Fichier :** `city-detectives-api/src/services/auth_service.rs` (module tests).  
   - **Constat :** Aucun test ne vérifie que l’inscription avec `admin@city-detectives.local` produit un JWT dont les claims contiennent le rôle admin (décodage ou appel à `validate_token_claims`).  
   - **Action :** Ajouter un test du type `register_with_admin_seed_email_returns_token_with_admin_role`.

---

## 5. Synthèse

- **Git vs File List :** 2 écarts (fichiers modifiés non listés).  
- **Problèmes :** 0 HIGH, 3 MEDIUM, 4 LOW.  
- **Recommandation :** Corriger les MEDIUM (File List + test `me`/admin ; documenter ou améliorer le comportement du guard en erreur). Les LOW peuvent être traités maintenant ou en suivi.

---

---

## 6. Correctifs appliqués (choix utilisateur : 1 – correction automatique)

- **File List :** ajout de `enigmas_test.rs`, `gamification_test.rs`, `admin_route_guard_test.dart`.
- **Backend :** test `me_returns_is_admin_true_when_admin_jwt` dans admin_test.rs ; test unitaire `register_with_admin_seed_email_returns_token_with_admin_role` dans auth_service.rs ; commentaire sur ADMIN_SEED_EMAIL pour la prod.
- **Flutter :** Semantics(label) sur le bouton Retour à l'accueil du dashboard ; commentaire dans AdminRouteGuard sur le comportement en erreur ; nouveau test `admin_route_guard_test.dart` (redirection si non-admin, affichage dashboard si admin).
- **Story :** section « Senior Developer Review (AI) » et Change Log mises à jour ; statut passé à **done** ; sprint-status : 7-1-acces-dashboard-admin → **done**.

_Checklist : AC vérifiés, File List complète, correctifs appliqués. Statut final : **done**._
