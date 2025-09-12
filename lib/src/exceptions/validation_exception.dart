import 'synctra_exception.dart';

class ValidationException extends SynctraException {
  final String field;
  final dynamic value;

  const ValidationException(
    super.message, {
    required this.field,
    this.value,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.required(String field) {
    return ValidationException(
      'Le champ $field est requis',
      field: field,
      code: 'REQUIRED_FIELD',
    );
  }

  factory ValidationException.invalidFormat(String field, [String? expected]) {
    final message = expected != null
        ? 'Format invalide pour $field. Format attendu: $expected'
        : 'Format invalide pour $field';
    return ValidationException(
      message,
      field: field,
      code: 'INVALID_FORMAT',
    );
  }

  factory ValidationException.invalidUrl(String field) {
    return ValidationException(
      'URL invalide pour $field',
      field: field,
      code: 'INVALID_URL',
    );
  }

  factory ValidationException.tooLong(String field, int maxLength) {
    return ValidationException(
      'La valeur de $field dépasse la longueur maximale de $maxLength caractères',
      field: field,
      code: 'TOO_LONG',
    );
  }

  factory ValidationException.tooShort(String field, int minLength) {
    return ValidationException(
      'La valeur de $field doit contenir au moins $minLength caractères',
      field: field,
      code: 'TOO_SHORT',
    );
  }

  @override
  String toString() {
    return 'ValidationException: $message (Field: $field)';
  }
}
