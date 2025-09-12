import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    final deviceData = <String, dynamic>{
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'platform': _getPlatformName(),
      'isDebugMode': kDebugMode,
    };

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceData.addAll({
        'deviceModel': androidInfo.model,
        'deviceBrand': androidInfo.brand,
        'deviceManufacturer': androidInfo.manufacturer,
        'androidVersion': androidInfo.version.release,
        'androidSdkInt': androidInfo.version.sdkInt,
        'deviceId': androidInfo.id,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceData.addAll({
        'deviceModel': iosInfo.model,
        'deviceName': iosInfo.name,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'deviceId': iosInfo.identifierForVendor,
      });
    } else if (Platform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      deviceData.addAll({
        'computerName': windowsInfo.computerName,
        'userName': windowsInfo.userName,
        'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
      });
    } else if (Platform.isMacOS) {
      final macInfo = await _deviceInfo.macOsInfo;
      deviceData.addAll({
        'computerName': macInfo.computerName,
        'hostName': macInfo.hostName,
        'arch': macInfo.arch,
        'model': macInfo.model,
      });
    } else if (Platform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      deviceData.addAll({
        'name': linuxInfo.name,
        'version': linuxInfo.version,
        'id': linuxInfo.id,
        'prettyName': linuxInfo.prettyName,
      });
    }

    return deviceData;
  }

  static String _getPlatformName() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    if (kIsWeb) return 'web';
    return 'unknown';
  }

  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
