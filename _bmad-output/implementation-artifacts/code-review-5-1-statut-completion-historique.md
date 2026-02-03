# Code Review – Story 5.1 Statut de complétion et historique

**Story:** 5-1-statut-completion-historique  
**Story file:** 5-1-statut-completion-historique.md  
**Date:** 2026-02-03  
**Reviewer:** Revue adverse (Senior Developer)

---

## Git vs Story Discrepancies

- **1 écart** : `city_detectives/lib/features/investigation/models/investigation_progress.g.dart` est modifié (git) mais absent de la File List de la story. Probablement régénération build_runner / fin de lignes.

---

## Issues Found

**Résumé :** 1 critique (corrigé), 1 élevé (corrigé), 3 moyen, 3 faible.

---

## CRITICAL (corrigé)

### 1. Ré-enregistrement de la progression après complétion (investigation_play_screen.dart)

**Problème :** Après avoir marqué l’enquête comme complétée et supprimé sa progression (`deleteProgress`), le code appelait systématiquement `_saveProgress(ref, investigationId)`, qui ré-enregistrait la même enquête en « en cours ». Résultat : une enquête pouvait être à la fois « complétée » et « en cours ».

**Preuve :** Lignes 321–336 : bloc `else` (dernière énigme validée) → `markCompleted`, `deleteProgress`, puis appel commun `_saveProgress(ref, investigationId)` (ligne 336).

**Correction appliquée :** `_saveProgress` n’est plus appelé dans le cas « dernière énigme validée ». Il n’est appelé que lorsque `safeIndex < total - 1`.

---

## HIGH (corrigé)

### 2. Données de progression obsolètes (investigation_play_screen.dart)

**Problème :** Après complétion d’une enquête, `userProgressDataProvider` n’était pas invalidé. En ouvrant l’écran Progression juste après, l’utilisateur pouvait encore voir l’enquête en « en cours ».

**Correction appliquée :** Appel à `ref.invalidate(userProgressDataProvider)` après `markCompleted` et `deleteProgress` dans le bloc « dernière énigme validée ».

---

## MEDIUM

### 3. Routes en dur (progression_screen.dart)

**Fichier :** `city_detectives/lib/features/profile/screens/progression_screen.dart`  
**Lignes :** 241, 307

**Problème :** Utilisation de chaînes en dur `'/investigations/$investigationId/start'` et `'/investigations/$investigationId'` au lieu de constantes ou helpers du `AppRouter`. En cas de changement des chemins, risque d’incohérence et de régression.

**Recommandation :** Introduire par ex. `AppRouter.investigationDetailPath(id)` et `AppRouter.investigationStartPath(id)` (ou équivalent) et les utiliser ici.

### 4. Task 4.1 – Accès partiel (AC)

**Problème :** La task 4.1 exige un accès à l’écran progression « depuis le menu principal, la barre de navigation ou l’écran liste des enquêtes ». Seul l’accès depuis la liste des enquêtes (icône) est implémenté. Pas de lien depuis le menu principal ni la barre de navigation.

**Recommandation :** Ajouter un accès depuis le menu principal et/ou la barre de navigation (ex. écran home, drawer, bottom nav) selon le design existant.

### 5. File List incomplète

**Problème :** Le fichier `city_detectives/lib/features/investigation/models/investigation_progress.g.dart` apparaît comme modifié dans git mais n’est pas listé dans la section File List de la story. Documentation incomplète des changements.

**Recommandation :** Soit l’ajouter à la File List (avec mention « régénéré » si pertinent), soit s’assurer qu’il n’est pas commité si le changement est uniquement fin de lignes / outil.

---

## LOW

### 6. FR41 – Durée non affichée (optionnel)

**Problème :** FR41 prévoit une liste avec « titre, date, éventuellement durée ». La durée de l’enquête (temps entre démarrage et complétion) n’est pas affichée dans l’historique.

**Recommandation :** Optionnel pour le MVP ; à traiter en amélioration si besoin produit.

### 7. Repository forTest – Liste non stockée (completed_investigation_repository.dart)

**Fichier :** `city_detectives/lib/features/investigation/repositories/completed_investigation_repository.dart`  
**Lignes :** 36–39

**Problème :** Dans la branche `else` de `markCompleted`, `final list = _testList ?? []` peut être une nouvelle liste ; les mutations ne sont alors pas conservées. Seul le cas `forTest()` avec `_testList = []` est correct. Comportement fragile si le repository est réutilisé avec `_testList == null`.

**Recommandation :** Documenter ou adapter le flux pour que la branche test ne s’exécute qu’avec `forTest()`, ou stocker explicitement la liste dans un champ mutable en mode test.

### 8. Accessibilité – Bouton « Réessayer » (progression_screen.dart)

**Problème :** En état erreur, le bouton « Réessayer » n’a pas de `Semantics` dédié (label / rôle bouton), ce qui peut dégrader l’usage avec les lecteurs d’écran.

**Recommandation :** Envelopper le bouton dans un `Semantics(label: 'Réessayer le chargement de la progression', button: true, child: ...)`.

---

## Validation des AC

| AC | Statut | Commentaire |
|----|--------|-------------|
| AC1 – Statut par enquête visible | OK | Écran Progression avec non démarrée / en cours / complétée. |
| AC1 – Progression globale et historique | OK | Barre X/Y et liste « Enquêtes complétées » par date. |

---

## Synthèse

- **Critique et élevé :** corrigés dans le code (pas de ré-enregistrement après complétion, invalidation du provider de progression).
- **Moyen / faible :** laissés en « Review Follow-ups » dans la story pour traitement ultérieur ou prise en charge selon priorité produit.

---

## Second Review Pass (2026-02-03)

**Objectif :** Revue adverse après correction des follow-ups.

### Issues trouvés (2e passage)

- **HIGH (corrigé)** : Navigation depuis l’historique vers le détail enquête cassée : la route `investigationDetail` attend `state.extra` de type `Investigation`, alors que l’écran Progression faisait `context.push(path)` sans `extra` → affichage « Enquête introuvable ». **Correction :** `CompletedHistoryEntry` enrichi avec `Investigation?` ; dans `_HistoryTile`, passage de `extra: investigation` lorsque non null.
- **MEDIUM (corrigé)** : Écran home : les `onTap` des ListTile appelaient `GoRouter.of(context)` sans vérifier `context.mounted` (risque si le contexte est démonté). **Correction :** garde `if (!context.mounted) return;` avant chaque navigation.
- **LOW** : Pas de test widget qui vérifie la navigation Progression → détail avec `extra`. Amélioration possible pour éviter les régressions.
- **LOW** : Zone d’erreur de l’écran Progression sans `Semantics` englobant (ex. `liveRegion` ou label de région) pour les lecteurs d’écran.

### Validation 2e passage

- AC1 (statut, progression, historique) : OK.
- Tous les points HIGH/MEDIUM du 2e passage sont corrigés. Story prête pour statut **done**.
