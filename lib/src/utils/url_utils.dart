import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  static Future<bool> canLaunchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri.toString());
    } catch (e) {
      return false;
    }
  }

  static Future<bool> launchUrl(String url, {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri.toString(), mode: mode);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openAppStore({
    required String packageName,
    String? iosAppId,
  }) async {
    if (Platform.isAndroid) {
      final playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
      return await launchUrl(playStoreUrl);
    } else if (Platform.isIOS && iosAppId != null) {
      final appStoreUrl = 'https://apps.apple.com/app/id$iosAppId';
      return await launchUrl(appStoreUrl);
    }
    return false;
  }

  static String addParametersToUrl(String baseUrl, Map<String, String> parameters) {
    if (parameters.isEmpty) return baseUrl;
    
    final uri = Uri.parse(baseUrl);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.addAll(parameters);
    
    return uri.replace(queryParameters: newParams).toString();
  }

  static Map<String, String> extractParametersFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters;
    } catch (e) {
      return {};
    }
  }

  static String removeParametersFromUrl(String url, List<String> parametersToRemove) {
    try {
      final uri = Uri.parse(url);
      final newParams = Map<String, String>.from(uri.queryParameters);
      
      for (final param in parametersToRemove) {
        newParams.remove(param);
      }
      
      return uri.replace(queryParameters: newParams.isNotEmpty ? newParams : null).toString();
    } catch (e) {
      return url;
    }
  }

  static String buildDeepLink({
    required String scheme,
    required String host,
    String? path,
    Map<String, String>? parameters,
  }) {
    final uri = Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: parameters?.isNotEmpty == true ? parameters : null,
    );
    
    return uri.toString();
  }

  static bool isValidScheme(String scheme) {
    final schemeRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*$');
    return schemeRegex.hasMatch(scheme);
  }

  static bool isHttpUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static bool isDeepLink(String url) {
    return !isHttpUrl(url) && Uri.tryParse(url) != null;
  }

  static String? extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  static String? extractScheme(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme;
    } catch (e) {
      return null;
    }
  }

  static String normalizeUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.toString();
    } catch (e) {
      return url;
    }
  }

  static bool isSameOrigin(String url1, String url2) {
    try {
      final uri1 = Uri.parse(url1);
      final uri2 = Uri.parse(url2);
      
      return uri1.scheme == uri2.scheme &&
             uri1.host == uri2.host &&
             uri1.port == uri2.port;
    } catch (e) {
      return false;
    }
  }
}
