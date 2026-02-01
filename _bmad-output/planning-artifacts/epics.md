---
stepsCompleted: ['step-01-validate-prerequisites', 'step-02-design-epics', 'step-03-create-stories', 'step-04-final-validation']
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - '_bmad-output/planning-artifacts/architecture.md'
  - '_bmad-output/planning-artifacts/ux-design-specification.md'
---

# city-detectives - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for city-detectives, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**User Onboarding & Account Management**
- FR1: Users can download and install the mobile application
- FR2: Users can create an account with basic information
- FR3: Users can discover the first free investigation during onboarding
- FR4: Users can learn about the concept and LORE of detectives during onboarding
- FR5: Users can understand how to use the application through onboarding guidance

**Enquête Discovery & Selection**
- FR6: Users can browse available investigations
- FR7: Users can view investigation details (duration, difficulty, description)
- FR8: Users can select an investigation to start
- FR9: Users can see which investigations are free vs paid
- FR10: Users can filter investigations by city (V1.0+)
- FR11: Users can filter investigations by difficulty level (V1.0+)

**Enquête Gameplay & Navigation**
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

**Énigme Resolution & Validation**
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

**Content & LORE**
- FR34: Users can experience the detective LORE narrative during investigations
- FR35: Users can skip LORE elements if they prefer to go directly to énigmes
- FR36: Users can view historical information about discovered locations
- FR37: Users can see photos and historical context for locations
- FR38: Users can learn about the city's heritage through the investigation

**Progression & Tracking**
- FR39: Users can see their investigation completion status
- FR40: Users can view their overall progress across investigations
- FR41: Users can view their investigation history (list of completed investigations)
- FR42: Users can see badges and accomplishments (V1.0+)
- FR43: Users can view their detective skills progression (V1.0+)
- FR44: Users can collect virtual postcards for discovered locations (V1.0+)
- FR45: Users can view leaderboard rankings (V1.0+)

**Monetization & Purchases**
- FR46: Users can access the first investigation for free
- FR47: Users can view available paid investigations
- FR48: Users can purchase additional investigations
- FR49: Users can view pricing for investigations
- FR50: Users can purchase investigation packs (V1.0+)
- FR51: Users can purchase group packs for game master mode (V1.0+)
- FR52: System can track purchase intent clicks even with simulated payments (MVP)
- FR53: System can simulate complete payment flow for MVP validation (transaction simulation without real payment)

**Social & Group Features (V1.0+)**
- FR54: Users can play investigations in group mode with multiple devices (V1.0+)
- FR55: Users can play investigations in game master mode with one device (V1.0+)
- FR56: Users can compete with friends on leaderboards (V1.0+)
- FR57: Users can see friends' scores and achievements (V1.0+)
- FR58: Users can share investigation experiences with friends (V1.0+)
- FR59: Users can adapt investigation difficulty for family mode (V1.0+)
- FR60: Parents can access parental help system with progressive hints (V1.0+)

**Admin & Content Management**
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

**Technical Capabilities**
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

**Push Notifications**
- FR85: Users can receive notifications about new investigations in their city (MVP - requires backend)
- FR86: Users can receive reminders about incomplete investigations (MVP - requires backend)
- FR87: Users can receive notifications about new cities in their region (MVP - requires backend)
- FR88: Users can receive notifications about friends' scores and achievements (V1.0+)
- FR89: Users can receive notifications about friends' badge achievements (V1.0+)
- FR90: Users can receive notifications about weekly challenges (V1.0+)
- FR91: Users can control which notification types they receive

**User Feedback & Ratings**
- FR92: Users can rate investigations after completion
- FR93: Users can write reviews for investigations (V1.0+)
- FR94: Users can view ratings and reviews from other users (V1.0+)

### NonFunctional Requirements

**Performance**
- NFR1: Interactions utilisateur <2s (95e percentile)
- NFR2: Chargement d'enquête depuis cache <2s ; cold start <3s ; transitions <1s
- NFR3: Précision géolocalisation <10m ; taux d'erreur <10% ; acquisition GPS <30s
- NFR4: Enquête complète (1h-1h30) sur une charge ; consommation <20%/heure
- NFR5: Taux de crash <0.5% ; disponibilité 99% (MVP) / 99.5% (V1.0+)

**Security**
- NFR6: Données compte et progression chiffrées en transit et au repos ; authentification sécurisée
- NFR7: Conformité RGPD (consentement, droit à l'oubli, transparence)
- NFR8: Paiements conformes App Store/Google Play ; validation serveur ; HTTPS/TLS

**Scalability**
- NFR9: Support 500-1100 utilisateurs actifs (3 mois) → 5000-11000 (12 mois)
- NFR10: Pics de trafic 2-3x ; scaling automatique ; dégradation <10% sous charge
- NFR11: Catalogue extensible (5 villes → 20+ ; 50+ enquêtes) ; cache scalable

**Accessibility**
- NFR12: WCAG 2.1 Level A minimum ; contraste 4.5:1 ; texte redimensionnable ; zones de toucher ; VoiceOver/TalkBack

**Integration**
- NFR13: Intégrations App Store/Google Play 99.9% fiabilité ; push 95%+ livraison ; sync 98%+ succès

### Additional Requirements

**From Architecture**
- Starter template : démarrer de zéro avec `flutter create` et `cargo new`, structurer manuellement en s'inspirant des templates.
- Backend Rust + Axum ; API GraphQL ; PostgreSQL + sqlx ; JWT + bcrypt ; rate limiting (tower-governor).
- Flutter : Hive (offline), Riverpod (état), GoRouter (navigation), flutter_secure_storage (tokens).
- Infrastructure : Docker sur VPS (PostgreSQL, Backend, Nginx), CI/CD GitHub Actions, Sentry, pg_dump backups.
- Structure par feature/module ; conventions de nommage et patterns documentés dans architecture.md et project-context.md.

**From UX**
- Design system « carnet de détective » ; carte interactive immersive ; feedback visuel riche ; adaptation contextuelle (mode famille/solo/touriste).
- Indicateurs de statut connexion discrets ; gestion faible précision GPS avec indicateurs clairs ; option sauter LORE.
- Accessibilité : contraste, taille de texte, zones de toucher ; premier écran impactant ; design language cohérent.

### FR Coverage Map

| FR | Epic | Domaine |
|----|------|---------|
| FR1–FR5 | Epic 1 | Onboarding & Account |
| FR6–FR11 | Epic 2 | Investigation Discovery & Selection |
| FR12–FR22, FR72–FR84 | Epic 3 | Core Gameplay & Navigation (+ techniques) |
| FR23–FR38 | Epic 4 | Énigmes & Content |
| FR39–FR45, FR54–FR60 | Epic 5 | Progression & Gamification (+ Social V1.0+) |
| FR46–FR53 | Epic 6 | Monetization & Purchases |
| FR61–FR71 | Epic 7 | Admin & Content Management |
| FR85–FR91 | Epic 8 | Push Notifications |
| FR92–FR94 | Epic 9 | User Feedback & Ratings |

### Parallelization & Agent Lanes

_Pour permettre à plusieurs agents de travailler en parallèle : quels epics sont indépendants (parallélisables) et quelles sont les dépendances._

| Epic | Depends on | Parallelizable with | Lane |
|------|------------|---------------------|------|
| Epic 1: Onboarding & Account | — | — | A |
| Epic 2: Investigation Discovery & Selection | Epic 1 | Epic 7 | A |
| Epic 3: Core Gameplay & Navigation | Epic 1, 2 | Epic 7 | A |
| Epic 4: Énigmes & Content | Epic 3 | Epic 7 | B |
| Epic 5: Progression & Gamification | Epic 4 | Epic 6, 8, 9 | B |
| Epic 6: Monetization & Purchases | Epic 2, 4 | Epic 5, 8, 9 | C |
| Epic 7: Admin & Content Management | Epic 1 | Epic 2, 3, 4 | B |
| Epic 8: Push Notifications | Epic 1, 2 _(backend catalogue minimal)_ | Epic 5, 6, 9 | C |
| Epic 9: User Feedback & Ratings | Epic 4 | Epic 5, 6, 8 | C |

**Ordre recommandé par lane :**
- **Lane A** (chaîne principale app) : Epic 1 → 2 → 3 → 4. À faire dans l’ordre.
- **Lane B** : Epic 7 (Admin) peut démarrer dès Epic 1 fait (auth) ; Epic 5 après Epic 4. Ordre recommandé : Epic 7 en parallèle de 2/3/4, puis Epic 5 après livraison Epic 4.
- **Lane C** : Epics 6, 8, 9 peuvent être répartis entre agents une fois Epic 4 (et pour 6 : Epic 2) livrés.

## Epic List

### Epic 1: Onboarding & Account
Les utilisateurs peuvent installer l’app, créer un compte, découvrir la première enquête gratuite, apprendre le LORE et l’usage de l’app.
**FRs covered:** FR1, FR2, FR3, FR4, FR5  
**Depends on:** none  
**Parallelizable with:** —  
**Lane:** A  

### Epic 2: Investigation Discovery & Selection
Les utilisateurs peuvent parcourir les enquêtes, voir détails (durée, difficulté, description), choisir une enquête, distinguer gratuit/payant (filtres ville/difficulté en V1.0+).
**FRs covered:** FR6, FR7, FR8, FR9, FR10 (V1.0+), FR11 (V1.0+)  
**Depends on:** Epic 1  
**Parallelizable with:** Epic 7  
**Lane:** A  

### Epic 3: Core Gameplay & Navigation
Les utilisateurs peuvent démarrer une enquête, naviguer entre énigmes, voir la progression, la carte interactive et leur position, mettre en pause/reprendre, sauvegarder ; l’app gère localisation, cache, batterie et erreurs.
**FRs covered:** FR12–FR22, FR72–FR84  
**Depends on:** Epic 1, 2  
**Parallelizable with:** Epic 7  
**Lane:** A  

### Epic 4: Énigmes & Content
Les utilisateurs peuvent résoudre les types d’énigmes (photo, géo, mots, puzzle, audio optionnel), recevoir validation/aide progressive, voir explications historiques et LORE (avec option de sauter le LORE).
**FRs covered:** FR23–FR38  
**Depends on:** Epic 3  
**Parallelizable with:** Epic 7  
**Lane:** B  

### Epic 5: Progression & Gamification
Les utilisateurs peuvent voir statut de complétion, progression globale, historique, badges, compétences détective, cartes postales virtuelles, leaderboard ; modes groupe / game master / famille (V1.0+).
**FRs covered:** FR39–FR45, FR54–FR60 (V1.0+)  
**Depends on:** Epic 4  
**Parallelizable with:** Epic 6, 8, 9  
**Lane:** B  

### Epic 6: Monetization & Purchases
Les utilisateurs peuvent profiter de la première enquête gratuite, voir et acheter des enquêtes payantes, voir les prix ; le système gère packs, pack groupe (V1.0+), simulation paiement MVP et tracking d’intention.
**FRs covered:** FR46–FR53  
**Depends on:** Epic 2, 4  
**Parallelizable with:** Epic 5, 8, 9  
**Lane:** C  

### Epic 7: Admin & Content Management
Les admins peuvent accéder au dashboard, créer/éditer enquêtes et énigmes, valider le contenu historique, prévisualiser, publier, rollback, monitorer les perfs et les analytics utilisateurs/parcours.
**FRs covered:** FR61–FR71  
**Depends on:** Epic 1  
**Parallelizable with:** Epic 2, 3, 4  
**Lane:** B  

### Epic 8: Push Notifications
Les utilisateurs peuvent recevoir des notifications (nouvelles enquêtes, rappels enquêtes incomplètes, nouvelles villes, et V1.0+ : amis, badges, défis) et contrôler les types de notifications.
**FRs covered:** FR85–FR91  
**Depends on:** Epic 1, Epic 2 (backend catalogue minimal pour cibler enquêtes/villes)  
**Parallelizable with:** Epic 5, 6, 9  
**Lane:** C  

### Epic 9: User Feedback & Ratings
Les utilisateurs peuvent noter les enquêtes après complétion et (V1.0+) consulter/écrire des avis.
**FRs covered:** FR92, FR93 (V1.0+), FR94 (V1.0+)  
**Depends on:** Epic 4  
**Parallelizable with:** Epic 5, 6, 8  
**Lane:** C

---

## Epic 1: Onboarding & Account (détail stories)

Les utilisateurs peuvent installer l'app, créer un compte, découvrir la première enquête gratuite, apprendre le LORE et l'usage de l'app.

### Story 1.1: App shell et installation
**Depends on:** none  
**Parallelizable with:** —  
**Lane:** A  

As a utilisateur, I want télécharger et installer l'application mobile City Detectives, So that je puisse accéder à l'expérience d'enquête urbaine.

**Acceptance Criteria:**
- **Given** un appareil iOS 13+ ou Android 8+ (API 26+)  
- **When** l'utilisateur suit le lien de téléchargement (App Store / Play Store) et lance l'app  
- **Then** l'application s'installe et s'ouvre sans erreur bloquante  
- **And** un écran d'accueil ou de connexion s'affiche (FR1)

### Story 1.2: Création de compte
**Depends on:** Story 1.1  
**Parallelizable with:** —  
**Lane:** A  

As a utilisateur, I want créer un compte avec mes informations de base (email, mot de passe), So que ma progression soit sauvegardée et accessible sur mon appareil.

**Acceptance Criteria:**
- **Given** l'app est installée et ouverte  
- **When** l'utilisateur remplit le formulaire d'inscription (email, mot de passe) et valide  
- **Then** le compte est créé côté backend (auth JWT) et l'utilisateur est connecté  
- **And** les données sont sécurisées (chiffrement transit, bcrypt pour mot de passe) (FR2)

### Story 1.3: Découverte de la première enquête gratuite et onboarding
**Depends on:** Story 1.2  
**Parallelizable with:** —  
**Lane:** A  

As a utilisateur, I want découvrir la première enquête gratuite pendant l'onboarding, comprendre le concept et le LORE des détectives, et recevoir un guidage d'usage, So que je sache comment jouer avant de commencer.

**Acceptance Criteria:**
- **Given** l'utilisateur est connecté (ou a choisi de jouer sans compte si prévu)  
- **When** il parcourt l'onboarding  
- **Then** la première enquête gratuite est présentée (FR3)  
- **And** le concept et le LORE des détectives sont expliqués (FR4)  
- **And** un guidage d'usage (navigation, objectif) est fourni (FR5)

---

## Epic 2: Investigation Discovery & Selection (détail stories)

Les utilisateurs peuvent parcourir les enquêtes, voir détails (durée, difficulté, description), choisir une enquête, distinguer gratuit/payant.

### Story 2.1: Parcourir et consulter les enquêtes
**Depends on:** Story 1.3  
**Parallelizable with:** Story 7.1  
**Lane:** A  

As a utilisateur, I want parcourir la liste des enquêtes disponibles et voir les détails (durée, difficulté, description), So que je puisse choisir quelle enquête lancer.

**Acceptance Criteria:**
- **Given** l'utilisateur a terminé l'onboarding  
- **When** il ouvre l'écran de sélection d'enquêtes  
- **Then** la liste des enquêtes disponibles s'affiche (FR6)  
- **And** pour chaque enquête : durée, difficulté, description sont visibles (FR7)

### Story 2.2: Sélection d'enquête et visibilité gratuit/payant
**Depends on:** Story 2.1  
**Parallelizable with:** Story 7.2  
**Lane:** A  

As a utilisateur, I want sélectionner une enquête pour la démarrer et voir clairement lesquelles sont gratuites ou payantes, So que je sache quoi attendre avant de lancer.

**Acceptance Criteria:**
- **Given** la liste des enquêtes est affichée  
- **When** l'utilisateur choisit une enquête  
- **Then** il peut la démarrer (FR8)  
- **And** le libellé gratuit vs payant est visible pour chaque enquête (FR9)

---

## Epic 3: Core Gameplay & Navigation (détail stories)

Les utilisateurs peuvent démarrer une enquête, naviguer entre énigmes, voir progression et carte, pause/save ; l'app gère localisation, cache, batterie, erreurs.

### Story 3.1: Démarrer une enquête et navigation entre énigmes
**Depends on:** Story 2.2  
**Parallelizable with:** Story 7.3  
**Lane:** A  

As a utilisateur, I want démarrer une enquête et naviguer entre les énigmes (liste ou flux), So que je puisse avancer dans l'enquête étape par étape.

**Acceptance Criteria:**
- **Given** une enquête est sélectionnée  
- **When** l'utilisateur démarre l'enquête  
- **Then** la première énigme (ou écran d'intro) s'affiche (FR12)  
- **And** l'utilisateur peut passer d'une énigme à l'autre (FR13)

### Story 3.2: Progression, carte interactive et position
**Depends on:** Story 3.1  
**Parallelizable with:** —  
**Lane:** A  

As a utilisateur, I want voir ma progression dans l'enquête, une carte de la ville avec ma position, et un retour visuel sur mes actions, So que je sache où j'en suis et où aller.

**Acceptance Criteria:**
- **Given** une enquête est en cours  
- **When** l'utilisateur consulte la progression ou la carte  
- **Then** la progression (énigmes complétées / restantes) est visible (FR14, FR15)  
- **And** une carte interactive de la ville est affichée, visible ou accessible à la demande (FR17)  
- **And** la position actuelle de l'utilisateur est indiquée sur la carte (FR18)  
- **And** un retour visuel sur la progression est fourni (FR19)

### Story 3.3: Pause, reprise, abandon et sauvegarde
**Depends on:** Story 3.2  
**Parallelizable with:** —  
**Lane:** A  

As a utilisateur, I want mettre en pause une enquête, la reprendre plus tard, ou l'abandonner et y revenir plus tard, sans perdre ma progression, So que je puisse jouer à mon rythme.

**Acceptance Criteria:**
- **Given** une enquête est en cours  
- **When** l'utilisateur met en pause, quitte l'app ou abandonne  
- **Then** la progression est sauvegardée automatiquement (FR21)  
- **And** il peut reprendre l'enquête plus tard au point où il s'est arrêté (FR16, FR20)

### Story 3.4: Capacités techniques (GPS, permissions, cache, batterie, erreurs)
**Depends on:** Story 3.1  
**Parallelizable with:** —  
**Lane:** A  
**Note:** Peut être découpée en sous-tâches (GPS/permissions, cache, batterie/erreurs) si un agent est surchargé.

As a utilisateur, I want que l'app gère la localisation précise, les permissions (GPS, caméra, stockage), le cache, la batterie et les erreurs de manière claire, So que l'expérience reste fluide et fiable.

**Acceptance Criteria:**
- **Given** l'app est utilisée en conditions réelles  
- **When** la localisation, les permissions ou le réseau sont sollicités  
- **Then** la position est déterminée avec une précision <10 m lorsque possible (FR72, FR73)  
- **And** les permissions sont demandées au bon moment avec un message clair (FR74, FR75)  
- **And** le statut de connexion est affiché (FR82)  
- **And** les données d'enquête sont mises en cache local pour performance (FR78)  
- **And** la consommation batterie est raisonnable ; messages de fallback si GPS imprécis (FR80, FR81)  
- **And** les erreurs d'enquête sont gérées avec un message explicite (FR84)

---

## Epic 4: Énigmes & Content (détail stories)

Les utilisateurs peuvent résoudre les types d'énigmes (photo, géo, mots, puzzle, audio optionnel), recevoir validation/aide progressive, voir explications historiques et LORE (avec option de sauter le LORE).

### Story 4.1: Énigmes photo et géolocalisation
**Depends on:** Story 3.2  
**Parallelizable with:** Story 7.4  
**Lane:** B  

As a utilisateur, I want résoudre des énigmes photo (prendre une photo d'un point précis) et géolocalisation (atteindre un lieu), So que je progresse dans l'enquête en explorant la ville.

**Acceptance Criteria:**
- **Given** une énigme photo ou géo est affichée  
- **When** l'utilisateur prend une photo du bon point ou atteint le lieu (précision <10 m)  
- **Then** la réponse est validée et un retour positif est affiché (FR23, FR24, FR28)  
- **And** en cas d'erreur, un retour explicite est fourni (FR29)  
- **And** si la caméra est refusée, la galerie peut être utilisée en fallback (FR33)

### Story 4.2: Énigmes mots et puzzle
**Depends on:** Story 4.1  
**Parallelizable with:** Story 7.4  
**Lane:** B  

As a utilisateur, I want résoudre des énigmes à base de mots (mots liés à la ville) et des puzzles (codes, logique), So que je puisse varier les types de défis.

**Acceptance Criteria:**
- **Given** une énigme mots ou puzzle est affichée  
- **When** l'utilisateur soumet la bonne réponse  
- **Then** la validation et le feedback sont affichés (FR25, FR26, FR28, FR29)

### Story 4.3: Aide contextuelle et explications historiques
**Depends on:** Story 4.1  
**Parallelizable with:** —  
**Lane:** B  

As a utilisateur, I want accéder à une aide contextuelle (indices progressifs) si je suis bloqué, et voir les explications historiques après résolution, So que je puisse avancer tout en apprenant.

**Acceptance Criteria:**
- **Given** l'utilisateur est sur une énigme (éventuellement bloqué)  
- **When** il demande de l'aide (bouton ou après inactivité)  
- **Then** des indices progressifs (suggestion → indice → solution) sont proposés (FR30)  
- **And** après résolution, les explications historiques et le contenu éducatif sont affichés (FR31, FR32, FR36–FR38)

### Story 4.4: LORE et option de saut
**Depends on:** Story 4.1  
**Parallelizable with:** —  
**Lane:** B  

As a utilisateur, I want vivre le LORE des détectives pendant l'enquête et pouvoir sauter les éléments narratifs si je préfère aller directement aux énigmes, So que l'expérience s'adapte à ma préférence.

**Acceptance Criteria:**
- **Given** une enquête avec contenu LORE  
- **When** le LORE est affiché  
- **Then** l'utilisateur peut le vivre (FR34) ou le sauter (FR35)  
- **And** photos et contexte historique des lieux sont disponibles (FR37)

---

## Epic 5: Progression & Gamification (détail stories)

Les utilisateurs peuvent voir statut de complétion, progression globale, historique, badges, leaderboard ; modes groupe / game master / famille (V1.0+).

### Story 5.1: Statut de complétion et historique
**Depends on:** Story 4.1  
**Parallelizable with:** Story 6.1, Story 8.1, Story 9.1  
**Lane:** B  

As a utilisateur, I want voir mon statut de complétion par enquête, ma progression globale et mon historique d'enquêtes complétées, So que je sache où j'en suis.

**Acceptance Criteria:**
- **Given** l'utilisateur a complété ou commencé des enquêtes  
- **When** il consulte son profil ou l'écran progression  
- **Then** le statut de complétion par enquête est visible (FR39)  
- **And** la progression globale et l'historique des enquêtes complétées sont affichés (FR40, FR41)

### Story 5.2: Badges, compétences et leaderboard (V1.0+)
**Depends on:** Story 5.1  
**Parallelizable with:** Story 6.2, Story 8.2, Story 9.2  
**Lane:** B  

As a utilisateur, I want voir mes badges et accomplissements, ma progression de compétences détective, les cartes postales virtuelles et le classement leaderboard, So que je sois motivé à progresser.

**Acceptance Criteria:**
- **Given** l'utilisateur a débloqué des accomplissements (V1.0+)  
- **When** il consulte la section gamification  
- **Then** badges, compétences détective, cartes postales et leaderboard sont visibles (FR42–FR45)

---

## Epic 6: Monetization & Purchases (détail stories)

Les utilisateurs peuvent profiter de la première enquête gratuite, voir et acheter des enquêtes payantes ; le système gère simulation paiement MVP et tracking d'intention.

### Story 6.1: Première enquête gratuite et visibilité payant
**Depends on:** Story 2.2, Story 4.1  
**Parallelizable with:** Story 5.1, Story 8.1, Story 9.1  
**Lane:** C  

As a utilisateur, I want accéder à la première enquête gratuite et voir clairement les enquêtes payantes et leurs prix, So que je sache quoi acheter si je veux continuer.

**Acceptance Criteria:**
- **Given** l'utilisateur est connecté  
- **When** il consulte le catalogue  
- **Then** la première enquête gratuite est accessible sans paiement (FR46)  
- **And** les enquêtes payantes et leurs prix sont affichés (FR47, FR49)

### Story 6.2: Achat et simulation paiement (MVP)
**Depends on:** Story 6.1  
**Parallelizable with:** Story 5.2, Story 8.2, Story 9.2  
**Lane:** C  

As a utilisateur, I want acheter des enquêtes supplémentaires ; pour le MVP le flux de paiement est simulé et les clics d'intention sont trackés, So que la conversion soit mesurable sans intégration réelle.

**Acceptance Criteria:**
- **Given** l'utilisateur consulte une enquête payante  
- **When** il déclenche l'achat  
- **Then** le flux de paiement complet est simulé (FR53)  
- **And** les clics d'intention d'achat sont enregistrés (FR52)  
- **And** l'accès aux enquêtes achetées (simulé) est cohérent (FR48)

---

## Epic 7: Admin & Content Management (détail stories)

Les admins peuvent accéder au dashboard, créer/éditer enquêtes et énigmes, valider le contenu, prévisualiser, publier, rollback, monitorer les perfs et les analytics.

### Story 7.1: Accès dashboard admin
**Depends on:** Story 1.2  
**Parallelizable with:** Story 2.1  
**Lane:** B  

As an admin, I want accéder à un dashboard de gestion du contenu, So que je puisse gérer les enquêtes et les énigmes.

**Acceptance Criteria:**
- **Given** un compte admin authentifié  
- **When** l'admin se connecte au dashboard  
- **Then** la vue d'ensemble (contenu, métriques de base) s'affiche (FR61)

### Story 7.2: Création et édition d'enquêtes et d'énigmes
**Depends on:** Story 7.1  
**Parallelizable with:** Story 2.2  
**Lane:** B  

As an admin, I want créer et éditer des enquêtes et des énigmes, et valider la précision du contenu historique, So que le catalogue reste à jour et fiable.

**Acceptance Criteria:**
- **Given** l'admin est sur le dashboard  
- **When** il crée ou modifie une enquête ou une énigme  
- **Then** les champs nécessaires sont disponibles (FR62, FR63)  
- **And** la validation du contenu historique est possible (FR64)

### Story 7.3: Prévisualisation, publication et rollback
**Depends on:** Story 7.2  
**Parallelizable with:** Story 3.1  
**Lane:** B  

As an admin, I want prévisualiser une enquête avant publication, la publier pour les utilisateurs, et faire un rollback en cas d'erreur, So que les utilisateurs ne voient que du contenu validé.

**Acceptance Criteria:**
- **Given** une enquête est prête  
- **When** l'admin prévisualise puis publie  
- **Then** la prévisualisation reflète l'expérience utilisateur (FR65)  
- **And** la publication rend l'enquête disponible (FR66)  
- **And** un rollback est possible si des erreurs sont détectées (FR67)

### Story 7.4: Monitoring et analytics
**Depends on:** Story 7.1  
**Parallelizable with:** Story 4.1, Story 4.2  
**Lane:** B  

As an admin, I want consulter les métriques techniques (performances, crashs) et les analytics utilisateurs (taux de complétion, parcours), So que je puisse améliorer le contenu et l'expérience.

**Acceptance Criteria:**
- **Given** l'admin est sur le dashboard  
- **When** il consulte les métriques  
- **Then** les indicateurs techniques (perfs, crashs) sont visibles (FR68)  
- **And** les analytics utilisateurs et les taux de complétion sont disponibles (FR69, FR70)  
- **And** les analytics de parcours utilisateur sont accessibles (FR71)

---

## Epic 8: Push Notifications (détail stories)

Les utilisateurs peuvent recevoir des notifications (nouvelles enquêtes, rappels, nouvelles villes) et contrôler les types de notifications.

### Story 8.1: Notifications enquêtes et rappels (MVP)
**Depends on:** Story 1.2, Story 2.1  
**Parallelizable with:** Story 5.1, Story 6.1, Story 9.1  
**Lane:** C  

As a utilisateur, I want recevoir des notifications sur les nouvelles enquêtes dans ma ville, les rappels d'enquêtes incomplètes et les nouvelles villes dans ma région, So que je reste engagé.

**Acceptance Criteria:**
- **Given** le backend push est configuré (tokens, FCM/APNs)  
- **When** un événement pertinent se produit (nouvelle enquête, rappel, nouvelle ville)  
- **Then** l'utilisateur reçoit la notification correspondante (FR85, FR86, FR87)

### Story 8.2: Préférences de notifications
**Depends on:** Story 8.1  
**Parallelizable with:** Story 5.2, Story 6.2, Story 9.2  
**Lane:** C  

As a utilisateur, I want choisir quels types de notifications je reçois, So que je ne sois pas submergé.

**Acceptance Criteria:**
- **Given** l'utilisateur est dans les paramètres  
- **When** il modifie les préférences de notifications  
- **Then** les types de notifications (enquêtes, rappels, villes, etc.) sont configurables (FR91)

---

## Epic 9: User Feedback & Ratings (détail stories)

Les utilisateurs peuvent noter les enquêtes après complétion et (V1.0+) consulter/écrire des avis.

### Story 9.1: Notation après complétion
**Depends on:** Story 4.1  
**Parallelizable with:** Story 5.1, Story 6.1, Story 8.1  
**Lane:** C  

As a utilisateur, I want noter une enquête après l'avoir complétée, So que ma satisfaction soit prise en compte et visible pour les autres (V1.0+).

**Acceptance Criteria:**
- **Given** l'utilisateur a complété une enquête  
- **When** il est invité à noter (ou ouvre l'écran de notation)  
- **Then** il peut soumettre une note (FR92)

### Story 9.2: Avis et consultation des avis (V1.0+)
**Depends on:** Story 9.1  
**Parallelizable with:** Story 5.2, Story 6.2, Story 8.2  
**Lane:** C  

As a utilisateur, I want écrire un avis sur une enquête et consulter les notes et avis des autres utilisateurs, So que je puisse choisir mes prochaines enquêtes en connaissance de cause.

**Acceptance Criteria:**
- **Given** l'utilisateur a complété une enquête (ou consulte une enquête)  
- **When** il écrit un avis ou consulte les avis  
- **Then** il peut soumettre un avis texte (FR93)  
- **And** les notes et avis des autres utilisateurs sont visibles (FR94)
