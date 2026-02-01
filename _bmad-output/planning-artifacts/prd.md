---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-03-success', 'step-04-journeys', 'step-05-domain', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish']
inputDocuments: ['_bmad-output/planning-artifacts/product-brief-city-detectives-2026-01-24.md', '_bmad-output/analysis/brainstorming-session-2026-01-24.md']
workflowType: 'prd'
briefCount: 1
researchCount: 0
brainstormingCount: 1
projectDocsCount: 0
classification:
  projectType: mobile_app
  domain: general
  complexity: medium
  projectContext: greenfield
---

# Product Requirements Document - city-detectives

**Author:** Sarkhan  
**Date:** 2026-01-24  
**Project:** city-detectives  
**Type:** Mobile Application (Flutter, iOS/Android)  
**Domain:** General (Tourism/Entertainment)  
**Complexity:** Medium

---

## Success Criteria

### User Success

**Résultat recherché par les utilisateurs :**
- Faire un maximum d'enquêtes le plus vite possible
- Découvrir un maximum de villes
- S'amuser tout en découvrant une ville
- Apprendre l'histoire et le patrimoine de manière ludique
- Passer un bon moment en groupe ou en famille

**Comment les utilisateurs savent que le produit fonctionne :**
- **Badges** : Progression visible, accomplissements reconnus
- **Timers** : Mesure du temps et de la performance
- **Plaisir** : Sentiment d'amusement et d'engagement
- **Découvertes** : Apprentissage de nouvelles choses sur les villes

**Moment de réalisation de la valeur :**
- En s'amusant et faisant de nouvelles enquêtes
- Quand ils prennent une nouvelle enquête après en avoir complété une
- Quand ils jouent régulièrement (ex: tous les weekends)

**Métriques de succès utilisateur mesurables :**

1. **Taux de complétion d'enquête** : >80% des utilisateurs complètent une enquête commencée
2. **Temps moyen par enquête** : 1h-1h30 (objectif validé)
3. **Taux de retour (Retention Rate)** : À définir selon les données initiales
4. **Taux d'adoption de nouvelles enquêtes** : 15-20% des utilisateurs achètent/jouent une nouvelle enquête après la première gratuite
5. **Fréquence de jeu** : Nombre d'enquêtes complétées par utilisateur par mois
6. **Engagement régulier** : % d'utilisateurs actifs chaque semaine/mois
7. **Satisfaction utilisateur** : >4/5 étoiles en moyenne
8. **Nombre de villes découvertes** : Nombre moyen de villes explorées par utilisateur
9. **Collection de badges** : Progression dans la gamification (badges obtenus)

### Business Success

**Objectifs à 3 mois :**
- **Premiers revenus** : 500€/mois (MRR)
- **5 villes disponibles** : Au moins 5 villes avec plusieurs enquêtes chacune (2-3 enquêtes par ville)
- **Base d'utilisateurs** : Acquisition des premiers utilisateurs payants
- **Validation du modèle** : Confirmation que le modèle économique fonctionne

**Objectifs à 12 mois :**
- **Vivre du projet** : 5000€/mois (MRR) - Revenus suffisants pour vivre du projet
- **Très gros pool de villes/enquêtes** : 20+ villes, 50+ enquêtes
- **Croissance utilisateurs** : Base d'utilisateurs active et croissante
- **Engagement fort** : Utilisateurs réguliers et engagés

**Métriques business à mesurer :**

1. **Revenus mensuels (MRR)** : Métrique principale de succès
   - Objectif 3 mois : 500€/mois
   - Objectif 12 mois : 5000€/mois
   - Fréquence : Mensuelle
   - **Note** : Nécessite modélisation du nombre d'utilisateurs nécessaires (estimé : 500-1100 utilisateurs totaux à 3 mois pour atteindre 500€/mois avec 15-20% de conversion)

2. **Taux de conversion freemium** : 15-20%
   - Mesure : % d'utilisateurs qui achètent après la première enquête gratuite
   - Fréquence : Mensuelle

3. **Croissance utilisateurs** : À définir selon les données initiales
   - Mesure : Nombre de nouveaux utilisateurs par mois
   - Fréquence : Mensuelle

4. **Valeur par utilisateur (ARPU)** : À définir
   - Mesure : Revenus moyens par utilisateur actif
   - Fréquence : Mensuelle

5. **Taux de rétention** : À définir
   - Mesure : % d'utilisateurs actifs après 30/60/90 jours
   - Fréquence : Mensuelle

6. **Nombre de villes disponibles** :
   - Objectif 3 mois : 5 villes avec plusieurs enquêtes
   - Objectif 12 mois : 20+ villes, 50+ enquêtes
   - Fréquence : Mensuelle

**Contribution aux objectifs plus larges :**
- **Apprendre** : Faire apprendre l'histoire et le patrimoine aux utilisateurs
- **Faire sortir les gens** : Encourager l'exploration physique des villes
- **Activité physique** : Promouvoir l'activité en extérieur
- **Réflexion** : Stimuler la réflexion et la résolution de problèmes
- **Être en groupe** : Favoriser les interactions sociales et les moments partagés

### Technical Success

**Métriques techniques critiques :**

1. **Stabilité de l'application** : Taux de crash <0.5%
   - Mesure : Nombre de crashes / Nombre total de sessions
   - Fréquence : Continue, monitoring en temps réel
   - **Note** : Objectif amélioré pour une meilleure expérience utilisateur (standard mobile : <1%, objectif optimisé : <0.5%)

2. **Performance offline** : Fonctionnement correct sans réseau avec métriques précises
   - **Taux de réussite des opérations offline** : >95% des actions fonctionnent sans réseau
   - **Temps de chargement en cache** : <2s pour charger une enquête complète depuis le cache
   - **Taux de synchronisation** : >98% des données synchronisées avec succès après reconnexion
   - Fréquence : Tests réguliers et monitoring continu

3. **Performance batterie** : Enquête complète possible sur une charge (1h-1h30)
   - Objectif : Optimiser autant que possible la consommation batterie
   - Mesure : Consommation batterie pendant une enquête complète
   - Fréquence : Tests de performance réguliers
   - **Stratégies d'optimisation** : Mode économie d'énergie (réduction GPS en arrière-plan), préchargement intelligent des données, gestion des services en arrière-plan

4. **Précision géolocalisation** : <10m de précision
   - Mesure : Taux d'erreur géolocalisation <10%
   - Fréquence : Monitoring continu

5. **Performance générale** : Réactivité constante requise
   - Mesure : Temps de réponse des interactions utilisateur
   - Fréquence : Monitoring continu

### Measurable Outcomes

**Indicateurs de succès MVP :**

**Métriques utilisateurs :**
- Taux de complétion d'enquête : >80%
- Temps moyen par enquête : 1h-1h30
- Taux de conversion freemium : 15-20%
- Satisfaction utilisateur : >4/5 étoiles

**Métriques techniques :**
- Taux de crash : <0.5%
- Performance offline : >95% des actions fonctionnent sans réseau, <2s pour charger une enquête en cache, >98% de synchronisation réussie
- Performance batterie : Enquête complète sur une charge
- Taux d'erreur géolocalisation : <10%

**Métriques business :**
- Premiers revenus : 500€/mois à 3 mois
- Validation du modèle économique : Confirmation que le modèle freemium fonctionne

**Décision Go/No-Go pour V1.0 :**
- Si les critères de succès sont atteints → Procéder à V1.0 (expansion : plusieurs villes, tous types d'énigmes, gamification)
- Si les critères ne sont pas atteints → Itérer sur le MVP, identifier et résoudre les problèmes

**Indicateurs avancés (Leading Indicators) :**

Ces indicateurs permettent de détecter les problèmes tôt et d'anticiper les tendances :

- **Temps jusqu'à première conversion** : Temps moyen entre la première enquête gratuite et le premier achat
- **Nombre d'enquêtes avant premier achat** : Nombre moyen d'enquêtes complétées avant le premier achat
- **Taux de partage/recommandation** : % d'utilisateurs qui partagent ou recommandent l'application
- **Taux d'engagement avec la gamification** : % d'utilisateurs qui interagissent avec les badges, leaderboard
- **Taux d'utilisation des différents modes** : Répartition entre solo vs groupe (multi-téléphones vs game master)
- **Taux d'abandon par étape** : Identification des points de friction dans le parcours utilisateur

**Alignement stratégique :**

Toutes ces métriques sont alignées avec :
- **Vision produit** : Expérience complète et immersive de découverte de ville
- **Valeur utilisateur** : Plaisir, découverte, apprentissage
- **Objectifs business** : Viabilité économique et croissance
- **Phases de développement** : Plan MVP → V1.0 → V2.0 → V3.0

## User Journeys

### Journey 1: "Les Reconnectés" (Groupe d'Amis) - Happy Path

**Scène d'ouverture :**
- **Contexte** : 5 amis (25-30 ans) se retrouvent à Carcassonne après 6 mois sans se voir. Budget limité, recherche d'une activité abordable et amusante.
- **Émotion** : Excitement de se retrouver, frustration face aux prix élevés des activités.

**Étapes du parcours :**

**Étape 1 : Découverte**
- **Action** : Recherche d'activité sur smartphone, découverte de City Detectives via recommandation ou recherche.
- **Information** : "Escape game urbain, première enquête gratuite, 2,99€ par enquête".
- **Émotion** : Curiosité, intérêt.

**Étape 2 : Onboarding**
- **Action** : Téléchargement de l'app, création de compte rapide, découverte de la première enquête gratuite "Les Mystères de Carcassonne".
- **Information** : Explication du concept, LORE des détectives, interface simple.
- **Émotion** : Enthousiasme, impatience de commencer.

**Étape 3 : Démarrage de l'enquête**
- **Action** : Choix du mode (tous avec leur téléphone pour le leaderboard, ou 1 téléphone en mode game master). Si mode game master sélectionné, proposition d'un "pack groupe" (ex. 4,99€ pour jusqu'à 6 personnes) au lieu d'une seule enquête. Démarrage de l'enquête.
- **Information** : Carte de la ville, première énigme, instructions claires. Option pricing groupe clairement présentée pour le mode game master.
- **Émotion** : Excitement, anticipation, satisfaction du choix de pricing adapté au groupe.

**Étape 4 : Résolution des énigmes (Moment de valeur)**
- **Action** : Marche vers le premier lieu, résolution de l'énigme photo, découverte d'un fait historique surprenant, rires et collaboration.
- **Information** : Feedback positif, progression visible, découverte historique.
- **Émotion** : Plaisir, accomplissement, connexion.

**Étape 5 : Complétion et conversion**
- **Action** : Complétion de l'enquête en 1h15, découverte de plusieurs lieux historiques, satisfaction.
- **Information** : Badge de complétion, invitation à découvrir d'autres enquêtes, proposition d'achat.
- **Émotion** : Fierté, envie de continuer.

**Résolution :**
- **Nouvelle réalité** : Activité mémorable partagée, découverte de la ville, envie de refaire dans d'autres villes.
- **Action suivante** : Achat d'une autre enquête ou partage de l'expérience avec d'autres amis.

---

### Journey 2: "Le Défieur" (Joueur d'Escape Game) - Happy Path

**Scène d'ouverture :**
- **Contexte** : Thomas, 32 ans, amateur d'escape games, cherche un défi urbain de qualité. Frustré par les solutions existantes trop faciles.
- **Émotion** : Recherche de complexité, besoin de défi.

**Étapes du parcours :**

**Étape 1 : Découverte**
- **Action** : Recherche d'escape games urbains, découverte de City Detectives avec mention de 12 types d'énigmes et niveaux de difficulté.
- **Information** : "Énigmes variées, niveaux de difficulté, gamification complète".
- **Émotion** : Intérêt, espoir de trouver un vrai défi.

**Étape 2 : Onboarding et évaluation**
- **Action** : Téléchargement, test de la première enquête gratuite, évaluation de la difficulté et de la variété.
- **Information** : Aperçu des types d'énigmes, système de badges, leaderboard.
- **Émotion** : Curiosité, évaluation critique.

**Étape 3 : Sélection d'enquête**
- **Action** : Choix d'une enquête de difficulté moyenne/élevée, consultation des statistiques (taux de complétion, temps moyen).
- **Information** : Niveaux de difficulté, progression de compétences détective, badges disponibles.
- **Émotion** : Anticipation, excitation du défi.

**Étape 4 : Résolution d'énigme complexe (Moment de valeur)**
- **Action** : Résolution d'une énigme multi-étapes, utilisation de plusieurs compétences, découverte d'un fait historique inattendu.
- **Information** : Feedback de progression, badge obtenu, classement dans le leaderboard.
- **Émotion** : Accomplissement, fierté, satisfaction.

**Étape 5 : Progression et engagement**
- **Action** : Complétion de l'enquête, obtention de badges, consultation du classement, achat d'une enquête plus difficile.
- **Information** : Progression des compétences, collection de badges, nouveaux défis disponibles.
- **Émotion** : Motivation, envie de progresser.

**Résolution :**
- **Nouvelle réalité** : Défi satisfaisant, progression visible, collection de badges en cours.
- **Action suivante** : Exploration d'autres villes, participation aux défis hebdomadaires.

---

### Journey 3: "Les Explorateurs" (Famille avec Enfants) - Happy Path

**Scène d'ouverture :**
- **Contexte** : Famille Martin (parents 38-40 ans, enfants 8 et 12 ans) en visite à Toulouse. Recherche d'une activité éducative et amusante pour tous.
- **Émotion** : Besoin de trouver quelque chose qui plaise à tous, budget limité.

**Étapes du parcours :**

**Étape 1 : Découverte**
- **Action** : Recherche d'activité familiale, découverte de City Detectives via recommandation ou recherche.
- **Information** : "Activité familiale, première enquête gratuite, éducative et ludique".
- **Émotion** : Espoir, intérêt.

**Étape 2 : Onboarding en famille**
- **Action** : Téléchargement par les parents, découverte de la première enquête gratuite "Les Secrets de Toulouse", explication aux enfants. Sélection du mode "Famille" qui adapte automatiquement la difficulté selon l'âge des enfants.
- **Information** : Interface simple, énigmes adaptées aux enfants (mode famille ajuste la difficulté), système d'aide parentale avec indices progressifs (suggestions sans spoiler).
- **Émotion** : Enthousiasme des enfants, confiance des parents, sentiment que l'activité est adaptée à tous.

**Étape 3 : Démarrage de l'enquête**
- **Action** : Choix du mode (1 téléphone avec parents comme guides), démarrage de l'enquête, enfants participent activement.
- **Information** : Carte interactive, énigmes visuelles, explications historiques adaptées.
- **Émotion** : Excitement des enfants, satisfaction des parents.

**Étape 4 : Découverte et apprentissage (Moment de valeur)**
- **Action** : Marche vers un monument, résolution d'une énigme photo par les enfants (avec aide parentale si nécessaire via système d'indices progressifs), découverte d'un fait historique surprenant, discussion familiale.
- **Information** : Explications historiques adaptées à l'âge, photos avant/après, anecdotes. Système d'aide parentale : indices progressifs (suggestion → indice → solution) pour éviter les spoilers tout en aidant.
- **Émotion** : Émerveillement des enfants, fierté des parents, connexion familiale, sentiment d'accomplissement partagé.

**Étape 5 : Complétion et souvenirs**
- **Action** : Complétion de l'enquête, photos de famille aux lieux découverts, discussion sur ce qui a été appris.
- **Information** : Badge de complétion familiale, carte postale virtuelle, invitation à découvrir d'autres villes.
- **Émotion** : Satisfaction, création de souvenirs, envie de continuer.

**Résolution :**
- **Nouvelle réalité** : Activité mémorable, apprentissage partagé, souvenirs créés.
- **Action suivante** : Envie de découvrir d'autres villes en famille, partage de l'expérience avec d'autres familles.

---

### Journey 4: "Le Curieux" (Touriste) - Happy Path

**Scène d'ouverture :**
- **Contexte** : Sophie, 45 ans, touriste à Bordeaux pour 2 jours. Veut découvrir la ville et son histoire, sans contrainte d'horaire.
- **Émotion** : Curiosité, besoin de flexibilité, recherche d'une alternative aux visites guidées.

**Étapes du parcours :**

**Étape 1 : Découverte**
- **Action** : Recherche d'activité pour découvrir Bordeaux, découverte de City Detectives via recherche ou recommandation.
- **Information** : "Découverte de ville, première enquête gratuite, à votre rythme".
- **Émotion** : Intérêt, espoir d'une expérience flexible.

**Étape 2 : Onboarding**
- **Action** : Téléchargement, découverte de la première enquête gratuite "Les Mystères de Bordeaux", aperçu du parcours.
- **Information** : Enquête guidée, points d'intérêt historiques, durée estimée, possibilité de pause.
- **Émotion** : Curiosité, anticipation.

**Étape 3 : Démarrage de l'enquête**
- **Action** : Démarrage à son rythme, consultation de la carte, première énigme géolocalisation.
- **Information** : Carte interactive, points d'intérêt, explications historiques, possibilité de revenir en arrière.
- **Émotion** : Excitement, sentiment de liberté.

**Étape 4 : Découverte historique (Moment de valeur)**
- **Action** : Arrivée à un monument, résolution d'une énigme, découverte d'un fait historique surprenant, connexion émotionnelle avec le lieu.
- **Information** : Explications détaillées, photos historiques, anecdotes, contexte culturel.
- **Émotion** : Émerveillement, connexion avec la ville, satisfaction d'apprendre.

**Étape 5 : Complétion et recommandation**
- **Action** : Complétion de l'enquête, visite de plusieurs points d'intérêt, découverte de l'histoire de Bordeaux, satisfaction.
- **Information** : Badge de complétion, résumé des découvertes, invitation à découvrir d'autres villes.
- **Émotion** : Satisfaction, envie de partager, connexion avec la ville.

**Résolution :**
- **Nouvelle réalité** : Découverte enrichie de la ville, apprentissage ludique, flexibilité appréciée.
- **Action suivante** : Recommandation à d'autres touristes, envie de découvrir d'autres villes avec City Detectives.

---

### Journey 5: Admin/Opérations - Gestion du contenu et monitoring

**Scène d'ouverture :**
- **Contexte** : Équipe City Detectives, besoin de gérer le contenu (enquêtes, énigmes) et de monitorer les performances de l'application.
- **Émotion** : Besoin d'efficacité, contrôle qualité, visibilité sur les performances.

**Étapes du parcours :**

**Étape 1 : Accès au dashboard**
- **Action** : Connexion au dashboard admin, vue d'ensemble des métriques clés.
- **Information** : Revenus (MRR), nombre d'utilisateurs actifs, taux de complétion, villes disponibles.
- **Émotion** : Besoin de visibilité, contrôle.

**Étape 2 : Gestion du contenu**
- **Action** : Création/modification d'une enquête, ajout d'énigmes, validation du contenu historique.
- **Information** : Éditeur d'enquêtes, templates d'énigmes, validation de contenu, prévisualisation.
- **Émotion** : Efficacité, contrôle qualité.

**Étape 3 : Monitoring des performances**
- **Action** : Consultation des métriques techniques (taux de crash, performance offline, géolocalisation), identification des problèmes.
- **Information** : Dashboard de monitoring, alertes automatiques, logs d'erreurs, métriques en temps réel.
- **Émotion** : Vigilance, besoin de réactivité.

**Étape 4 : Analyse des données utilisateurs**
- **Action** : Analyse des parcours utilisateurs, identification des points de friction, optimisation des enquêtes.
- **Information** : Analytics détaillés, heatmaps, taux d'abandon, feedback utilisateurs.
- **Émotion** : Compréhension, besoin d'amélioration continue.

**Étape 5 : Publication et validation**
- **Action** : Publication d'une nouvelle enquête, validation des tests, activation pour les utilisateurs.
- **Information** : Workflow de publication, tests de validation, rollback possible.
- **Émotion** : Satisfaction, contrôle qualité.

**Résolution :**
- **Nouvelle réalité** : Gestion efficace du contenu, visibilité sur les performances, amélioration continue.
- **Action suivante** : Optimisation continue, expansion du catalogue, amélioration de l'expérience utilisateur.

---

### Journey 6: Parcours de Récupération - Abandon et Retour

**Scène d'ouverture :**
- **Contexte** : Utilisateur qui a commencé une enquête mais l'a abandonnée (blocage sur une énigme, interruption, problème technique).
- **Émotion** : Frustration, sentiment d'échec, hésitation à revenir.

**Étapes du parcours :**

**Étape 1 : Détection de l'abandon**
- **Action** : Système détecte l'inactivité prolongée ou l'abandon explicite (fermeture de l'app).
- **Information** : Sauvegarde automatique de la progression, enregistrement du point d'abandon.
- **Émotion** : (Système) Identification du problème.

**Étape 2 : Notification de rappel (si applicable)**
- **Action** : Notification push (optionnelle) après 24-48h : "Vous étiez à mi-parcours de l'enquête 'Les Mystères de Carcassonne'. Voulez-vous continuer ?"
- **Information** : Rappel de la progression, point d'abandon, temps écoulé.
- **Émotion** : (Utilisateur) Rappel bienveillant, pas de pression.

**Étape 3 : Retour à l'enquête**
- **Action** : Réouverture de l'app, affichage de l'enquête en cours, option de reprendre ou recommencer.
- **Information** : Progression sauvegardée, point d'abandon clairement indiqué, option d'aide contextuelle.
- **Émotion** : (Utilisateur) Sentiment de contrôle, possibilité de reprendre facilement.

**Étape 4 : Aide contextuelle (si blocage)**
- **Action** : Si l'utilisateur était bloqué, proposition d'aide contextuelle : indices progressifs, suggestion de révision des indices précédents, ou option de sauter temporairement (avec pénalité de score si applicable).
- **Information** : Système d'aide adaptatif, pas de spoiler direct, encouragement.
- **Émotion** : (Utilisateur) Sentiment d'être aidé sans être gâché, motivation à continuer.

**Étape 5 : Complétion ou nouvelle tentative**
- **Action** : Soit complétion réussie avec aide, soit nouvelle tentative avec meilleure compréhension.
- **Information** : Feedback positif, badge de persévérance (si applicable), progression sauvegardée.
- **Émotion** : (Utilisateur) Accomplissement, satisfaction d'avoir surmonté le défi.

**Résolution :**
- **Nouvelle réalité** : Utilisateur réengagé, progression sauvegardée, sentiment de support plutôt que d'abandon.
- **Action suivante** : Continuation de l'enquête ou exploration d'autres enquêtes avec confiance renouvelée.

**Métriques de parcours alignées avec KPIs :**
- **Taux d'abandon par étape** : Identification des points de friction (énigmes difficiles, problèmes techniques)
- **Taux de retour après abandon** : % d'utilisateurs qui reviennent après avoir abandonné
- **Temps jusqu'à reprise** : Temps moyen entre abandon et reprise
- **Taux de complétion après reprise** : % d'utilisateurs qui complètent après avoir repris
- **Utilisation de l'aide contextuelle** : Fréquence d'utilisation des indices et impact sur la complétion

---

### Journey Requirements Summary

Les parcours utilisateurs révèlent les capacités fonctionnelles suivantes nécessaires pour City Detectives :

**Capacités d'onboarding :**
- Téléchargement et installation de l'application mobile
- Création de compte rapide et simple
- Découverte de la première enquête gratuite
- Explication du concept et du LORE des détectives
- Interface intuitive et accessible

**Capacités de jeu et navigation :**
- Sélection de mode de jeu (solo, groupe multi-téléphones, game master)
- Navigation entre les énigmes avec carte interactive
- Affichage de la progression dans l'enquête
- Feedback visuel et positif à chaque étape
- Système de pause et reprise
- Sauvegarde automatique de la progression
- Système de récupération après abandon

**Capacités d'énigmes :**
- 4-5 types d'énigmes de base (photo, géolocalisation, mots, puzzles, audio optionnel)
- Validation des réponses et énigmes
- Aide contextuelle si l'utilisateur bloque (indices progressifs : suggestion → indice → solution)
- Explications historiques et éducatives
- Adaptation de la difficulté selon le mode (famille, solo, groupe)
- Système d'aide parentale pour mode famille (indices progressifs sans spoiler)

**Capacités de gamification :**
- Système de badges et accomplissements
- Leaderboard (pour mode compétitif)
- Progression de compétences détective
- Collection de cartes postales virtuelles

**Capacités de monétisation :**
- Première enquête gratuite (freemium)
- Affichage et achat d'enquêtes supplémentaires
- Intégration paiement (App Store, Google Play)
- Gestion des packs et promotions
- Pricing groupe pour mode game master (pack groupe : ex. 4,99€ pour jusqu'à 6 personnes)
- Proposition d'achat pendant l'enquête (optionnel : "Débloquez la suite")

**Capacités techniques :**
- Mode offline fonctionnel
- Géolocalisation précise (<10m)
- Optimisation batterie
- Synchronisation des données

**Capacités admin/opérations :**
- Dashboard de gestion du contenu
- Éditeur d'enquêtes et d'énigmes
- Monitoring des performances techniques
- Analytics et métriques utilisateurs
- Workflow de publication et validation
- Métriques de parcours (taux d'abandon par étape, taux de retour après abandon, temps jusqu'à reprise)
- Alignement des métriques de parcours avec les KPIs définis dans les critères de succès

---

## Innovation & Novel Patterns

### Detected Innovation Areas

City Detectives présente plusieurs aspects innovants qui le différencient des solutions existantes :

**1. IA pour création de contenu à grande échelle**
- **Innovation** : Utilisation de l'IA assistée pour créer des énigmes de qualité à grande échelle, permettant une expansion rapide tout en maintenant la qualité
- **Hypothèse remise en question** : "On ne peut pas créer des énigmes variées et de qualité sans visiter les villes physiquement"
- **Différenciation** : Résout le problème principal des solutions existantes (manque de villes, contenu répétitif) en permettant la création de contenu de qualité pour de nombreuses villes sans nécessiter de présence physique

**2. LORE et immersion narrative**
- **Innovation** : Création d'un univers narratif autour des détectives qui plonge l'utilisateur dans l'expérience, au-delà d'une simple application de quizz
- **Hypothèse remise en question** : "Les escape games urbains doivent être simples et répétitifs, sans véritable histoire"
- **Différenciation** : Expérience immersive avec un LORE cohérent qui crée une connexion émotionnelle avec l'utilisateur et la ville

**3. Combinaison escape game urbain + découverte patrimoniale**
- **Innovation** : Fusion réussie entre gameplay ludique (escape game) et valeur éducative (découverte du patrimoine et de l'histoire)
- **Hypothèse remise en question** : "L'apprentissage doit être séparé du divertissement"
- **Différenciation** : Apprentissage ludique et engageant qui ne sacrifie ni le fun ni la valeur éducative

**4. Mode offline avec géolocalisation précise**
- **Innovation** : Fonctionnement complet offline avec géolocalisation précise (<10m), optimisé pour la batterie
- **Hypothèse remise en question** : "Les applications de géolocalisation nécessitent une connexion constante"
- **Différenciation** : Expérience fluide même dans des zones sans réseau, avec optimisation batterie pour permettre une enquête complète (1h-1h30) sur une charge

**5. Expertise technique combinée à la création de contenu**
- **Innovation** : Combinaison unique de capacité de développement technique (Flutter, offline, performance) et processus de création de contenu assisté par IA
- **Différenciation** : Capacité à produire une grande quantité d'énigmes variées et de qualité avec une expérience utilisateur technique supérieure

### Market Context & Competitive Landscape

**Solutions existantes :**
- **Questo** : Application d'escape game urbain avec limitations (couverture géographique limitée, expérience peu immersive, énigmes peu variées, pas de test avant achat)
- **Autres applications de tourisme** : Visites guidées classiques (coûteuses, rigides, peu interactives)

**Positionnement innovant :**
- City Detectives se positionne comme la première solution à combiner :
  - IA pour création de contenu à grande échelle
  - LORE et immersion narrative
  - Expérience technique supérieure (offline, géolocalisation précise, optimisation batterie)
  - Modèle freemium avec première enquête gratuite

**Pourquoi maintenant :**
- L'émergence de l'IA rend possible la création de contenu de qualité à grande échelle
- La technologie mobile permet enfin de combiner qualité technique (offline, géolocalisation) et expérience utilisateur fluide
- Le marché est prêt pour des expériences plus immersives et narratives dans le tourisme

### Validation Approach

**Validation des aspects innovants :**

**1. IA pour création de contenu :**
- **Tests de qualité** : Validation manuelle de chaque enquête créée par IA (vérification historique, cohérence, variété)
- **Métriques** : Taux d'erreurs historiques, satisfaction utilisateurs sur la qualité des énigmes, variété perçue
- **Processus** : Templates structurés, validation par étapes, amélioration continue basée sur les retours
- **Processus scalable** : Validation en deux étapes pour assurer la scalabilité :
  - **Phase MVP** : Validation rapide pour 1 ville (processus manuel complet pour valider l'approche)
  - **Phase Expansion** : Processus optimisé et automatisé pour l'expansion (validation par étapes, templates améliorés, outils d'aide à la validation)

**2. LORE et immersion :**
- **Tests utilisateurs** : Mesure de l'engagement avec le LORE (temps passé, taux de complétion, retours qualitatifs)
- **Métriques** : Taux de complétion d'enquête (>80%), satisfaction utilisateur (>4/5 étoiles), mentions du LORE dans les avis
- **Validation** : Tests A/B sur l'impact du LORE sur l'engagement et la rétention
- **Flexibilité utilisateur** : Option de sauter le LORE pour les utilisateurs qui préfèrent aller directement aux énigmes (mesure de l'adoption de cette option)

**3. Mode offline + géolocalisation :**
- **Tests techniques** : Validation du fonctionnement offline complet, précision géolocalisation (<10m), consommation batterie
- **Métriques** : Taux de réussite des opérations offline (>95%), précision géolocalisation (<10% d'erreur), enquête complète sur une charge
- **Tests utilisateurs** : Expérience dans différentes conditions (zones sans réseau, différents appareils, conditions météo)
- **Cache intelligent** : Système de cache optimisé pour équilibrer performance et espace de stockage :
  - Préchargement automatique des enquêtes disponibles dans la ville actuelle
  - Téléchargement manuel optionnel pour d'autres villes
  - Gestion intelligente de l'espace de stockage (nettoyage automatique des enquêtes complétées si nécessaire)

**4. Expérience complète :**
- **Validation MVP** : Tests end-to-end avec utilisateurs réels sur le MVP (1 ville, 1 enquête)
- **Métriques** : Taux de complétion (>80%), temps moyen (1h-1h30), taux de conversion freemium (15-20%), satisfaction (>4/5 étoiles)
- **Décision Go/No-Go** : Si critères atteints → V1.0, sinon → itération sur MVP

**Indicateurs avancés d'innovation :**
- **Taux d'adoption des fonctionnalités innovantes** : % d'utilisateurs qui utilisent les fonctionnalités innovantes (LORE, mode offline, etc.)
- **Impact sur la rétention** : Comparaison de la rétention entre utilisateurs qui adoptent les innovations vs ceux qui ne les adoptent pas
- **Différenciation perçue** : Mesure de la perception des utilisateurs sur ce qui rend City Detectives unique (enquêtes, avis, feedback)
- **Taux d'utilisation du mode offline** : % d'utilisateurs qui utilisent le mode offline, impact sur la satisfaction
- **Engagement avec le LORE** : Temps passé avec les éléments narratifs, taux de saut du LORE, impact sur la complétion

### Risk Mitigation

**Risques identifiés et stratégies de mitigation :**

**1. Risque : Qualité du contenu IA (hallucinations, erreurs historiques)**
- **Mitigation** :
  - Processus de validation manuelle systématique de chaque enquête
  - Templates structurés pour guider la génération IA
  - Sources historiques fiables et vérifiables
  - Tests utilisateurs pour détecter les erreurs
  - Système de feedback et correction continue
  - **Processus scalable** : Validation en deux étapes (rapide pour MVP, optimisée pour expansion) pour éviter le goulot d'étranglement lors de l'expansion

**2. Risque : Complexité technique (offline + géolocalisation)**
- **Mitigation** :
  - Architecture technique solide (Flutter, patterns éprouvés)
  - Tests approfondis dans différentes conditions
  - Monitoring continu des performances techniques
  - Fallbacks en cas de problème (messages d'erreur clairs, récupération gracieuse)
  - Objectifs techniques mesurables (taux de crash <0.5%, précision <10m)

**3. Risque : Adoption utilisateur du LORE**
- **Mitigation** :
  - Tests utilisateurs pour valider l'engagement avec le LORE
  - Option de sauter les éléments narratifs si nécessaire (flexibilité) - permet aux utilisateurs qui préfèrent aller directement aux énigmes
  - Mesure de l'impact du LORE sur les métriques clés (complétion, rétention)
  - Itération basée sur les retours utilisateurs
  - Mesure du taux d'adoption de l'option "sauter le LORE" pour comprendre les préférences utilisateurs

**4. Risque : Scalabilité de la création de contenu**
- **Mitigation** :
  - Processus structuré et reproductible avec IA
  - Templates et outils pour accélérer la création
  - Validation progressive (commencer avec 1 ville, puis expansion)
  - Partenariats futurs avec offices de tourisme pour création locale

**5. Risque : Concurrence et copie**
- **Mitigation** :
  - Avantage de pionnier (premier sur le marché avec cette approche)
  - Barrière à l'entrée : combinaison IA + expertise technique + LORE
  - Focus sur la qualité et l'expérience complète plutôt que sur des fonctionnalités isolées
  - Expansion rapide du catalogue grâce à l'IA
  - **Stratégie face aux "fast followers"** : Maintenir l'avantage grâce à :
    - Processus de création de contenu optimisé et scalable
    - Qualité supérieure validée par les utilisateurs
    - LORE cohérent et immersif difficile à copier
    - Expérience technique supérieure (offline, géolocalisation, batterie)

**Stratégie de fallback :**
- Si l'IA ne produit pas de contenu de qualité suffisante → Processus manuel avec validation rigoureuse
- Si le LORE ne fonctionne pas → Focus sur la qualité des énigmes et l'expérience technique
- Si les contraintes techniques sont trop complexes → Simplification progressive, focus sur le core value

---

## Mobile App Specific Requirements

### Project-Type Overview

City Detectives est une application mobile cross-platform développée avec Flutter, ciblant iOS et Android. L'application combine géolocalisation précise, mode offline, et fonctionnalités multimédias (photo, audio) pour offrir une expérience d'escape game urbain immersive.

### Technical Architecture Considerations

**Framework et plateformes :**
- **Framework** : Flutter (cross-platform)
- **Plateformes cibles** : iOS et Android
- **Rationale** : Développement unique pour les deux plateformes, réduction des coûts de développement et de maintenance

**Architecture technique :**
- Architecture offline-first avec synchronisation intelligente
- Cache local pour données essentielles (enquêtes, énigmes, médias)
- Géolocalisation précise avec fallbacks pour zones à faible précision
- Optimisation batterie intégrée (mode économie d'énergie, gestion GPS en arrière-plan)

### Platform Requirements

**iOS :**
- Version minimale : iOS 13.0 ou supérieur
- Compatibilité : iPhone et iPad
- Appareils cibles : iPhone 8 et supérieurs (pour performance optimale)
- Support iPad : Interface adaptée pour tablettes (optionnel pour MVP)

**Android :**
- Version minimale : Android 8.0 (API level 26) ou supérieur
- Compatibilité : Smartphones et tablettes Android
- Appareils cibles : Appareils avec au moins 2GB RAM (pour performance optimale)

**Considérations de performance :**
- Optimisation pour différents types d'appareils (bas de gamme à haut de gamme)
- Gestion de la mémoire pour éviter les crashes
- Tests sur différents appareils et versions OS

### Device Permissions

**Permissions requises (obligatoires) :**

1. **Localisation (GPS)** : **CRITIQUE**
   - Usage : Géolocalisation précise pour validation des énigmes basées sur la localisation
   - Précision requise : <10m
   - Gestion : Demande de permission au démarrage de la première enquête nécessitant la géolocalisation, avec explication claire de la nécessité ("Pour valider que vous êtes au bon endroit")
   - Fallback : Message d'erreur clair si permission refusée ou précision insuffisante
   - **Mode alternatif** : Si permission refusée, proposer un mode alternatif si possible (énigmes non basées sur géolocalisation) ou expliquer que l'application nécessite la géolocalisation pour fonctionner

2. **Caméra** : **CRITIQUE**
   - Usage : Prise de photos pour énigmes photo
   - Gestion : Demande de permission lors de la première énigme photo
   - Fallback : Option d'utiliser une photo existante de la galerie si permission refusée

3. **Stockage** : **CRITIQUE**
   - Usage : Cache des données offline (enquêtes, énigmes, médias)
   - Gestion : Stockage interne de l'application
   - Considérations : Gestion de l'espace de stockage (nettoyage automatique des enquêtes complétées si nécessaire)

**Permissions optionnelles :**

4. **Accès aux photos (galerie)** : **OPTIONNEL**
   - Usage : Utilisation de photos existantes pour certains types d'énigmes
   - Gestion : Demande de permission si fonctionnalité utilisée
   - Rationale : Peut être intéressant pour certains types de jeux/énigmes

**Permissions non nécessaires :**
- Notifications : Pas nécessaire pour le MVP (push notifications gérées via système de notifications push, pas besoin de permission notification système)

### Offline Mode

**Stratégie offline :**

**Fonctionnement offline complet :**
- Toutes les fonctionnalités essentielles fonctionnent sans réseau
- Cache intelligent des données nécessaires :
  - Enquêtes complètes (énigmes, médias, explications historiques)
  - Carte interactive de la ville
  - Progression et sauvegarde locale
  - Données de géolocalisation (coordonnées des points d'intérêt)

**Communication du statut offline :**
- **Indicateur visuel discret** : Indicateur en haut de l'écran montrant le statut de connexion (offline/online)
- **Gestion des actions nécessitant le réseau** : Messages clairs si une action nécessite le réseau (ex. achat d'enquête, synchronisation)
- **Transparence** : L'utilisateur sait toujours s'il est en mode offline et quelles actions sont disponibles

**Préchargement et cache :**
- **Préchargement automatique** : Enquêtes disponibles dans la ville actuelle préchargées automatiquement
- **Téléchargement manuel** : Option de téléchargement manuel pour d'autres villes
- **Gestion de l'espace** : Nettoyage automatique des enquêtes complétées si espace limité (optionnel, avec confirmation utilisateur)

**Synchronisation :**
- Synchronisation automatique en arrière-plan lors de la reconnexion
- Taux de synchronisation réussie : >98%
- **Gestion des conflits** :
  - **MVP** : Stratégie "dernière modification gagne" (simple et suffisant pour MVP)
  - **V1.0+** : Système plus robuste avec versioning ou merge intelligent si nécessaire (quand système social/multi-utilisateurs sera implémenté)

**Métriques offline :**
- Taux de réussite des opérations offline : >95%
- Temps de chargement en cache : <2s pour charger une enquête complète
- Taux de synchronisation : >98% après reconnexion

### Push Strategy

**Notifications push :**

**Types de notifications :**

**Priorisation MVP (3 types essentiels) :**

1. **Nouvelles enquêtes dans votre ville** : **MVP**
   - Déclencheur : Nouvelle enquête disponible dans une ville que l'utilisateur a visitée ou marquée comme favorite
   - Fréquence : Au moment de la publication
   - Valeur : Découverte de nouveau contenu local

2. **Rappels d'enquête en cours** : **MVP**
   - Déclencheur : Enquête commencée mais non complétée depuis plusieurs jours (ex. 3-7 jours)
   - Fréquence : Une fois par semaine maximum
   - Valeur : Réengagement, aide à la complétion

3. **Nouvelles villes disponibles dans votre région** : **MVP**
   - Déclencheur : Nouvelle ville disponible à proximité (basé sur géolocalisation)
   - Fréquence : Au moment de la publication
   - Valeur : Découverte de nouvelles destinations

**Reportées à V1.0+ (nécessitent système social) :**

4. **Scores de vos amis** : **V1.0+**
   - Déclencheur : Un ami complète une enquête ou bat votre score
   - Fréquence : En temps réel ou batch quotidien
   - Valeur : Engagement social, compétition amicale
   - **Note** : Nécessite système social/amis (non disponible en MVP)

5. **Badges obtenus par des amis** : **V1.0+**
   - Déclencheur : Un ami obtient un badge rare ou intéressant
   - Fréquence : Limité (seulement badges rares/importants)
   - Valeur : Engagement social, découverte de nouveaux défis
   - **Note** : Nécessite système social/amis (non disponible en MVP)

6. **Défis hebdomadaires** : **V1.0+**
   - Déclencheur : Nouveau défi hebdomadaire disponible
   - Fréquence : Hebdomadaire
   - Valeur : Engagement continu, contenu limité dans le temps
   - **Note** : Fonctionnalité future, pas dans le scope MVP

**Stratégie de notification :**
- **Opt-in** : Utilisateurs peuvent activer/désactiver chaque type de notification
- **Fréquence limitée** : Pas de spam, notifications pertinentes uniquement
- **Personnalisation** : Paramètres utilisateur pour contrôler les notifications
- **Respect de la vie privée** : Pas de notifications intrusives, respect des préférences utilisateur
- **Onboarding notifications** : Écran d'onboarding expliquant la valeur de chaque type de notification lors de la première demande pour améliorer le taux d'opt-in

**Implémentation technique :**
- Service de notifications push (Firebase Cloud Messaging pour Android, Apple Push Notification Service pour iOS)
- Gestion des tokens et abonnements
- Segmentation des utilisateurs pour notifications ciblées
- Analytics sur l'engagement avec les notifications

### Store Compliance

**Conformité App Store (iOS) :**

**Guidelines Apple à respecter :**
- **Guidelines de contenu** : Contenu approprié pour tous les âges (familles incluses)
- **Politique de confidentialité** : Politique de confidentialité claire et accessible
- **Permissions** : Justification claire de chaque permission demandée
- **Paiements in-app** : Utilisation du système de paiement Apple (IAP) pour les achats d'enquêtes
- **Performance** : Application stable, pas de crashes, performance optimale
- **Métadonnées** : Description claire, screenshots, vidéo de démonstration (recommandé)

**Exigences spécifiques :**
- Politique de confidentialité accessible depuis l'app
- Explication claire de l'utilisation de la géolocalisation
- Conformité avec les règles de collecte de données (RGPD si applicable)

**Conformité Google Play (Android) :**

**Politiques Google à respecter :**
- **Politique de contenu** : Contenu approprié, pas de contenu offensant
- **Politique de confidentialité** : Politique de confidentialité claire et accessible
- **Permissions** : Justification claire de chaque permission, demande au moment approprié
- **Paiements in-app** : Utilisation du système de paiement Google Play Billing pour les achats d'enquêtes
- **Performance** : Application stable, optimisation pour différents appareils
- **Métadonnées** : Description claire, screenshots, vidéo de démonstration (recommandé)

**Exigences spécifiques :**
- Politique de confidentialité accessible depuis l'app
- Explication claire de l'utilisation de la géolocalisation
- Conformité avec les règles de collecte de données (RGPD si applicable)
- Gestion des permissions Android (demande au moment approprié, pas au démarrage)

**Considérations communes :**
- **RGPD** : Conformité avec le Règlement Général sur la Protection des Données (collecte de données, consentement, droit à l'oubli)
- **Accessibilité** : Respect des guidelines d'accessibilité (optionnel pour MVP, recommandé pour V1.0)
- **Localisation** : Support multilingue (français pour MVP, autres langues pour expansion)

### Implementation Considerations

**Développement :**
- **Flutter** : Utilisation de Flutter pour développement cross-platform
- **Packages clés** : 
  - Géolocalisation : `geolocator` ou équivalent
  - Offline storage : `sqflite` ou `hive` pour cache local
  - Push notifications : `firebase_messaging` pour notifications push
  - Paiements : `in_app_purchase` pour achats in-app
  - Caméra : `camera` ou `image_picker` pour photos

**Tests :**
- Tests sur différents appareils iOS et Android
- Tests de performance (batterie, mémoire, CPU)
- Tests offline dans différentes conditions
- Tests de géolocalisation dans différents environnements (urbain, intérieur, extérieur)
- Tests de conformité stores (guidelines Apple et Google)
- **Tests cross-platform** : Tests spécifiques pour identifier les différences de comportement entre iOS et Android (GPS, permissions, performance)

**Métriques de permissions :**
- **Taux d'acceptation des permissions** : Mesurer le taux d'acceptation pour chaque permission (GPS, caméra, stockage)
- **Impact sur l'expérience** : Analyser l'impact sur l'expérience utilisateur si permissions refusées (taux de complétion, satisfaction)
- **Optimisation continue** : Utiliser les métriques pour améliorer le timing et l'explication des demandes de permissions

**Déploiement :**
- Processus de soumission App Store et Google Play
- **Planning de review** : Prévoir 1-2 semaines pour le premier review App Store/Google Play (peut impacter le planning de lancement)
- **Gestion des rejets** : Processus pour gérer les rejets de soumission (corrections, re-soumission)
- Gestion des versions et mises à jour
- Monitoring des performances et crashes en production
- Analytics et métriques utilisateurs

---

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach : Experience MVP**

City Detectives suit une approche **Experience MVP** : valider l'expérience complète (LORE + énigmes + géolocalisation) pour s'assurer que l'expérience utilisateur est engageante et que le modèle économique fonctionne.

**Rationale :**
- L'expérience complète est essentielle pour différencier City Detectives des solutions existantes
- Le LORE et l'immersion narrative sont des éléments clés de différenciation
- La validation de l'expérience utilisateur est prioritaire pour valider le concept
- Le modèle économique (freemium + conversion) doit être validé dès le MVP

**Objectifs de validation MVP :**
1. **Expérience utilisateur engageante** : Les utilisateurs trouvent l'expérience fun et immersive
2. **Modèle économique fonctionnel** : Le modèle freemium génère des conversions (15-20%)
3. **Qualité du contenu IA** : Le contenu généré par IA est de qualité suffisante

**Métriques de validation MVP :**

Pour valider chaque objectif, métriques spécifiques :

1. **Expérience utilisateur engageante :**
   - Taux de complétion d'enquête : >80%
   - Temps moyen par enquête : 1h-1h30
   - Satisfaction utilisateur : >4/5 étoiles
   - Taux de retour : % d'utilisateurs qui reviennent pour une autre enquête
   - Mentions du LORE dans les avis : Qualitatif

2. **Modèle économique fonctionnel :**
   - Taux de conversion freemium : 15-20% (mesuré via tracking de propension à payer si paiement simulé)
   - Taux de clics sur "Acheter" : Mesure de la propension à payer
   - Taux d'abandon au moment du paiement : Identifier les frictions

3. **Qualité du contenu IA :**
   - Taux d'erreurs historiques : <5% (validation manuelle)
   - Satisfaction utilisateurs sur la qualité des énigmes : >4/5 étoiles
   - Variété perçue : Feedback qualitatif sur la variété des énigmes
   - Taux de complétion : >80% (indicateur de qualité et engagement)

**Resource Requirements :**
- **Équipe MVP** : Développeur solo (vibecoding avec BMAD Method)
- **Compétences nécessaires** : Flutter, géolocalisation, développement mobile
- **Timeline** : Flexible (projet personnel en dehors du travail)
- **Contenu** : Création de contenu assistée par IA avec validation manuelle

### MVP Feature Set (Phase 1)

**Core User Journeys Supported :**

Le MVP supporte les parcours essentiels pour valider l'expérience :

1. **"Le Curieux" (Touriste) - Happy Path** : Parcours principal pour valider l'expérience complète
2. **"Le Défieur" (Joueur d'Escape Game) - Happy Path** : Parcours pour valider la qualité des énigmes
3. **Parcours de récupération (abandon)** : Support basique pour réengagement

**Note :** Les parcours "Les Reconnectés" (groupe) et "Les Explorateurs" (famille) nécessitent des fonctionnalités sociales/groupes qui sont reportées à V1.0.

**Communication aux utilisateurs :**
- Clarifier clairement que le MVP est solo uniquement (pas de modes groupe/famille)
- Éviter la déception en communiquant clairement les limitations du MVP
- Présenter les fonctionnalités groupe comme "à venir" pour maintenir l'engagement

**Must-Have Capabilities :**

1. **1 enquête complète dans 1 ville** - LORE essentiel (base solide mais simplifiée)
2. **4-5 types d'énigmes de base** (photo, géolocalisation, mots, puzzles, audio optionnel)
3. **Géolocalisation fonctionnelle** (<10m précision)
4. **Interface simple et intuitive** avec LORE des détectives
5. **Système de progression basique**
6. **Première enquête gratuite (freemium)** - Paiement peut être simulé pour MVP
   - **Tracking de propension à payer** : Système de tracking des "clics d'achat" même avec paiement simulé pour mesurer la propension à payer
   - **Métrique** : Taux de clics sur "Acheter" même si transaction non réelle
7. **Fonctionnement online** (mode offline reporté à V1.0 - pas critique pour MVP)
   - **Gestion zones sans réseau** : Messages d'erreur clairs si réseau indisponible, ou limitation géographique des tests MVP aux zones avec réseau
   - **Architecture extensible** : Structure de données qui facilite l'ajout de l'offline plus tard (séparation données/cache, pas de dépendances réseau hardcodées)
   - **Communication utilisateur** : Clarifier que le MVP nécessite une connexion réseau

### Post-MVP Features

**Phase 2: Growth (V1.0)**
- Mode offline complet
- Tous les 12 types d'énigmes (QR codes, AR, chronologie, comparaison, mathématiques, observation, codes secrets)
- Gamification complète (badges, leaderboard, compétences détective, collection cartes postales)
- Plusieurs villes (3-5 villes avec 2-3 enquêtes chacune)
- Modes groupe (multi-téléphones, game master, familles)
- Push notifications (3 types essentiels)
- Système de paiement complet (App Store, Google Play)
- Optimisation batterie avancée

**Phase 3: Expansion (V2.0+)**
- Histoires croisées régionales (fil rouge entre villes)
- AR (voyage dans le temps)
- Créateur d'énigmes pour offices de tourisme
- Partenariats (musées, commerçants locaux)
- Défis hebdomadaires
- Énigmes saisonnières
- Intégration événements locaux

**Phase 4: Vision (V3.0+)**
- Plateforme de découverte urbaine leader en France (50+ villes, 200+ enquêtes)
- Écosystème de partenaires (offices de tourisme créant leurs propres enquêtes)
- Expansion internationale (villes européennes)
- Mode créateur pour utilisateurs avancés
- Impact social et éducatif (préservation patrimoine, éducation ludique)

### Risk Mitigation Strategy

**Technical Risks :** 
- Architecture solide (Flutter, patterns éprouvés)
- Simplification MVP (offline reporté) avec architecture extensible pour faciliter l'ajout de l'offline plus tard
- Processus scalable pour contenu IA (validation en deux étapes : rapide MVP, optimisée expansion)
- Gestion zones sans réseau : Messages d'erreur clairs ou limitation géographique des tests MVP

**Market Risks :** Première enquête gratuite, expérience engageante, validation modèle économique

**Resource Risks :** Scope MVP réaliste, timeline flexible, utilisation IA pour contenu

---

## Functional Requirements

**CRITICAL : Cette section définit LE CONTRAT DE CAPACITÉS pour tout le travail en aval.**
- Les designers UX ne concevront QUE ce qui est listé ici
- Les architectes ne supporteront QUE ce qui est listé ici
- Le breakdown en epics n'implémentera QUE ce qui est listé ici
- Si une capacité n'est pas dans les FRs, elle n'existera PAS dans le produit final

### User Onboarding & Account Management

- FR1: Users can download and install the mobile application
- FR2: Users can create an account with basic information
- FR3: Users can discover the first free investigation during onboarding
- FR4: Users can learn about the concept and LORE of detectives during onboarding
- FR5: Users can understand how to use the application through onboarding guidance

### Enquête Discovery & Selection

- FR6: Users can browse available investigations
- FR7: Users can view investigation details (duration, difficulty, description)
- FR8: Users can select an investigation to start
- FR9: Users can see which investigations are free vs paid
- FR10: Users can filter investigations by city (V1.0+)
- FR11: Users can filter investigations by difficulty level (V1.0+)

### Enquête Gameplay & Navigation

- FR12: Users can start an investigation
- FR13: Users can navigate between énigmes within an investigation
- FR14: Users can view their progress within an investigation
- FR15: Users can see which énigmes are completed vs pending
- FR16: Users can pause an investigation and resume later
- FR17: Users can view an interactive map of the city during an investigation (always visible or accessible on demand)
- FR18: Users can see their current location on the map
- FR19: Users can receive visual feedback on their progress
- FR20: Users can abandon an investigation and return to it later
- FR21: System can automatically save investigation progress (continuous saving or at specific checkpoints)
- FR22: Users can receive reminders about incomplete investigations (V1.0+)

### Énigme Resolution & Validation

- FR23: Users can solve photo-based énigmes (take a photo of a specific point)
- FR24: Users can solve geolocation-based énigmes (reach a specific location)
- FR25: Users can solve word-based énigmes (find words related to the city)
- FR26: Users can solve puzzle-based énigmes (codes, logic puzzles)
- FR27: Users can solve audio-based énigmes (listen to historical excerpts) (Optional MVP)
- FR28: Users can receive validation feedback when solving an énigme correctly
- FR29: Users can receive error feedback when solving an énigme incorrectly
- FR30: Users can access contextual help if blocked on an énigme (progressive hints - accessible via help button or automatically offered after inactivity)
- FR31: Users can view historical explanations after solving énigmes
- FR32: Users can see educational content about the city and heritage
- FR33: Users can use existing photos from gallery as fallback for photo énigmes if camera permission denied

### Content & LORE

- FR34: Users can experience the detective LORE narrative during investigations
- FR35: Users can skip LORE elements if they prefer to go directly to énigmes
- FR36: Users can view historical information about discovered locations
- FR37: Users can see photos and historical context for locations
- FR38: Users can learn about the city's heritage through the investigation

### Progression & Tracking

- FR39: Users can see their investigation completion status
- FR40: Users can view their overall progress across investigations
- FR41: Users can view their investigation history (list of completed investigations)
- FR42: Users can see badges and accomplishments (V1.0+)
- FR43: Users can view their detective skills progression (V1.0+)
- FR44: Users can collect virtual postcards for discovered locations (V1.0+)
- FR45: Users can view leaderboard rankings (V1.0+)

### Monetization & Purchases

- FR46: Users can access the first investigation for free
- FR47: Users can view available paid investigations
- FR48: Users can purchase additional investigations
- FR49: Users can view pricing for investigations
- FR50: Users can purchase investigation packs (V1.0+)
- FR51: Users can purchase group packs for game master mode (V1.0+)
- FR52: System can track purchase intent clicks even with simulated payments (MVP)
- FR53: System can simulate complete payment flow for MVP validation (transaction simulation without real payment)

### Social & Group Features (V1.0+)

- FR54: Users can play investigations in group mode with multiple devices (V1.0+)
- FR55: Users can play investigations in game master mode with one device (V1.0+)
- FR56: Users can compete with friends on leaderboards (V1.0+)
- FR57: Users can see friends' scores and achievements (V1.0+)
- FR58: Users can share investigation experiences with friends (V1.0+)
- FR59: Users can adapt investigation difficulty for family mode (V1.0+)
- FR60: Parents can access parental help system with progressive hints (V1.0+)

### Admin & Content Management

- FR61: Admins can access a content management dashboard
- FR62: Admins can create and edit investigations
- FR63: Admins can create and edit énigmes
- FR64: Admins can validate historical content accuracy
- FR65: Admins can preview investigations before publication
- FR66: Admins can publish investigations for users
- FR67: Admins can rollback published investigations if errors are detected
- FR68: Admins can monitor technical performance metrics
- FR69: Admins can view user analytics and metrics
- FR70: Admins can track investigation completion rates
- FR71: Admins can view user journey analytics

### Technical Capabilities

- FR72: Application can determine user's precise location (<10m accuracy)
- FR73: Application can validate user is at correct location for geolocation énigmes
- FR74: Application can request device permissions (GPS, camera, storage) when needed
- FR75: Application can handle permission denial with alternative modes or clear messaging
- FR76: Application can function with network connection (MVP)
- FR77: Application can function without network connection (V1.0+)
- FR78: Application can cache investigation data locally (MVP - for performance even in online mode)
- FR79: Application can synchronize data when network connection is restored (V1.0+)
- FR80: Application can optimize battery consumption during investigations
- FR81: Application can handle low GPS precision scenarios with fallback messaging
- FR82: Application can display connection status to users
- FR83: Application can manage local storage space (cleanup completed investigations if needed)
- FR84: System can detect and handle investigation errors gracefully

### Push Notifications

- FR85: Users can receive notifications about new investigations in their city (MVP - requires backend)
- FR86: Users can receive reminders about incomplete investigations (MVP - requires backend)
- FR87: Users can receive notifications about new cities in their region (MVP - requires backend)
- FR88: Users can receive notifications about friends' scores and achievements (V1.0+)
- FR89: Users can receive notifications about friends' badge achievements (V1.0+)
- FR90: Users can receive notifications about weekly challenges (V1.0+)
- FR91: Users can control which notification types they receive

### User Feedback & Ratings

- FR92: Users can rate investigations after completion
- FR93: Users can write reviews for investigations (V1.0+)
- FR94: Users can view ratings and reviews from other users (V1.0+)

---

## Non-Functional Requirements

### Performance

**Temps de réponse utilisateur :**
- **Interactions utilisateur** : Toutes les interactions utilisateur (clics, navigation, validation d'énigmes) doivent se compléter en <2 secondes
- **Rationale** : Expérience fluide et non frustrante, réactivité constante requise pour maintenir l'engagement
- **Mesure** : Temps de réponse moyen des interactions utilisateur <2s (95e percentile)
- **Critères de test** : Test de performance avec 100 interactions utilisateur, 95% doivent se compléter en <2s
- **Monitoring** : Système de monitoring pour suivre les temps de réponse en production

**Temps de chargement :**
- **Chargement d'enquête depuis cache** : <2 secondes pour charger une enquête complète depuis le cache local
- **Chargement initial de l'application** : <3 secondes pour le démarrage initial (cold start)
- **Navigation entre écrans** : <1 seconde pour les transitions entre écrans
- **Mesure** : Temps de chargement moyen <2s pour enquêtes en cache

**Géolocalisation :**
- **Précision géolocalisation** : <10m de précision pour validation des énigmes basées sur la localisation
- **Taux d'erreur géolocalisation** : <10% (géolocalisation fonctionne correctement dans 90%+ des cas)
- **Temps d'acquisition GPS** : <30 secondes pour obtenir une position précise au démarrage
- **Mesure** : Précision GPS <10m, taux d'erreur <10%

**Performance batterie :**
- **Consommation batterie** : Une enquête complète (1h-1h30) doit être possible sur une charge de batterie
- **Optimisation** : Mode économie d'énergie disponible, gestion intelligente du GPS en arrière-plan
- **Mesure** : Consommation batterie <20% par heure d'utilisation active
- **Validation** : Tests de consommation batterie sur différents appareils pour valider l'objectif

**Stabilité :**
- **Taux de crash** : <0.5% (nombre de crashes / nombre total de sessions)
- **Disponibilité** : 99% de disponibilité pour MVP (application fonctionnelle), 99.5% pour V1.0+
- **Mesure** : Monitoring continu, taux de crash <0.5%
- **Monitoring** : Système de monitoring en production pour suivre les métriques de performance en temps réel

### Security

**Protection des données utilisateurs :**
- **Comptes utilisateurs** : Toutes les données de compte (identifiants, profils) doivent être chiffrées en transit et au repos
- **Progression utilisateur** : Les données de progression (enquêtes complétées, scores) doivent être sécurisées et accessibles uniquement par l'utilisateur propriétaire
- **Paiements** : Toutes les transactions de paiement doivent être sécurisées selon les standards App Store et Google Play (chiffrement, validation serveur)
- **Authentification** : Système d'authentification sécurisé pour protéger les comptes utilisateurs

**Conformité réglementaire :**
- **RGPD (Règlement Général sur la Protection des Données)** : Conformité complète avec le RGPD pour la collecte, le stockage et le traitement des données personnelles des utilisateurs
- **Consentement utilisateur** : Consentement explicite pour la collecte de données (géolocalisation, analytics)
- **Droit à l'oubli** : Possibilité pour les utilisateurs de supprimer leurs données personnelles
- **Transparence** : Politique de confidentialité claire et accessible

**Sécurité des paiements :**
- **Standards App Store/Google Play** : Conformité avec les standards de sécurité des stores (App Store In-App Purchase, Google Play Billing)
- **Validation serveur** : Validation des transactions côté serveur pour prévenir la fraude
- **Chiffrement** : Toutes les communications de paiement chiffrées en transit (HTTPS/TLS)

**Sécurité technique :**
- **Chiffrement des données** : Chiffrement des données sensibles au repos et en transit
- **Gestion des permissions** : Demande de permissions au moment approprié avec justification claire
- **Protection contre les attaques** : Protection contre les attaques courantes (injection, XSS, etc.)

### Scalability

**Capacité utilisateurs :**
- **Objectif 3 mois** : Support de 500-1100 utilisateurs actifs (basé sur objectif business 500€/mois avec 15-20% conversion)
- **Objectif 12 mois** : Support de 5000-11000 utilisateurs actifs (basé sur objectif business 5000€/mois avec 15-20% conversion)
- **Croissance** : Architecture capable de supporter une croissance 10x sans refonte majeure
- **Architecture scalable** : Architecture scalable dès le départ (patterns extensibles) mais avec implémentation simple pour MVP
- **Mesure** : Système supporte le nombre d'utilisateurs cibles sans dégradation de performance
- **Tests de charge** : Tests de charge pour valider la scalabilité (simulation de 500-1100 utilisateurs simultanés)

**Gestion du trafic :**
- **Trafic saisonnier** : Système capable de gérer les pics de trafic saisonniers (été, vacances) avec 2-3x le trafic normal
- **Scaling automatique** : Capacité de scaling automatique pour gérer les pics de trafic
- **Performance sous charge** : Performance maintenue (<10% de dégradation) même sous charge élevée

**Scalabilité du contenu :**
- **Expansion du catalogue** : Architecture capable de supporter l'expansion du catalogue (5 villes → 20+ villes, 50+ enquêtes)
- **Gestion du cache** : Système de cache scalable pour gérer l'augmentation du contenu
- **Performance constante** : Temps de chargement maintenu (<2s) même avec catalogue étendu

### Accessibility

**Support des utilisateurs avec handicaps :**
- **Public cible inclusif** : L'application doit être accessible aux utilisateurs avec handicaps (visuels, auditifs, moteurs)
- **Standards d'accessibilité** : Conformité avec les standards d'accessibilité de base (WCAG 2.1 Level A minimum)
- **Fonctionnalités d'accessibilité** : Support des fonctionnalités d'accessibilité des plateformes (VoiceOver, TalkBack, etc.)
- **Priorisation MVP** : Focus sur l'accessibilité essentielle pour MVP (contraste, taille de texte, zones de toucher), amélioration continue pour V1.0+ avec conformité WCAG complète

**Accessibilité visuelle :**
- **Contraste** : Contraste suffisant pour la lisibilité (ratio de contraste minimum 4.5:1)
- **Taille de texte** : Texte lisible et redimensionnable selon les préférences système
- **Navigation** : Navigation accessible via lecteurs d'écran

**Accessibilité motrice :**
- **Interactions** : Zones de toucher suffisamment grandes pour faciliter les interactions
- **Alternatives** : Alternatives aux interactions complexes (gestes, etc.)

**Tests d'accessibilité** : Tests d'accessibilité automatisés et manuels pour valider la conformité WCAG (tests avec lecteurs d'écran, tests de contraste, etc.)

### Integration

**Intégrations App Store et Google Play :**
- **Fiabilité** : Intégrations App Store et Google Play avec 99.9% de fiabilité
- **Gestion des erreurs** : Gestion gracieuse des erreurs d'intégration (réseau, API, etc.)
- **Fallbacks** : Messages d'erreur clairs si les intégrations échouent
- **Validation** : Validation des transactions avec les stores pour prévenir la fraude

**Push Notifications :**
- **Fiabilité** : Système de push notifications avec 95%+ de taux de livraison
- **Gestion des erreurs** : Gestion gracieuse des erreurs de notifications (tokens invalides, etc.)
- **Retry logic** : Logique de retry pour les notifications non livrées

**Synchronisation des données :**
- **Fiabilité** : Synchronisation des données avec 98%+ de taux de succès
- **Gestion des conflits** : Stratégie de résolution des conflits de synchronisation
- **Récupération** : Récupération automatique après échec de synchronisation
