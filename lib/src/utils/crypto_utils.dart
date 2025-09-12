import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class CryptoUtils {
  static const Uuid _uuid = Uuid();
  static final Random _random = Random.secure();

  static String generateUuid() {
    return _uuid.v4();
  }

  static String generateSessionId() {
    return _uuid.v4();
  }

  static String generateDeviceId() {
    return _uuid.v4();
  }

  static String generateReferralCode({int length = 8}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  static String generateShortCode({int length = 6}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String hashWithSalt(String input, String salt) {
    final saltedInput = '$input$salt';
    return hashString(saltedInput);
  }

  static String generateSalt({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  static String encodeBase64(String input) {
    final bytes = utf8.encode(input);
    return base64Encode(bytes);
  }

  static String decodeBase64(String input) {
    final bytes = base64Decode(input);
    return utf8.decode(bytes);
  }

  static String generateApiKey({int length = 64}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  static String generateSecureToken({int length = 32}) {
    final bytes = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(bytes).substring(0, length);
  }

  static bool verifyHash(String input, String hash, [String? salt]) {
    if (salt != null) {
      return hashWithSalt(input, salt) == hash;
    }
    return hashString(input) == hash;
  }
}
