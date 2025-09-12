import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../exceptions/exceptions.dart';
import '../utils/utils.dart';
import 'api_service.dart';

class AppInstallService {
  final ApiService _apiService;

  AppInstallService(this._apiService);

  Future<AppInstallInfo> checkAppInstallation(String packageName) async {
    if (packageName.isEmpty) {
      throw ValidationException.required('packageName');
    }

    try {
      final deviceInfo = await DeviceUtils.getDeviceInfo();
      final platform = deviceInfo['platform'] as String;
      
      InstallStatus status = InstallStatus.unknown;
      String? version;
      DateTime? installedAt;

      if (Platform.isAndroid) {
        status = await _checkAndroidApp(packageName);
      } else if (Platform.isIOS) {
        status = await _checkIOSApp(packageName);
      }

      final appInfo = AppInstallInfo(
        packageName: packageName,
        status: status,
        version: version,
        installedAt: installedAt,
        checkedAt: DateTime.now(),
        platform: platform,
        metadata: deviceInfo,
      );

      await _reportInstallStatus(appInfo);
      return appInfo;
    } catch (e) {
      return AppInstallInfo(
        packageName: packageName,
        status: InstallStatus.unknown,
        checkedAt: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  Future<InstallStatus> _checkAndroidApp(String packageName) async {
    try {
      final uri = Uri.parse('market://details?id=$packageName');
      final canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        final appUri = Uri.parse('package:$packageName');
        final isInstalled = await canLaunchUrl(appUri);
        return isInstalled ? InstallStatus.installed : InstallStatus.notInstalled;
      }
      
      return InstallStatus.unknown;
    } catch (e) {
      return InstallStatus.unknown;
    }
  }

  Future<InstallStatus> _checkIOSApp(String packageName) async {
    try {
      final uri = Uri.parse('$packageName://');
      final isInstalled = await canLaunchUrl(uri);
      return isInstalled ? InstallStatus.installed : InstallStatus.notInstalled;
    } catch (e) {
      return InstallStatus.unknown;
    }
  }

  Future<bool> openApp(String packageName, {Map<String, String>? parameters}) async {
    if (packageName.isEmpty) {
      throw ValidationException.required('packageName');
    }

    try {
      String deepLinkUrl;
      
      if (Platform.isAndroid) {
        deepLinkUrl = 'package:$packageName';
      } else if (Platform.isIOS) {
        deepLinkUrl = '$packageName://';
      } else {
        return false;
      }

      if (parameters != null && parameters.isNotEmpty) {
        deepLinkUrl = UrlUtils.addParametersToUrl(deepLinkUrl, parameters);
      }

      final uri = Uri.parse(deepLinkUrl);
      return await launchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  Future<bool> openAppStore({
    required String packageName,
    String? iosAppId,
    String? fallbackUrl,
  }) async {
    if (packageName.isEmpty) {
      throw ValidationException.required('packageName');
    }

    try {
      if (Platform.isAndroid) {
        final playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
        final uri = Uri.parse(playStoreUrl);
        return await launchUrl(uri);
      } else if (Platform.isIOS && iosAppId != null) {
        final appStoreUrl = 'https://apps.apple.com/app/id$iosAppId';
        final uri = Uri.parse(appStoreUrl);
        return await launchUrl(uri);
      } else if (fallbackUrl != null) {
        final uri = Uri.parse(fallbackUrl);
        return await launchUrl(uri);
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _reportInstallStatus(AppInstallInfo appInfo) async {
    try {
      await _apiService.post(
        '/apps/install-status',
        body: appInfo.toJson(),
      );
    } catch (e) {
      // Ignore reporting errors
    }
  }

  Future<List<AppInstallInfo>> getInstallHistory({
    String? packageName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    
    if (packageName != null) queryParams['packageName'] = packageName;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final response = await _apiService.get<List<AppInstallInfo>>(
      '/apps/install-history',
      queryParams: queryParams,
      fromJson: (json) => (json['installations'] as List)
          .map((item) => AppInstallInfo.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération de l\'historique d\'installation',
        code: 'INSTALL_HISTORY_FAILED',
      );
    }

    return response.data!;
  }

  Future<Map<String, dynamic>> getInstallAnalytics({
    String? packageName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    
    if (packageName != null) queryParams['packageName'] = packageName;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final response = await _apiService.get<Map<String, dynamic>>(
      '/apps/install-analytics',
      queryParams: queryParams,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération des analytics d\'installation',
        code: 'INSTALL_ANALYTICS_FAILED',
      );
    }

    return response.data!;
  }

  Future<bool> isAppInstalled(String packageName) async {
    final appInfo = await checkAppInstallation(packageName);
    return appInfo.status == InstallStatus.installed;
  }

  Future<void> trackAppInstall(String packageName, String linkId) async {
    final appInfo = AppInstallInfo(
      packageName: packageName,
      status: InstallStatus.installed,
      installedAt: DateTime.now(),
      checkedAt: DateTime.now(),
      platform: DeviceUtils.isAndroid ? 'android' : 'ios',
      metadata: {'linkId': linkId},
    );

    await _reportInstallStatus(appInfo);
  }
}
