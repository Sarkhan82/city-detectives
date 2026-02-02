# Code Review – Story 3.3 : Pause, reprise, abandon et sauvegarde

**Story :** 3-3-pause-reprise-abandon-sauvegarde  
**Fichier story :** `_bmad-output/implementation-artifacts/3-3-pause-reprise-abandon-sauvegarde.md`  
**Date :** 2026-02-02  
**Revue :** Adversariale (Senior Developer)

---

## Git vs Story – Écarts

- **Fichiers modifiés (git) non listés dans la story File List :**
  - `city_detectives/pubspec.lock` (modifié)
  - `city_detectives/windows/flutter/generated_plugin_registrant.cc`, `generated_plugins.cmake` (générés, optionnel à documenter)
- **Fichiers listés dans la story sans changement git attendu :** `app_router.dart` (mentionné comme « import utilisé », pas modifié) – OK.
- **Conclusion :** 1 écart de documentation (pubspec.lock).

---

## Synthèse des problèmes

| Sévérité | Nombre | Description |
|----------|--------|-------------|
| CRITICAL / HIGH | 2 | setState pendant build ; sauvegarde non attendue avant navigation |
| MEDIUM | 2 | File List incomplet ; pas de test « reprise au bon index » |
| LOW | 3 | Clamp à la restauration ; firstWhere + try/catch ; typeId Hive |

**Total : 7 problèmes identifiés.**

---

## CRITICAL / HIGH

### 1. [CRITICAL] setState() appelé pendant build → risque d’exception Flutter

**Fichier :** `city_detectives/lib/features/investigation/screens/investigation_play_screen.dart`  
**Ligne :** 75

Quand il n’y a **pas** de progression sauvegardée (`progress == null`), le code appelle `setState(() => _progressRestored = true)` directement dans la méthode `build()`. En Flutter, appeler `setState()` pendant `build()` peut provoquer une exception (setState() or markNeedsBuild() called during build).

**Extrait :**
```dart
if (data != null && !_progressRestored) {
  final progress = repo.getProgress(investigationId);
  if (progress != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) { ... });
    return Semantics(...);  // loader
  }
  setState(() => _progressRestored = true);  // ← pendant build !
}
return _buildContent(...);
```

**Correction :** Planifier le `setState` après le frame (ex. `WidgetsBinding.instance.addPostFrameCallback`) comme pour la branche `progress != null`, au lieu d’appeler `setState` synchrone dans `build`.

---

### 2. [HIGH] Sauvegarde progression non attendue avant navigation → perte possible

**Fichier :** `city_detectives/lib/features/investigation/screens/investigation_play_screen.dart`  
**Lignes :** 14–23 (fonction `_saveProgress`), 173–174, 185–186, 206–207

`_saveProgress(ref, investigationId)` appelle `repo.saveProgress(...)` qui retourne une `Future<void>`, mais cette future n’est jamais attendue. Immédiatement après, le code fait `context.pop()` ou `context.go(...)`. L’écran est démonté avant que l’écriture Hive soit terminée, ce qui peut entraîner une **perte de progression** (surtout sur appareil lent ou I/O chargé).

**Extrait :**
```dart
onPressed: () {
  _saveProgress(ref, investigationId);  // fire-and-forget
  context.go(AppRouter.investigations);  // navigation immédiate
},
```

**Correction :** Rendre `_saveProgress` asynchrone (ex. `Future<void> _saveProgress(...)`), l’appeler avec `await` (dans un callback async ou via un petit helper), et naviguer seulement après `await _saveProgress(...)` (ou au minimum attendre la future avant de naviguer).

---

## MEDIUM

### 3. [MEDIUM] File List story incomplet

**Story :** Dev Agent Record → File List

`pubspec.lock` est modifié (dépendances Hive, etc.) mais n’apparaît pas dans la File List de la story. Les fichiers générés Windows (`generated_plugin_registrant.cc`, `generated_plugins.cmake`) sont aussi modifiés ; pour traçabilité, on peut les mentionner comme « générés » ou les exclure explicitement.

**Correction :** Ajouter `city_detectives/pubspec.lock` à la File List (et optionnellement une note sur les fichiers Windows générés).

---

### 4. [MEDIUM] Pas de test widget « reprise au bon index »

**Story Task 5.1 :** « tests pour écran « reprendre » (présence liste enquêtes en cours, **reprise au bon index**) ».

Il existe un test pour la présence de la section « Enquêtes en cours » et du libellé « Reprendre », mais **aucun test** qui :
- préremplisse une progression (ex. index 2, énigmes complétées e1, e2),
- ouvre l’écran de jeu pour cette enquête,
- et vérifie que l’énigme affichée correspond bien à l’index sauvegardé (ex. « Énigme 3 / N » ou titre de la 3e énigme).

**Correction :** Ajouter un test widget (ex. dans `investigation_play_screen_test.dart`) qui seed le repository de progression (forTest), ouvre `InvestigationPlayScreen`, et fait des `expect` sur l’index/énigme affichée après reprise.

---

## LOW

### 5. [LOW] Restauration : index non clampé côté chargement

**Fichier :** `investigation_play_screen.dart` (restauration dans le postFrameCallback)

Lors de la restauration, on affecte `progress.currentEnigmaIndex` tel quel aux providers. Si l’enquête a été modifiée (moins d’énigmes), l’index peut dépasser la taille. `_buildContent` utilise déjà un `safeIndex` clampé, donc pas de crash, mais pour cohérence et clarté on peut clamp l’index au chargement : `clamp(0, data.enigmas.length - 1)` (ou 0 si pas d’énigmes).

---

### 6. [LOW] firstWhere + try/catch dans la liste

**Fichier :** `city_detectives/lib/features/investigation/screens/investigation_list_screen.dart`  
**Lignes :** 104–109

Recherche d’une enquête par id avec `list.firstWhere((e) => e.id == id)` dans un try/catch pour mettre `inv = null`. Fonctionnel mais peu idiomatique. On peut utiliser par exemple `list.where((e) => e.id == id).firstOrNull` (Dart 2.19+) ou un helper pour éviter le try/catch.

---

### 7. [LOW] typeId Hive 0

**Fichier :** `investigation_progress.dart`  
**Ligne :** 7

`@HiveType(typeId: 0)` : le typeId 0 est souvent utilisé. Si d’autres types Hive sont ajoutés plus tard, un conflit de typeId est possible. Recommandation : documenter dans le fichier que le typeId 0 est réservé à `InvestigationProgress`, ou choisir un typeId moins courant (ex. 100 + hash du nom).

---

## Validation AC / Tasks

- **AC1 (progression sauvegardée, reprise au point d’arrêt) :** Implémenté ; risque de perte si sauvegarde non attendue (voir #2).
- **Tasks 1–5 marqués [x] :** Réalisés ; les points #1 et #2 concernent la robustesse de l’implémentation (bugs potentiels), pas l’absence de feature.
- **Architecture / project-context :** Conformes (Hive, repository, pas d’accès Hive direct depuis l’écran, Semantics).

---

## Recommandation

- **À corriger en priorité :** #1 (setState pendant build) et #2 (await sauvegarde avant navigation).
- **Souhaitable :** #3 (File List), #4 (test reprise au bon index).
- **Optionnel :** #5, #6, #7.

---

## Corrections appliquées (2026-02-02)

- **#1 (CRITICAL)** : `setState` pendant le build → `addPostFrameCallback` quand `progress == null`.
- **#2 (HIGH)** : `_saveProgress` rendue `Future<void>` et `await` avant `context.pop()` / `context.go()` (retour, pause, abandon) ; vérification `context.mounted` après l’await.
- **#3 (MEDIUM)** : File List complété avec `city_detectives/pubspec.lock`.
- **#4 (MEDIUM)** : Test widget « InvestigationPlayScreen restores progress and shows correct enigma index » ajouté dans `investigation_play_screen_test.dart`.
- **Bonus** : Avertissements `unnecessary_non_null_assertion` dans le repository corrigés (utilisation de la promotion de type pour `_box`).

Story passée en **done** ; `sprint-status.yaml` mis à jour : `3-3-pause-reprise-abandon-sauvegarde: done`.
