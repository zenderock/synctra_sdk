import 'dart:async';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../utils/utils.dart';
import 'api_service.dart';
import 'analytics_service.dart';
import 'app_install_service.dart';

class DeferredDeepLinkService {
  final ApiService _apiService;
  final AnalyticsService _analyticsService;
  final AppInstallService _appInstallService;
  
  Timer? _checkTimer;
  final Map<String, Completer<DeepLink?>> _pendingLinks = {};

  DeferredDeepLinkService(
    this._apiService,
    this._analyticsService,
    this._appInstallService,
  );

  Future<void> handleIncomingLink(String url) async {
    try {
      final uri = Uri.parse(url);
      final linkId = uri.queryParameters['linkId'];
      
      if (linkId == null) return;

      await _analyticsService.trackLinkClick(linkId, properties: {
        'url': url,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final response = await _apiService.get<DeepLink>(
        '/links/$linkId',
        fromJson: DeepLink.fromJson,
      );

      if (response.success && response.data != null) {
        final deepLink = response.data!;
        
        if (!deepLink.isValid) {
          await _handleExpiredLink(deepLink);
          return;
        }

        await _processDeepLink(deepLink);
      }
    } catch (e) {
      // Log error silently
    }
  }

  Future<DeepLink?> waitForDeferredLink({
    required String packageName,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final completer = Completer<DeepLink?>();
    final key = packageName;
    
    _pendingLinks[key] = completer;
    
    _startCheckingForDeferredLink(packageName);
    
    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete(null);
        _pendingLinks.remove(key);
      }
    });

    return completer.future;
  }

  void _startCheckingForDeferredLink(String packageName) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final deferredData = await _checkForDeferredData(packageName);
        
        if (deferredData != null) {
          timer.cancel();
          
          final completer = _pendingLinks.remove(packageName);
          if (completer != null && !completer.isCompleted) {
            completer.complete(deferredData);
          }
          
          await _analyticsService.trackAppInstall(
            deferredData.id,
            properties: {'deferred': true},
          );
        }
      } catch (e) {
        // Continue checking
      }
    });
  }

  Future<DeepLink?> _checkForDeferredData(String packageName) async {
    try {
      final deviceInfo = await DeviceUtils.getDeviceInfo();
      final deviceId = await StorageUtils.getDeviceId() ?? 
                      await _generateAndStoreDeviceId();

      final response = await _apiService.get<DeepLink>(
        '/deferred-links',
        queryParams: {
          'packageName': packageName,
          'deviceId': deviceId,
          'platform': deviceInfo['platform'] as String,
        },
        fromJson: DeepLink.fromJson,
      );

      if (response.success && response.data != null) {
        await _clearDeferredData(packageName, deviceId);
        return response.data;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _processDeepLink(DeepLink deepLink) async {
    try {
      final packageName = deepLink.parameters['packageName'] as String?;
      
      if (packageName != null) {
        final isInstalled = await _appInstallService.isAppInstalled(packageName);
        
        if (isInstalled) {
          await _openApp(deepLink, packageName);
        } else {
          await _handleAppNotInstalled(deepLink, packageName);
        }
      } else {
        await _openWebFallback(deepLink);
      }
    } catch (e) {
      await _openWebFallback(deepLink);
    }
  }

  Future<void> _openApp(DeepLink deepLink, String packageName) async {
    try {
      final parameters = Map<String, String>.from(deepLink.parameters);
      parameters.remove('packageName');
      
      final opened = await _appInstallService.openApp(
        packageName,
        parameters: parameters,
      );
      
      if (opened) {
        await _analyticsService.trackAppOpen(deepLink.id, properties: {
          'packageName': packageName,
          'parameters': parameters,
        });
      } else {
        await _openWebFallback(deepLink);
      }
    } catch (e) {
      await _openWebFallback(deepLink);
    }
  }

  Future<void> _handleAppNotInstalled(DeepLink deepLink, String packageName) async {
    try {
      await _storeDeferredData(deepLink, packageName);
      
      final iosAppId = deepLink.iosAppStoreUrl?.split('/').last;
      
      final opened = await _appInstallService.openAppStore(
        packageName: packageName,
        iosAppId: iosAppId,
        fallbackUrl: deepLink.fallbackUrl,
      );
      
      if (!opened) {
        await _openWebFallback(deepLink);
      }
    } catch (e) {
      await _openWebFallback(deepLink);
    }
  }

  Future<void> _openWebFallback(DeepLink deepLink) async {
    try {
      final fallbackUrl = deepLink.fallbackUrl ?? deepLink.originalUrl;
      await UrlUtils.launchUrl(fallbackUrl);
      
      await _analyticsService.trackLinkOpen(deepLink.id, properties: {
        'fallback': true,
        'url': fallbackUrl,
      });
    } catch (e) {
      // Failed to open fallback
    }
  }

  Future<void> _handleExpiredLink(DeepLink deepLink) async {
    try {
      if (deepLink.fallbackUrl != null) {
        await UrlUtils.launchUrl(deepLink.fallbackUrl!);
      }
      
      await _analyticsService.trackLinkOpen(deepLink.id, properties: {
        'expired': true,
        'fallback': deepLink.fallbackUrl != null,
      });
    } catch (e) {
      // Failed to handle expired link
    }
  }

  Future<void> _storeDeferredData(DeepLink deepLink, String packageName) async {
    try {
      final deviceId = await StorageUtils.getDeviceId() ?? 
                      await _generateAndStoreDeviceId();
      
      await _apiService.post('/deferred-links', body: {
        'linkId': deepLink.id,
        'packageName': packageName,
        'deviceId': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
        'parameters': deepLink.parameters,
      });
    } catch (e) {
      // Store locally as fallback
      await StorageUtils.setJson('deferred_link_$packageName', {
        'linkId': deepLink.id,
        'parameters': deepLink.parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _clearDeferredData(String packageName, String deviceId) async {
    try {
      await _apiService.delete('/deferred-links', queryParams: {
        'packageName': packageName,
        'deviceId': deviceId,
      });
    } catch (e) {
      // Clear local fallback
      await StorageUtils.remove('deferred_link_$packageName');
    }
  }

  Future<String> _generateAndStoreDeviceId() async {
    final deviceId = CryptoUtils.generateDeviceId();
    await StorageUtils.setDeviceId(deviceId);
    return deviceId;
  }

  Future<Map<String, dynamic>?> getLocalDeferredData(String packageName) async {
    return await StorageUtils.getJson('deferred_link_$packageName');
  }

  Future<void> clearLocalDeferredData(String packageName) async {
    await StorageUtils.remove('deferred_link_$packageName');
  }

  void dispose() {
    _checkTimer?.cancel();
    
    for (final completer in _pendingLinks.values) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
    _pendingLinks.clear();
  }

  @visibleForTesting
  Map<String, Completer<DeepLink?>> get pendingLinks => _pendingLinks;
}
