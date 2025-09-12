# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-12

### Added
- **SDK principal** : Classe SynctraSDK avec pattern singleton
- **Gestion des liens dynamiques** : Création, récupération et gestion de liens courts
- **Deferred Deep Linking** : Redirection intelligente après installation d'application
- **Analytics avancés** : Tracking automatique des événements avec batch processing
- **Codes de parrainage** : Système complet de référencement avec validation
- **Détection d'installation** : Vérification automatique des applications installées
- **Stockage offline** : Cache local avec synchronisation automatique
- **Gestion d'erreurs** : Exceptions typées avec messages en français
- **Multi-plateforme** : Support Android, iOS, Web, Desktop
- **Modèles de données** : DeepLink, AnalyticsEvent, ReferralCode, AppInstallInfo
- **Services** : ApiService, DeepLinkService, AnalyticsService, ReferralService
- **Utilitaires** : Validation, cryptographie, gestion des URLs, informations device
- **Tests unitaires** : Couverture des modèles principaux
- **Documentation complète** : README détaillé avec exemples d'utilisation
- **Application d'exemple** : Interface de démonstration des fonctionnalités

### Features
- Configuration flexible avec SynctraConfig
- Validation automatique des URLs et paramètres
- Chiffrement et génération sécurisée d'identifiants
- Gestion des timeouts et retry automatique
- Support des domaines personnalisés
- Tracking des conversions avec valeurs monétaires
- Codes de parrainage avec limites d'utilisation et expiration
- Détection intelligente des plateformes
- Interface utilisateur moderne avec Material 3

### Technical
- Architecture production-ready avec dependency injection
- Type safety avec modèles immutables
- Memory management optimisé
- Performance avec traitement par batch
- Gestion robuste des erreurs réseau
- Stockage sécurisé des données sensibles
- Support offline-first avec synchronisation
- API REST avec authentification Bearer token

### Dependencies
- http: ^1.1.0 - Requêtes HTTP
- shared_preferences: ^2.2.2 - Stockage local
- url_launcher: ^6.2.1 - Ouverture d'URLs
- package_info_plus: ^4.2.0 - Informations application
- device_info_plus: ^9.1.1 - Informations device
- crypto: ^3.0.3 - Fonctions cryptographiques
- uuid: ^4.1.0 - Génération d'identifiants uniques
- meta: ^1.9.1 - Annotations de métadonnées
