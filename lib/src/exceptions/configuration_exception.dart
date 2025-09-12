import 'synctra_exception.dart';

class ConfigurationException extends SynctraException {
  const ConfigurationException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory ConfigurationException.missingApiKey() {
    return const ConfigurationException(
      'Clé API manquante. Veuillez configurer votre clé API Synctra',
      code: 'MISSING_API_KEY',
    );
  }

  factory ConfigurationException.missingProjectId() {
    return const ConfigurationException(
      'ID de projet manquant. Veuillez configurer votre ID de projet Synctra',
      code: 'MISSING_PROJECT_ID',
    );
  }

  factory ConfigurationException.invalidApiKey() {
    return const ConfigurationException(
      'Clé API invalide. Vérifiez votre clé API Synctra',
      code: 'INVALID_API_KEY',
    );
  }

  factory ConfigurationException.invalidBaseUrl() {
    return const ConfigurationException(
      'URL de base invalide. Vérifiez la configuration de votre URL de base',
      code: 'INVALID_BASE_URL',
    );
  }

  factory ConfigurationException.notInitialized() {
    return const ConfigurationException(
      'SDK non initialisé. Appelez SynctraSDK.initialize() avant utilisation',
      code: 'NOT_INITIALIZED',
    );
  }

  @override
  String toString() {
    return 'ConfigurationException: $message';
  }
}
