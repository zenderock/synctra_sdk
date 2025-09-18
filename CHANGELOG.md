# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2024-09-18

### Modifié
- Mise à jour de `shared_preferences` vers ^2.5.3 (était ^2.2.2)
- Mise à jour de `device_info_plus` vers ^12.1.0 (était ^9.1.0)
- Mise à jour de `app_links` vers ^6.4.1 (était ^3.4.3)
- Mise à jour de `crypto` vers ^3.0.6 (était ^3.0.3)

### Amélioré
- Compatibilité avec les dernières versions des dépendances
- Corrections de bugs et améliorations de performance des packages mis à jour
- Meilleure stabilité sur toutes les plateformes

## [1.0.1] - 2024-09-18

### Note
- Version publiée précédemment

## [1.0.0+1] - 2024-09-18

### Ajouté
- SDK Flutter professionnel pour la gestion des liens dynamiques
- Support du deferred deep linking avec détection automatique d'installation
- Système d'analytics avancé avec tracking des conversions
- Codes de parrainage intégrés avec gestion des récompenses
- Support multi-plateforme (Android, iOS, Web, Desktop)
- Fonctionnement offline-first avec synchronisation automatique
- Génération de signatures d'appareil pour le matching
- Configuration flexible avec callbacks personnalisables
- Gestion d'erreurs robuste avec types d'exceptions spécialisés
- Documentation complète avec exemples d'implémentation
- Tests unitaires et d'intégration
- Support des liens personnalisés et des domaines custom

### Fonctionnalités principales
- **Liens dynamiques** : Création et gestion de liens courts intelligents
- **Deep linking différé** : Redirection après installation d'application
- **Analytics** : Tracking complet des interactions utilisateur
- **Parrainage** : Système de référencement avec codes personnalisés
- **Multi-plateforme** : Compatibilité Android, iOS, Web, Desktop
- **Production-ready** : Code optimisé pour un usage en production

### Dépendances
- Flutter SDK >=3.0.0
- Dart SDK >=3.4.4 <4.0.0
- http ^1.1.0
- shared_preferences ^2.2.2
- device_info_plus ^9.1.0
- app_links ^3.4.3
- crypto ^3.0.3
