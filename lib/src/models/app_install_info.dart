import 'package:meta/meta.dart';

enum InstallStatus {
  unknown,
  installed,
  notInstalled,
  checking,
}

@immutable
class AppInstallInfo {
  final String packageName;
  final InstallStatus status;
  final String? version;
  final DateTime? installedAt;
  final DateTime checkedAt;
  final String? platform;
  final Map<String, dynamic> metadata;

  const AppInstallInfo({
    required this.packageName,
    required this.status,
    this.version,
    this.installedAt,
    required this.checkedAt,
    this.platform,
    this.metadata = const {},
  });

  factory AppInstallInfo.fromJson(Map<String, dynamic> json) {
    return AppInstallInfo(
      packageName: json['packageName'] as String,
      status: InstallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InstallStatus.unknown,
      ),
      version: json['version'] as String?,
      installedAt: json['installedAt'] != null 
          ? DateTime.parse(json['installedAt'] as String) 
          : null,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
      platform: json['platform'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'status': status.name,
      'version': version,
      'installedAt': installedAt?.toIso8601String(),
      'checkedAt': checkedAt.toIso8601String(),
      'platform': platform,
      'metadata': metadata,
    };
  }

  AppInstallInfo copyWith({
    String? packageName,
    InstallStatus? status,
    String? version,
    DateTime? installedAt,
    DateTime? checkedAt,
    String? platform,
    Map<String, dynamic>? metadata,
  }) {
    return AppInstallInfo(
      packageName: packageName ?? this.packageName,
      status: status ?? this.status,
      version: version ?? this.version,
      installedAt: installedAt ?? this.installedAt,
      checkedAt: checkedAt ?? this.checkedAt,
      platform: platform ?? this.platform,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppInstallInfo && 
           other.packageName == packageName &&
           other.platform == platform;
  }

  @override
  int get hashCode => Object.hash(packageName, platform);

  @override
  String toString() {
    return 'AppInstallInfo(packageName: $packageName, status: $status, version: $version)';
  }
}
