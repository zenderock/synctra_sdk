import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'models/models.dart';
import 'services/services.dart';
import 'exceptions/exceptions.dart';
import 'utils/utils.dart';

class SynctraSDK {
  static SynctraSDK? _instance;
  static SynctraConfig? _config;
  
  late final ApiService _apiService;
  late final DeepLinkService _deepLinkService;
  late final AnalyticsService _analyticsService;
  late final ReferralService _referralService;
  late final AppInstallService _appInstallService;
  late final DeferredDeepLinkService _deferredDeepLinkService;
  
  bool _isInitialized = false;
  String? _sessionId;
  String? _deviceId;
  String? _userId;

  SynctraSDK._internal();

  static SynctraSDK get instance {
    _instance ??= SynctraSDK._internal();
    return _instance!;
  }

  static Future<void> initialize(SynctraConfig config) async {
    final sdk = SynctraSDK.instance;
    _config = config;
    
    await sdk._initialize(config);
  }

  Future<void> _initialize(SynctraConfig config) async {
    try {
      final validator = LinkValidator();
      validator.validateApiKey(config.apiKey, 'apiKey');
      validator.validateProjectId(config.projectId, 'projectId');
      
      _apiService = ApiService(config);
      _deepLinkService = DeepLinkService(_apiService);
      _analyticsService = AnalyticsService(_apiService);
      _referralService = ReferralService(_apiService);
      _appInstallService = AppInstallService(_apiService);
      _deferredDeepLinkService = DeferredDeepLinkService(
        _apiService,
        _analyticsService,
        _appInstallService,
      );

      await _initializeSession();
      _isInitialized = true;
      
      if (config.debugMode) {
        debugPrint('SynctraSDK initialisé avec succès');
      }
    } catch (e) {
      throw ConfigurationException(
        'Erreur lors de l\'initialisation du SDK: ${e.toString()}',
        code: 'INITIALIZATION_FAILED',
        originalError: e,
      );
    }
  }

  Future<void> _initializeSession() async {
    _deviceId = await StorageUtils.getDeviceId();
    if (_deviceId == null) {
      _deviceId = CryptoUtils.generateDeviceId();
      await StorageUtils.setDeviceId(_deviceId!);
    }

    _sessionId = CryptoUtils.generateSessionId();
    await StorageUtils.setSessionId(_sessionId!);

    _userId = await StorageUtils.getUserId();
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw ConfigurationException.notInitialized();
    }
  }

  // Deep Link Management
  Future<DeepLink> createLink({
    required String originalUrl,
    Map<String, dynamic>? parameters,
    String? fallbackUrl,
    String? iosAppStoreUrl,
    String? androidPlayStoreUrl,
    DateTime? expiresAt,
    String? campaignId,
    String? referralCode,
    LinkMetadata? metadata,
  }) async {
    _ensureInitialized();
    
    final link = await _deepLinkService.createLink(
      originalUrl: originalUrl,
      parameters: parameters,
      fallbackUrl: fallbackUrl,
      iosAppStoreUrl: iosAppStoreUrl,
      androidPlayStoreUrl: androidPlayStoreUrl,
      expiresAt: expiresAt,
      campaignId: campaignId,
      referralCode: referralCode,
      metadata: metadata,
    );

    if (_config!.enableAnalytics) {
      await _analyticsService.trackEvent(
        type: AnalyticsEventType.linkCreated,
        linkId: link.id,
        properties: {
          'originalUrl': originalUrl,
          'hasParameters': parameters?.isNotEmpty ?? false,
          'hasFallback': fallbackUrl != null,
          'hasExpiration': expiresAt != null,
          'campaignId': campaignId,
          'referralCode': referralCode,
        },
      );
    }

    return link;
  }

  Future<DeepLink?> getLink(String linkId) async {
    _ensureInitialized();
    return await _deepLinkService.getLink(linkId);
  }

  Future<List<DeepLink>> getLinks({
    int? limit,
    int? offset,
    String? campaignId,
    bool? isActive,
  }) async {
    _ensureInitialized();
    return await _deepLinkService.getLinks(
      limit: limit,
      offset: offset,
      campaignId: campaignId,
      isActive: isActive,
    );
  }

  Future<String> shortenUrl(String originalUrl) async {
    _ensureInitialized();
    return await _deepLinkService.shortenUrl(originalUrl);
  }

  // Deferred Deep Linking
  Future<void> handleIncomingLink(String url) async {
    _ensureInitialized();
    await _deferredDeepLinkService.handleIncomingLink(url);
  }

  Future<DeepLink?> waitForDeferredLink({
    required String packageName,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    _ensureInitialized();
    return await _deferredDeepLinkService.waitForDeferredLink(
      packageName: packageName,
      timeout: timeout,
    );
  }

  // Analytics
  Future<void> trackEvent({
    required AnalyticsEventType type,
    required String linkId,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    
    if (!_config!.enableAnalytics) return;
    
    await _analyticsService.trackEvent(
      type: type,
      linkId: linkId,
      properties: properties,
      userId: _userId,
      sessionId: _sessionId,
      deviceId: _deviceId,
    );
  }

  Future<void> trackLinkClick(String linkId, {Map<String, dynamic>? properties}) async {
    await trackEvent(
      type: AnalyticsEventType.linkClicked,
      linkId: linkId,
      properties: properties,
    );
  }

  Future<void> trackConversion(String linkId, {
    double? value,
    String? currency,
    Map<String, dynamic>? properties,
  }) async {
    _ensureInitialized();
    
    if (!_config!.enableAnalytics) return;
    
    await _analyticsService.trackConversion(
      linkId,
      value: value,
      currency: currency,
      properties: properties,
    );
  }

  // Referral Management
  Future<ReferralCode> createReferralCode({
    String? customCode,
    String? campaignId,
    DateTime? expiresAt,
    int maxUses = -1,
    double? rewardAmount,
    String? rewardType,
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();
    
    if (!_config!.enableReferrals) {
      throw ConfigurationException(
        'Les codes de parrainage ne sont pas activés dans la configuration',
        code: 'REFERRALS_DISABLED',
      );
    }

    if (_userId == null) {
      throw ConfigurationException(
        'Un utilisateur doit être connecté pour créer un code de parrainage',
        code: 'USER_NOT_SET',
      );
    }

    return await _referralService.createReferralCode(
      userId: _userId!,
      customCode: customCode,
      campaignId: campaignId,
      expiresAt: expiresAt,
      maxUses: maxUses,
      rewardAmount: rewardAmount,
      rewardType: rewardType,
      metadata: metadata,
    );
  }

  Future<bool> validateReferralCode(String code) async {
    _ensureInitialized();
    return await _referralService.validateReferralCode(code);
  }

  Future<ReferralCode> useReferralCode(String code) async {
    _ensureInitialized();
    
    if (_userId == null) {
      throw ConfigurationException(
        'Un utilisateur doit être connecté pour utiliser un code de parrainage',
        code: 'USER_NOT_SET',
      );
    }

    return await _referralService.useReferralCode(code, _userId!);
  }

  // App Installation
  Future<bool> isAppInstalled(String packageName) async {
    _ensureInitialized();
    return await _appInstallService.isAppInstalled(packageName);
  }

  Future<bool> openApp(String packageName, {Map<String, String>? parameters}) async {
    _ensureInitialized();
    return await _appInstallService.openApp(packageName, parameters: parameters);
  }

  Future<bool> openAppStore({
    required String packageName,
    String? iosAppId,
    String? fallbackUrl,
  }) async {
    _ensureInitialized();
    return await _appInstallService.openAppStore(
      packageName: packageName,
      iosAppId: iosAppId,
      fallbackUrl: fallbackUrl,
    );
  }

  // User Management
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await StorageUtils.setUserId(userId);
  }

  String? get userId => _userId;
  String? get sessionId => _sessionId;
  String? get deviceId => _deviceId;
  SynctraConfig? get config => _config;
  bool get isInitialized => _isInitialized;

  // Analytics Flush
  Future<void> flushAnalytics() async {
    _ensureInitialized();
    await _analyticsService.flush();
  }

  // Cleanup
  Future<void> dispose() async {
    if (_isInitialized) {
      await _analyticsService.flush();
      _analyticsService.dispose();
      _deferredDeepLinkService.dispose();
      _apiService.dispose();
      _isInitialized = false;
    }
  }

  // Debug helpers
  @visibleForTesting
  DeepLinkService get deepLinkService => _deepLinkService;
  
  @visibleForTesting
  AnalyticsService get analyticsService => _analyticsService;
  
  @visibleForTesting
  ReferralService get referralService => _referralService;
  
  @visibleForTesting
  AppInstallService get appInstallService => _appInstallService;
  
  @visibleForTesting
  DeferredDeepLinkService get deferredDeepLinkService => _deferredDeepLinkService;
}
