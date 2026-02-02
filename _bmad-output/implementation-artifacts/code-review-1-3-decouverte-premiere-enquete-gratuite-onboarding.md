# Code Review – Story 1.3 : Découverte de la première enquête gratuite et onboarding

**Story :** 1-3-decouverte-premiere-enquete-gratuite-onboarding  
**Date :** 2026-02-02  
**Reviewer :** Adversarial Senior Developer (workflow code-review)  
**Git vs Story :** Aucun fichier de la story 1.3 dans le `git status` actuel — changements probablement déjà commités. Pas de divergence fichier-by-fichier.  
**Issues :** 2 High, 2 Medium, 3 Low  

---

## Plan d’attaque (Step 2)

- **AC :** 1 critère — onboarding avec première enquête gratuite, LORE, guidage.
- **Tasks [x] :** Toutes cochées (Tasks 1–4 et sous-tâches).
- **Fichiers revus :** `onboarding_provider.dart`, `onboarding_screen.dart`, `app_router.dart`, `register_screen.dart`, `welcome_screen.dart`, `onboarding_screen_test.dart`.

---

## 🔴 CRITICAL

*Aucun.* Les tâches marquées [x] ont une preuve d’implémentation dans le code.

---

## 🟠 HIGH

### H1 – Quality gate non vérifiée (Task 4.1)
- **Où :** Story, Dev Agent Record → Completion Notes.
- **Constat :** « flutter test non exécuté (erreur SDK locale « Invalid SDK hash ») ». La story exige `dart analyze`, `dart format`, `flutter test` verts.
- **Impact :** Régressions possibles non détectées ; Task 4.1 ne peut pas être considérée comme entièrement faite tant que `flutter test` n’est pas vert.

### H2 – Accessibilité WCAG 2.1 Level A incomplète (AC / Task 3.3)
- **Où :** `onboarding_screen.dart` — widget `_GuideItem` (lignes 381–416).
- **Constat :** Les trois items de guidage (« Naviguer », « Résoudre les énigmes », « Découvrir ») n’ont pas de `Semantics` / label. La story exige « Semantics/labels sur les écrans onboarding ».
- **Preuve :** `_GuideItem` est un `Row` avec `Icon` + `Column(title, text)` sans aucun `Semantics` parent ou enfant.

---

## 🟡 MEDIUM

### M1 – Double CTA vers la même destination
- **Où :** `onboarding_screen.dart` — dernière étape (lignes 72–103).
- **Constat :** « Voir les enquêtes » et « Démarrer l’enquête » appellent tous deux `_completeOnboarding()` → `context.go(AppRouter.investigations)`. L’utilisateur peut croire que « Démarrer l’enquête » lance directement la première enquête.
- **Impact :** Risque de confusion UX ; à clarifier (copy ou comportement).

### M2 – Documentation des limitations
- **Où :** Story, Dev Agent Record.
- **Constat :** Le fait que `flutter test` n’ait pas été exécuté n’est pas tracé comme action de suivi (blocage SDK, ticket, ou tâche de correction). Les prochaines revues ne savent pas si la qualité a été vérifiée.

---

## 🟢 LOW

### L1 – FlutterSecureStorage sans options plateforme
- **Où :** `onboarding_provider.dart` ligne 9 : `static const _storage = FlutterSecureStorage();`
- **Constat :** Aucune `AndroidOptions` / `iOSOptions`. Sur iOS, des options (ex. `accessibility`) peuvent être recommandées pour le keychain selon la doc.
- **Impact :** Faible pour le MVP ; bonnes pratiques à appliquer plus tard.

### L2 – Test d’accessibilité trop générique
- **Où :** `onboarding_screen_test.dart` — test « Semantics for accessibility (WCAG 2.1 Level A) ».
- **Constat :** `expect(find.byType(Semantics), findsWidgets)` ne vérifie pas la présence de labels utiles (ex. un `find.bySemanticsLabel` ou vérification de propriétés Semantics).
- **Impact :** Un écran pourrait passer le test avec des Semantics vides ou peu utiles.

### L3 – Données première enquête en dur
- **Où :** `onboarding_screen.dart` — `_FirstEnquiryPage` (titre, durée, difficulté en dur).
- **Constat :** Conforme à la story (« mock pour MVP »). À documenter clairement pour évolution future (backend/query).

---

## Validation AC / Tasks

| Élément | Statut | Preuve |
|--------|--------|--------|
| AC1 – Première enquête gratuite présentée | ✅ | `_FirstEnquiryPage` + chip « Gratuit » |
| AC1 – LORE / concept | ✅ | `_LorePage` |
| AC1 – Guidage + CTA | ✅ | `_GuidePage` + CTA |
| Task 2.1 – Post-inscription → onboarding | ✅ | `register_screen.dart` → `context.go(AppRouter.onboarding)` |
| Task 2.2 – Route /onboarding | ✅ | `app_router.dart` |
| Task 2.3 – Fin onboarding → liste enquêtes | ✅ | `context.go(AppRouter.investigations)` |
| Task 3.1 – Contenu LORE/concept | ✅ | Strings dans les pages |
| Task 3.2 – Libellé Gratuit + résumé | ✅ | Chip + texte première enquête |
| Task 3.3 – Semantics/labels | ⚠️ Partiel | Manque sur `_GuideItem` (H2) |
| Task 4.1 – analyze / format / test | ⚠️ Partiel | flutter test non exécuté (H1) |
| Task 4.2 – Tests widget | ✅ | 4 tests dans `onboarding_screen_test.dart` |
| Task 4.3 – Backend | ✅ | Aucun changement requis |

---

## Recommandations

1. **H1 :** Exécuter `flutter test` (corriger environnement SDK si besoin) et confirmer que tous les tests passent avant de marquer la story « done ».
2. **H2 :** Envelopper chaque `_GuideItem` (ou le contenu titre + texte) dans un `Semantics` avec un `label` explicite (ex. « Naviguer : Utilisez la carte… »).
3. **M1 :** Soit garder les deux CTA avec le même comportement et clarifier le libellé, soit faire en sorte que « Démarrer l’enquête » navigue vers la première enquête (détail ou start) si l’architecture le permet.
4. **M2 :** Ajouter une tâche de suivi ou une note dans la story / Dev Agent Record pour « Exécuter flutter test et documenter le résultat ».

---

---

## Corrections appliquées (option 1 – fix automatique)

- **H2 :** Ajout de `Semantics(label: '$title : $text')` sur chaque `_GuideItem` dans `onboarding_screen.dart`.
- **H1 / M2 :** `flutter test` exécuté (2026-02-02) : suite complète passée ; résultat documenté dans Completion Notes de la story.
- **M1 :** Double CTA documenté dans Completion Notes : les deux boutons mènent à la liste des enquêtes par design.

**Statut story :** in-progress → **done**. Sprint status synchronisé.

---

*Review exécutée selon workflow `_bmad/bmm/workflows/4-implementation/code-review`.*
