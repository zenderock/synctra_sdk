import '../exceptions/exceptions.dart';

class LinkValidator {
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void validateUrl(String url, String fieldName) {
    if (url.isEmpty) {
      throw ValidationException.required(fieldName);
    }

    if (!_urlRegex.hasMatch(url)) {
      throw ValidationException.invalidUrl(fieldName);
    }

    if (url.length > 2048) {
      throw ValidationException.tooLong(fieldName, 2048);
    }
  }

  void validateEmail(String email, String fieldName) {
    if (email.isEmpty) {
      throw ValidationException.required(fieldName);
    }

    if (!_emailRegex.hasMatch(email)) {
      throw ValidationException.invalidFormat(fieldName, 'email@example.com');
    }
  }

  void validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      throw ValidationException.required(fieldName);
    }
  }

  void validateLength(String value, String fieldName, {int? min, int? max}) {
    if (min != null && value.length < min) {
      throw ValidationException.tooShort(fieldName, min);
    }

    if (max != null && value.length > max) {
      throw ValidationException.tooLong(fieldName, max);
    }
  }

  void validateReferralCode(String code, String fieldName) {
    validateRequired(code, fieldName);
    validateLength(code, fieldName, min: 3, max: 50);

    final validCodeRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validCodeRegex.hasMatch(code)) {
      throw ValidationException.invalidFormat(
        fieldName,
        'Lettres, chiffres, tirets et underscores uniquement',
      );
    }
  }

  void validateApiKey(String apiKey, String fieldName) {
    validateRequired(apiKey, fieldName);
    validateLength(apiKey, fieldName, min: 32, max: 128);
  }

  void validateProjectId(String projectId, String fieldName) {
    validateRequired(projectId, fieldName);
    validateLength(projectId, fieldName, min: 8, max: 64);

    final validProjectIdRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!validProjectIdRegex.hasMatch(projectId)) {
      throw ValidationException.invalidFormat(
        fieldName,
        'Lettres, chiffres, tirets et underscores uniquement',
      );
    }
  }

  bool isValidUrl(String url) {
    try {
      validateUrl(url, 'url');
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isValidEmail(String email) {
    try {
      validateEmail(email, 'email');
      return true;
    } catch (_) {
      return false;
    }
  }
}
