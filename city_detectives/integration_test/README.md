# Tests E2E (integration_test)

Parcours : welcome → register ; retour arrière.

## Exécution

- **Avec émulateur ou appareil connecté :**  
  `flutter test integration_test/app_test.dart`

- **Sans device :** le projet cible Android/iOS ; pour exécuter sur la machine hôte, activer une plateforme (ex. Windows) et lancer la même commande. La build Windows peut échouer si des plugins (ex. `flutter_secure_storage`) exigent des composants SDK (ex. ATL).

- **Avec `flutter drive` (device requis) :**  
  Créer un driver si besoin, puis `flutter drive --target=integration_test/app_test.dart`.

## Contenu

- `app_test.dart` : lancement de l’app, écran welcome, navigation « Continuer » → écran inscription, retour arrière vers welcome.
