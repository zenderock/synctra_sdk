import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';

class SynctraSDK {
  static SynctraSDK? _instance;
  static SynctraSDK get instance => _instance ??= SynctraSDK._internal();

  SynctraSDK._internal();

  String? _apiBaseUrl;
  String? _projectId;
  String? _apiKey;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  // Callbacks
  Function(SynctraLinkData)? _onLinkReceived;
  Function(SynctraReferralData)? _onReferralDetected;
  Function(String error)? _onError;

  /// Initialise le SDK Synctra
  Future<void> initialize({
    required String apiBaseUrl,
    required String projectId,
    required String apiKey,
    Function(SynctraLinkData)? onLinkReceived,
    Function(SynctraReferralData)? onReferralDetected,
    Function(String error)? onError,
  }) async {
    _apiBaseUrl = apiBaseUrl;
    _projectId = projectId;
    _apiKey = apiKey;
    _onLinkReceived = onLinkReceived;
    _onReferralDetected = onReferralDetected;
    _onError = onError;

    _appLinks = AppLinks();

    // Vérifier si c'est la première installation
    await _checkFirstInstall();

    // Écouter les deep links
    await _setupDeepLinkListener();

    // Traiter le lien initial si l'app a été ouverte via un deep link
    await _handleInitialLink();
  }

  /// Vérifie si c'est la première installation et récupère la signature
  Future<void> _checkFirstInstall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstInstall =
          !prefs.containsKey('synctra_first_install_checked');

      if (isFirstInstall) {
        await prefs.setBool('synctra_first_install_checked', true);

        // Générer la signature du device
        final deviceSignature = await _generateDeviceSignature();

        // Chercher une signature correspondante dans la BD
        await _searchForSignature(deviceSignature);
      }
    } catch (e) {
      _onError
          ?.call('Erreur lors de la vérification de première installation: $e');
    }
  }

  /// Génère une signature unique basée sur les infos du device
  Future<String> _generateDeviceSignature() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String signature = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        signature =
            '${androidInfo.model}_${androidInfo.brand}_${androidInfo.device}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        signature =
            '${iosInfo.model}_${iosInfo.name}_${iosInfo.identifierForVendor}';
      }

      // Hash de la signature pour la sécurité
      final bytes = utf8.encode(signature);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      _onError?.call('Erreur génération signature: $e');
      return '';
    }
  }

  /// Recherche une signature correspondante dans la base de données
  Future<void> _searchForSignature(String deviceSignature) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/v1/sdk/match-signature'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey!,
        },
        body: jsonEncode({
          'device_signature': deviceSignature,
          'project_id': _projectId,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) {
          final linkId = data['link_id'];
          final referralCode = data['referral_code'];

          // Sauvegarder les infos localement
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('synctra_link_id', linkId);
          if (referralCode != null) {
            await prefs.setString('synctra_referral_code', referralCode);

            // Récupérer les détails du code de parrainage
            final referralData = await _fetchReferralData(referralCode);
            if (referralData != null) {
              _onReferralDetected?.call(referralData);
            }
          }
        }
      }
    } catch (e) {
      _onError?.call('Erreur recherche signature: $e');
    }
  }

  /// Configure l'écoute des deep links
  Future<void> _setupDeepLinkListener() async {
    try {
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) async {
          await _handleDeepLink(uri);
        },
        onError: (err) {
          _onError?.call('Erreur deep link: $err');
        },
      );
    } catch (e) {
      _onError?.call('Erreur setup deep link listener: $e');
    }
  }

  /// Traite le lien initial si l'app a été ouverte via un deep link
  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }
    } catch (e) {
      _onError?.call('Erreur lien initial: $e');
    }
  }

  /// Traite un deep link reçu
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      if (kDebugMode) {
        print('=== DEEP LINK REÇU ===');
        print('URI complète: $uri');
        print('Paramètres: ${uri.queryParameters}');
      }

      // Extraire les paramètres depuis l'URI
      final linkId = uri.queryParameters['id'];
      final referralCode = uri.queryParameters['rel'];

      if (kDebugMode) {
        print('Link ID: $linkId');
        print('Referral Code: $referralCode');
      }

      if (linkId != null) {
        // Cas 1: Lien dynamique (avec ou sans code de parrainage associé)
        if (kDebugMode) {
          print('Traitement lien dynamique: $linkId');
        }
        await _handleLinkId(linkId);
      } else if (referralCode != null) {
        // Cas 2: Code de parrainage simple
        if (kDebugMode) {
          print('Traitement code parrainage: $referralCode');
        }
        await _handleReferralCode(referralCode);
      } else {
        if (kDebugMode) {
          print('Aucun paramètre valide trouvé dans le deep link');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur traitement deep link: $e');
      }
      _onError?.call('Erreur traitement deep link: $e');
    }
  }

  /// Traite un ID de lien dynamique
  Future<void> _handleLinkId(String linkShortCode) async {
    try {
      if (kDebugMode) {
        print('=== TRAITEMENT LIEN SHORT CODE: $linkShortCode ===');
      }

      // Récupérer les données du lien d'abord pour obtenir l'ID numérique
      final linkData = await _fetchLinkData(linkShortCode);
      if (linkData != null) {
        if (kDebugMode) {
          print('Données lien récupérées, ID numérique: ${linkData.id}');
        }

        // Sauvegarder l'ID numérique du lien (pas le short_code)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('synctra_current_link_id', linkData.id);

        if (kDebugMode) {
          print('ID numérique lien sauvegardé localement: ${linkData.id}');
        }

        // Appeler le callback d'abord
        _onLinkReceived?.call(linkData);

        // Enregistrer la conversion avec l'ID numérique
        await _trackConversion(linkData.id);

        // Si le lien est lié à un code de parrainage
        if (linkData.referralCode != null) {
          await _handleReferralCode(linkData.referralCode!);
        }
      } else {
        if (kDebugMode) {
          print('Impossible de récupérer les données du lien');
        }
        _onError?.call('Lien non trouvé: $linkShortCode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception traitement lien: $e');
      }
      _onError?.call('Erreur traitement lien: $e');
    }
  }

  /// Traite un code de parrainage simple
  Future<void> _handleReferralCode(String referralCode) async {
    try {
      // Sauvegarder le code de parrainage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('synctra_referral_code', referralCode);

      // Récupérer les données du code de parrainage
      final referralData = await _fetchReferralData(referralCode);
      if (referralData != null) {
        _onReferralDetected?.call(referralData);
      }
    } catch (e) {
      _onError?.call('Erreur traitement code parrainage: $e');
    }
  }

  /// Récupère les données d'un lien
  Future<SynctraLinkData?> _fetchLinkData(String linkId) async {
    try {
      if (kDebugMode) {
        print('=== RÉCUPÉRATION DONNÉES LIEN ===');
        print(
            'URL: $_apiBaseUrl/api/v1/sdk/link/$linkId?project_id=$_projectId');
      }

      final response = await http.get(
        Uri.parse(
            '$_apiBaseUrl/api/v1/sdk/link/$linkId?project_id=$_projectId'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey!,
        },
      );

      if (kDebugMode) {
        print('Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Données lien récupérées: $data');
        }
        return SynctraLinkData.fromJson(data);
      } else {
        if (kDebugMode) {
          print('Erreur HTTP: ${response.statusCode} - ${response.body}');
        }
        _onError?.call('Erreur HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception récupération lien: $e');
      }
      _onError?.call('Erreur récupération données lien: $e');
    }
    return null;
  }

  /// Récupère les données d'un code de parrainage
  Future<SynctraReferralData?> _fetchReferralData(String referralCode) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_apiBaseUrl/api/v1/sdk/referral/$referralCode?project_id=$_projectId'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SynctraReferralData.fromJson(data);
      }
    } catch (e) {
      _onError?.call('Erreur récupération données parrainage: $e');
    }
    return null;
  }

  /// Récupère les données du lien actuel stockées localement
  Future<SynctraLinkData?> getCurrentLinkData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final linkId = prefs.getString('synctra_current_link_id');

      if (linkId != null) {
        return await _fetchLinkData(linkId);
      }
      return null;
    } catch (e) {
      _onError?.call('Erreur récupération lien actuel: $e');
      return null;
    }
  }

  /// Récupère le code de parrainage actuel stocké localement
  Future<String?> getCurrentReferralCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('synctra_referral_code');
    } catch (e) {
      _onError?.call('Erreur récupération code parrainage: $e');
      return null;
    }
  }

  /// Enregistre une conversion (ouverture app via lien)
  Future<void> _trackConversion(String linkId,
      {double? conversionValue}) async {
    try {
      if (kDebugMode) {
        print('=== TRACKING CONVERSION ===');
        print('Link ID: $linkId');
      }

      final deviceSignature = await _generateDeviceSignature();

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/v1/sdk/track-conversion'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey!,
        },
        body: jsonEncode({
          'link_id': linkId,
          'device_signature': deviceSignature,
          'project_id': _projectId,
          'conversion_value': conversionValue,
        }),
      );

      if (kDebugMode) {
        print('Conversion response: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Erreur conversion: ${response.statusCode} - ${response.body}');
        }
        _onError?.call('Erreur enregistrement conversion: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception tracking conversion: $e');
      }
      _onError?.call('Erreur enregistrement conversion: $e');
    }
  }

  /// Récupère l'ID du lien actuel stocké localement
  Future<String?> getCurrentLinkId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('synctra_current_link_id');
    } catch (e) {
      _onError?.call('Erreur récupération ID lien actuel: $e');
      return null;
    }
  }

  /// Récupère le code de parrainage stocké localement (alias pour getCurrentReferralCode)
  Future<String?> getReferralCode() async {
    return await getCurrentReferralCode();
  }

  /// Enregistre une conversion manuelle avec valeur
  Future<void> trackConversion({double? conversionValue}) async {
    final linkId = await getCurrentLinkId();
    if (linkId != null) {
      await _trackConversion(linkId, conversionValue: conversionValue);
    } else {
      _onError?.call('Aucun lien actuel pour tracker la conversion');
    }
  }

  /// Nettoie les ressources
  void dispose() {
    _linkSubscription?.cancel();
  }
}

/// Modèle de données pour un lien Synctra
class SynctraLinkData {
  final String id;
  final String shortCode;
  final String originalUrl;
  final String? title;
  final String? description;
  final String? referralCode;
  final Map<String, dynamic>? utmParams;

  SynctraLinkData({
    required this.id,
    required this.shortCode,
    required this.originalUrl,
    this.title,
    this.description,
    this.referralCode,
    this.utmParams,
  });

  factory SynctraLinkData.fromJson(Map<String, dynamic> json) {
    return SynctraLinkData(
      id: json['id'],
      shortCode: json['short_code'],
      originalUrl: json['original_url'],
      title: json['title'],
      description: json['description'],
      referralCode: json['referral_code'],
      utmParams: json['utm_params'],
    );
  }
}

/// Modèle de données pour un code de parrainage
class SynctraReferralData {
  final String code;
  final String rewardType;
  final double rewardValue;
  final int? maxUses;
  final int currentUses;
  final bool isActive;
  final DateTime? expiresAt;

  SynctraReferralData({
    required this.code,
    required this.rewardType,
    required this.rewardValue,
    this.maxUses,
    required this.currentUses,
    required this.isActive,
    this.expiresAt,
  });

  factory SynctraReferralData.fromJson(Map<String, dynamic> json) {
    return SynctraReferralData(
      code: json['code'],
      rewardType: json['reward_type'],
      rewardValue: json['reward_value'].toDouble(),
      maxUses: json['max_uses'],
      currentUses: json['current_uses'],
      isActive: json['is_active'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }
}
