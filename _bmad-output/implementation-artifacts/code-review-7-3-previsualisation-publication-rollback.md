# Code Review – Story 7.3 : Prévisualisation, publication et rollback

**Story :** 7-3-previsualisation-publication-rollback  
**Reviewer :** Senior Developer (AI), mode adversarial  
**Date :** 2026-02-03  

---

## Git vs Story

- **Fichiers modifiés/nouveaux (git) :** alignés avec le File List de la story (hors `_bmad-output`).
- **Écart :** aucun fichier applicatif modifié n’est absent du File List.
- **Conclusion :** pas d’écart critique Git / File List.

---

## Problèmes identifiés (minimum 3)

### CRITIQUE

1. **Task 4.3 marquée [x] alors que non réalisée**  
   - **Fichier / preuve :** `7-3-previsualisation-publication-rollback.md` (Tasks 4.3), `city_detectives/test/features/admin/` (aucun test pour preview/list/detail).  
   - La story exige : *« Flutter : tests widget pour boutons Prévisualiser, Publier, Rollback et confirmation ; mocker les mutations »*.  
   - Il n’existe aucun test widget pour `InvestigationPreviewScreen`, `AdminInvestigationListScreen`, `AdminInvestigationDetailScreen`, ni pour les boutons Publier/Rollback et la confirmation.  
   - Seuls `dashboard_screen_test.dart` et `admin_route_guard_test.dart` existent (pré-7.3).  
   - **Sévérité :** CRITICAL (tâche cochée complète alors qu’elle ne l’est pas).

### HAUTE

2. **Exposition d’erreurs techniques à l’utilisateur**  
   - **Fichier :** `city_detectives/lib/features/admin/screens/admin_investigation_detail_screen.dart` (lignes 42–43, 85–86).  
   - En cas d’échec de `publishInvestigation` ou `rollbackInvestigation`, le SnackBar affiche `Erreur: $e` (stack / message technique).  
   - Risque : fuite d’informations, mauvaise UX.  
   - **Sévérité :** HIGH (sécurité / UX).

3. **Statut `status` null non géré en affichage**  
   - **Fichiers :** `admin_investigation_list_screen.dart` (subtitle), `admin_investigation_detail_screen.dart` (isDraft).  
   - Si `inv.status == null` (ancien modèle ou API sans champ), `isDraft = false` → affichage « Publiée » et bouton Rollback affiché. Comportement ambigu ou faux.  
   - **Sévérité :** HIGH (données incohérentes possibles).

### MOYENNE

4. **Structure GraphQL non conforme à la Dev Notes**  
   - **Fichier :** `city_detectives/lib/features/admin/repositories/admin_investigation_repository.dart`.  
   - Les Dev Notes / File Structure exigent : `lib/features/admin/graphql/publish_investigation.graphql`, `rollback_investigation.graphql`, et query preview dédiée.  
   - Les requêtes sont en constantes Dart dans le repository, pas en fichiers `.graphql`.  
   - **Sévérité :** MEDIUM (conformité structure).

5. **Labels d’accessibilité manquants sur des contrôles d’erreur**  
   - **Fichier :** `city_detectives/lib/features/admin/screens/investigation_preview_screen.dart` (bouton « Retour au dashboard » en cas d’erreur, lignes 109–112).  
   - Pas de `Semantics` / `label` sur ce bouton, alors que les autres écrans admin en ont.  
   - **Sévérité :** MEDIUM (WCAG 2.1 Level A).

### BASSE

6. **Champ `published_at` non implémenté**  
   - Story 2.1 : *« éventuellement published_at »*. Backend : seul `status` est mis à jour, pas de `published_at`.  
   - **Sévérité :** LOW.

7. **Tri des énigmes en prévisualisation**  
   - L’écran de preview affiche les énigmes dans l’ordre de la liste API. Le backend trie bien par `order_index` ; aucun tri explicite côté client.  
   - Risque faible si le contrat API reste garanti.  
   - **Sévérité :** LOW (documentation / robustesse).

---

## Synthèse

| Sévérité | Nombre |
|----------|--------|
| CRITICAL | 1     |
| HIGH     | 2     |
| MEDIUM   | 2     |
| LOW      | 2     |

**Total : 7 problèmes identifiés.**

---

## Recommandation

- **Verdict :** Changes Requested.  
- À traiter avant passage en *done* : au minimum le point CRITICAL (4.3 – tests widget) et les deux HIGH (messages d’erreur, `status` null).
