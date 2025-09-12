import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static const String _keyPrefix = 'synctra_';
  static const String _pendingLinksKey = '${_keyPrefix}pending_links';
  static const String _analyticsEventsKey = '${_keyPrefix}analytics_events';
  static const String _deviceIdKey = '${_keyPrefix}device_id';
  static const String _sessionIdKey = '${_keyPrefix}session_id';
  static const String _userIdKey = '${_keyPrefix}user_id';
  static const String _referralDataKey = '${_keyPrefix}referral_data';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await _preferences;
    await prefs.setString('$_keyPrefix$key', value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString('$_keyPrefix$key');
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await _preferences;
    await prefs.setBool('$_keyPrefix$key', value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool('$_keyPrefix$key');
  }

  static Future<void> setInt(String key, int value) async {
    final prefs = await _preferences;
    await prefs.setInt('$_keyPrefix$key', value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt('$_keyPrefix$key');
  }

  static Future<void> setDouble(String key, double value) async {
    final prefs = await _preferences;
    await prefs.setDouble('$_keyPrefix$key', value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble('$_keyPrefix$key');
  }

  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  static Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  static Future<void> remove(String key) async {
    final prefs = await _preferences;
    await prefs.remove('$_keyPrefix$key');
  }

  static Future<void> clear() async {
    final prefs = await _preferences;
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<void> savePendingLinks(List<Map<String, dynamic>> links) async {
    final prefs = await _preferences;
    final jsonString = jsonEncode(links);
    await prefs.setString(_pendingLinksKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getPendingLinks() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_pendingLinksKey);
    if (jsonString == null) return [];
    
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAnalyticsEvents(List<Map<String, dynamic>> events) async {
    final prefs = await _preferences;
    final jsonString = jsonEncode(events);
    await prefs.setString(_analyticsEventsKey, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getAnalyticsEvents() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_analyticsEventsKey);
    if (jsonString == null) return [];
    
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> setDeviceId(String deviceId) async {
    final prefs = await _preferences;
    await prefs.setString(_deviceIdKey, deviceId);
  }

  static Future<String?> getDeviceId() async {
    final prefs = await _preferences;
    return prefs.getString(_deviceIdKey);
  }

  static Future<void> setSessionId(String sessionId) async {
    final prefs = await _preferences;
    await prefs.setString(_sessionIdKey, sessionId);
  }

  static Future<String?> getSessionId() async {
    final prefs = await _preferences;
    return prefs.getString(_sessionIdKey);
  }

  static Future<void> setUserId(String userId) async {
    final prefs = await _preferences;
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(_userIdKey);
  }

  static Future<void> setReferralData(Map<String, dynamic> data) async {
    final prefs = await _preferences;
    final jsonString = jsonEncode(data);
    await prefs.setString(_referralDataKey, jsonString);
  }

  static Future<Map<String, dynamic>?> getReferralData() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_referralDataKey);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
