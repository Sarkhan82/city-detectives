# Code Review – Story 4.3 : Aide contextuelle et explications historiques

**Story Key:** 4-3-aide-contextuelle-explications-historiques  
**Date:** 2026-02-03  
**Revue :** Adversarial Senior Developer (workflow code-review)

---

## Contexte

- **Fichiers revus :** File List de la story (hors _bmad-output), uniquement code applicatif.
- **Git :** Modifications et nouveaux fichiers (screens/, widgets/, tests) cohérents avec la File List. Aucune revendication fausse (fichiers listés sans changement).
- **AC et tâches :** Toutes les tâches marquées [x] correspondent à du code présent ; les AC sont globalement couverts avec les réserves ci‑dessous.

---

## 🔴 CRITICAL ISSUES

*Aucun.* Aucune tâche marquée [x] sans implémentation réelle, aucun AC totalement absent.

---

## 🟡 MEDIUM ISSUES

### 1. Navigation : usage de `Navigator.push` au lieu de GoRouter  
**Fichier :** `city_detectives/lib/features/investigation/screens/investigation_play_screen.dart` (l.282–308)

**Constat :** L’écran des explications est affiché via `Navigator.of(context).push(MaterialPageRoute<void>(...))` au lieu d’une route GoRouter.

**Référence :** project-context.md – *« Navigation : GoRouter (déclaratif) ; pas de bus d'events global »*. L’app utilise partout ailleurs `context.go()` / `context.push()` (investigation_list_screen, onboarding, etc.). Cette route est la seule à utiliser l’API impérative `Navigator.push`.

**Impact :** Incohérence d’architecture, routes non déclaratives, historique et deep-linking moins propres.

**Recommandation :** Déclarer une route (ex. `/investigations/:id/play/enigma-explanation`) dans `app_router.dart` et utiliser `context.push(..., extra: { enigmaId, onContinue })` ou équivalent (paramètres de route / state) pour ouvrir l’écran Explications.

---

### 2. Tests widget : flux « suggestion → indice → solution » non vérifié  
**Fichiers :** `city_detectives/test/features/enigma/widgets/enigma_help_button_test.dart`

**Constat :** La story (Task 4.2) exige des *« tests widget pour … déroulement des indices (suggestion → indice → solution) »*. Le test actuel vérifie uniquement l’affichage du premier indice et du bouton « Voir l’indice suivant ». Il ne simule pas :
- un tap sur « Voir l’indice suivant » pour afficher l’indice 2 ;
- un second tap pour afficher la solution et le libellé « Solution » / « Fermer ».

**Recommandation :** Ajouter un test du type `EnigmaHelpButton tap next shows hint then solution` qui enchaîne deux taps et vérifie la présence du texte de l’indice 2 puis de la solution (et du bouton « Fermer »).

---

### 3. Quality gate : `dart format` non mentionné  
**Constat :** La story (Task 4.3) et les Completion Notes indiquent *« dart analyze, flutter test, cargo test, clippy verts »*. Le project-context exige aussi *« dart format »* dans les quality gates avant merge. Aucune preuve que `dart format` a été exécuté sur les fichiers modifiés.

**Recommandation :** Exécuter `dart format .` sur le projet Flutter et documenter dans la story / Completion Notes que la quality gate inclut bien `dart format`.

---

## 🟢 LOW ISSUES

### 4. Backend : erreurs sans `extensions.code` (NOT_FOUND)  
**Fichiers :** `city-detectives-api/src/api/graphql.rs`, `src/services/enigma_service.rs`

**Constat :** En cas d’énigme inconnue, le service retourne `Err("Énigme introuvable")`, transformé en erreur GraphQL générique. L’architecture (project-context / architecture) recommande des erreurs avec `extensions.code` (ex. `NOT_FOUND`, `UNAUTHENTICATED`) pour un traitement côté client plus propre.

**Recommandation :** Utiliser le format d’erreur GraphQL avec `extensions.code: "NOT_FOUND"` pour les cas « énigme introuvable » (et éventuellement « ID énigme invalide »).

---

### 5. Redondance : double accès à `AuthService` dans les queries  
**Fichier :** `city-detectives-api/src/api/graphql.rs` (l.74–77 et 90–93)

**Constat :** Dans `get_enigma_hints` et `get_enigma_explanation`, `ctx.data::<Arc<AuthService>>()` est appelé deux fois (une pour `_`, une pour `validate_token`). Même pattern que dans d’autres resolvers ; pas de bug, mais duplication.

**Recommandation :** Stocker le résultat dans une variable et réutiliser pour la validation du token.

---

### 6. Backend : pas de test pour « énigme introuvable »  
**Fichier :** `city-detectives-api/tests/api/enigmas_test.rs`

**Constat :** Les tests 4.3 couvrent uniquement le cas nominal (ID valide). Il n’y a pas de test pour un `enigmaId` invalide (UUID mal formé) ou inconnu (énigme absente du mock), pour vérifier le message ou le code d’erreur.

**Recommandation :** Ajouter un test (ex. `get_enigma_hints_returns_error_for_unknown_enigma`) avec un UUID valide mais inconnu, et vérifier que la réponse contient une erreur (et idéalement un code NOT_FOUND si implémenté).

---

### 7. Task 2.4 / FR37 : pas de support photo dans l’écran Explications  
**Fichiers :** `city_detectives/lib/features/enigma/screens/enigma_explanation_screen.dart`, modèle backend `EnigmaExplanation`

**Constat :** La task 2.4 et FR37 mentionnent *« photos/contexte historique des lieux si disponible »*. L’écran et le type n’exposent que du texte (`historicalExplanation`, `educationalContent`). Aucun champ optionnel pour une URL d’image.

**Impact :** Limité : le libellé est « si disponible ». Pour le MVP, le texte seul peut suffire ; l’absence de photo est un manque par rapport à la spec, en niveau « nice to have ».

**Recommandation :** Soit documenter explicitement que les photos sont reportées en V1, soit ajouter un champ optionnel `imageUrl` (backend + Flutter) et l’afficher dans l’écran Explications quand présent.

---

### 8. Accessibilité : état d’erreur de l’écran Explications  
**Fichier :** `city_detectives/lib/features/enigma/screens/enigma_explanation_screen.dart` (bloc `error:`)

**Constat :** En cas d’erreur de chargement, l’utilisateur voit un message et un bouton « Continuer ». Il n’y a pas de `Semantics` dédié pour annoncer qu’une erreur s’est produite (ex. `Semantics(label: 'Erreur lors du chargement des explications. Vous pouvez continuer.')`).

**Recommandation :** Envelopper la zone d’erreur dans un `Semantics` avec un libellé explicite pour les lecteurs d’écran (WCAG 2.1 Level A).

---

### 9. Task 1.1 : aide après inactivité (optionnel) non implémentée  
**Constat :** La task 1.1 indique *« optionnel : proposer l'aide après une durée d'inactivité (ex. 2–3 min) »*. Seul le bouton Aide est implémenté ; aucun timer d’inactivité.

**Impact :** Faible (explicitement optionnel).

**Recommandation :** Soit l’implémenter (timer + proposition d’aide), soit noter dans la story / Completion Notes que cette partie optionnelle est reportée.

---

## Synthèse

| Sévérité | Nombre |
|----------|--------|
| CRITICAL | 0 |
| MEDIUM   | 3 |
| LOW      | 6 |
| **Total**| **9** |

**Git vs File List :** Aucune incohérence (fichiers listés = modifiés ou nouveaux ; dossiers non suivis contiennent bien les nouveaux fichiers listés).

**Prochaines étapes possibles :**  
1. Corriger automatiquement les points MEDIUM (et éventuellement LOW).  
2. Créer des action items dans la story (section « Review Follow-ups (AI) »).  
3. Approfondir un point précis sur demande.

---

## Corrections appliquées (option 1)

- **MEDIUM 1** : Route GoRouter ajoutée dans `app_router.dart` (sous-route `explanation` de `investigationStart`). `InvestigationPlayScreen` utilise `context.push<bool>(path, extra: enigmaId)` et `await`, puis met à jour l’état après `pop(true)`.
- **MEDIUM 2** : Test `EnigmaHelpButton full flow suggestion then hint then solution` ajouté : deux taps sur « Voir l’indice suivant », vérification de l’indice 2 puis de la solution et du bouton « Fermer ».
- **MEDIUM 3** : `dart format lib test` exécuté (7 fichiers formatés). Completion Notes de la story mises à jour pour inclure `dart format` dans la quality gate.
