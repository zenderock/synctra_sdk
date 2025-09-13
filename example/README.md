# Synctra SDK - Application d'exemple

Cette application d'exemple démontre l'utilisation du SDK Synctra pour Flutter. Elle présente les fonctionnalités principales du SDK dans une interface utilisateur intuitive.

## Fonctionnalités démontrées

- **Initialisation du SDK** : Configuration et initialisation avec les paramètres requis
- **Création de liens dynamiques** : Interface pour créer des liens raccourcis avec paramètres personnalisés
- **Gestion des codes de parrainage** : Création de codes de parrainage avec limites d'utilisation
- **Informations du SDK** : Affichage des informations de session et d'état du SDK

## Installation et exécution

1. Assurez-vous d'avoir Flutter installé (version 3.0.0 ou supérieure)
2. Naviguez vers le dossier example :
   ```bash
   cd example
   ```
3. Installez les dépendances :
   ```bash
   flutter pub get
   ```
4. Lancez l'application :
   ```bash
   flutter run
   ```

## Configuration

Avant d'utiliser l'application, vous devez configurer votre clé API Synctra dans le fichier `lib/main.dart` :

```dart
const config = SynctraConfig(
  apiKey: 'votre_cle_api_ici',
  projectId: 'votre_project_id_ici',
  debugMode: true,
);
```

## Structure de l'application

- `lib/main.dart` : Point d'entrée principal avec l'interface utilisateur
- `pubspec.yaml` : Configuration des dépendances

## Utilisation

### Création d'un lien dynamique

1. Entrez une URL valide dans le champ "URL à raccourcir"
2. Cliquez sur "Créer le lien"
3. Le lien raccourci s'affiche dans la section de résultat

### Création d'un code de parrainage

1. Optionnellement, entrez un code personnalisé
2. Cliquez sur "Créer le code"
3. Le code généré s'affiche dans les messages

### Informations du SDK

La section "Informations SDK" affiche :
- Le statut d'initialisation
- L'ID utilisateur actuel
- L'ID de session
- L'ID de l'appareil

## Personnalisation

Cette application d'exemple peut être étendue pour démontrer d'autres fonctionnalités du SDK :

- Gestion des liens différés (deferred deep linking)
- Analytics et suivi d'événements
- Validation de codes de parrainage
- Détection d'installation d'applications

## Support

Pour plus d'informations sur l'utilisation du SDK Synctra, consultez la documentation principale dans le dossier racine du projet.
