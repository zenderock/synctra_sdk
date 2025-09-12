import 'synctra_exception.dart';

class NetworkException extends SynctraException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const NetworkException(
    super.message, {
    super.code,
    this.statusCode,
    this.responseData,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.timeout() {
    return const NetworkException(
      'Délai d\'attente dépassé lors de la connexion au serveur',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.noConnection() {
    return const NetworkException(
      'Aucune connexion internet disponible',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.serverError(int statusCode, [String? message]) {
    return NetworkException(
      message ?? 'Erreur serveur (Code: $statusCode)',
      code: 'SERVER_ERROR',
      statusCode: statusCode,
    );
  }

  factory NetworkException.unauthorized() {
    return const NetworkException(
      'Clé API invalide ou accès non autorisé',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  factory NetworkException.forbidden() {
    return const NetworkException(
      'Accès interdit à cette ressource',
      code: 'FORBIDDEN',
      statusCode: 403,
    );
  }

  factory NetworkException.notFound() {
    return const NetworkException(
      'Ressource non trouvée',
      code: 'NOT_FOUND',
      statusCode: 404,
    );
  }

  factory NetworkException.rateLimited() {
    return const NetworkException(
      'Limite de taux dépassée, veuillez réessayer plus tard',
      code: 'RATE_LIMITED',
      statusCode: 429,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('NetworkException: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (statusCode != null) {
      buffer.write(' (HTTP: $statusCode)');
    }
    return buffer.toString();
  }
}
