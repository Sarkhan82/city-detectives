# Mockups et Références - City Detectives

Ce dossier contient les mockups HTML et les fichiers de référence utilisés comme inspiration pour le design de City Detectives.

## Structure

```
mockups-references/
├── README.md (ce fichier)
├── case-closed-summary.html (Écran Final Report / Case Closed)
└── [autres mockups à venir]
```

## Fichiers

### case-closed-summary.html

**Description :** Écran "Case Closed Summary" (Final Report) créé avec Google Stitch.

**Éléments clés :**
- Design de dossier confidentiel avec effet papier/texture
- Stamp "RESOLVED" avec effet grunge
- Métriques de performance (Time, Solves, Score)
- "Chief's Commendation" avec signature
- Bouton d'action "SHARE DOSSIER"
- Navigation retour discrète

**Alignement UX :**
- ✅ Ton moderne et mystérieux (fond sombre, éléments thématiques)
- ✅ Layout aéré et spacieux
- ✅ Contenu long-form bien géré (commendation)
- ✅ Interface claire avec hiérarchie visuelle forte

**Utilisation :**
- Ouvrir dans un navigateur pour visualiser
- Utiliser comme référence pour l'implémentation Flutter
- Inspirer les animations et transitions (rotation de la carte, révélation du stamp)

## Comment utiliser ces fichiers

1. **Visualisation :** Ouvrir les fichiers HTML dans un navigateur pour voir le rendu
2. **Inspiration design :** Utiliser les styles, couleurs, et layouts comme référence
3. **Implémentation :** Adapter les concepts pour Flutter/Material Design 3
4. **Documentation :** Référencer ces fichiers dans le design system

## Notes

- Les images sont hébergées sur Google (via Google Stitch)
- Les polices utilisent Google Fonts (Public Sans, Material Symbols)
- Le style utilise Tailwind CSS
- Adapter les couleurs pour correspondre à la palette définie dans `ux-design-specification.md`

## Palette de couleurs utilisée

- **Primary (Rouge)** : `#f20d0d` (à adapter vers or/doré `#d4af37` selon fondations)
- **Background Dark** : `#221010` (proche de `#0a0a0a` des fondations)
- **Paper** : `#F0EAD6` / `#f3f0e6` (effet papier pour les cartes)

**Note :** Adapter ces couleurs pour correspondre exactement à la palette définie dans les fondations visuelles (bleu nuit `#1a1a2e`, or `#d4af37`, etc.)

## Prochaines étapes

- [ ] Créer d'autres mockups HTML pour les autres écrans (Map, Journal, Profile, etc.)
- [ ] Documenter les patterns d'interaction identifiés
- [ ] Créer un guide de conversion HTML → Flutter
- [ ] Extraire les assets/images pour usage local
