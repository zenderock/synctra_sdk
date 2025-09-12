abstract class SynctraException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const SynctraException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SynctraException: $message');
    if (code != null) {
      buffer.write(' (Code: $code)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}
