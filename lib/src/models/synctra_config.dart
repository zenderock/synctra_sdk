import 'package:meta/meta.dart';

@immutable
class SynctraConfig {
  final String apiKey;
  final String baseUrl;
  final String projectId;
  final bool enableAnalytics;
  final bool enableDeepLinking;
  final bool enableReferrals;
  final Duration timeout;
  final int maxRetries;
  final bool debugMode;
  final String? customDomain;
  final Map<String, String> defaultParameters;

  const SynctraConfig({
    required this.apiKey,
    this.baseUrl = 'https://api.synctra.link',
    required this.projectId,
    this.enableAnalytics = true,
    this.enableDeepLinking = true,
    this.enableReferrals = true,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.debugMode = false,
    this.customDomain,
    this.defaultParameters = const {},
  });

  factory SynctraConfig.fromJson(Map<String, dynamic> json) {
    return SynctraConfig(
      apiKey: json['apiKey'] as String,
      baseUrl: json['baseUrl'] as String? ?? 'https://api.synctra.link',
      projectId: json['projectId'] as String,
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      enableDeepLinking: json['enableDeepLinking'] as bool? ?? true,
      enableReferrals: json['enableReferrals'] as bool? ?? true,
      timeout: Duration(
        milliseconds: json['timeoutMs'] as int? ?? 30000,
      ),
      maxRetries: json['maxRetries'] as int? ?? 3,
      debugMode: json['debugMode'] as bool? ?? false,
      customDomain: json['customDomain'] as String?,
      defaultParameters: Map<String, String>.from(
        json['defaultParameters'] as Map? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'projectId': projectId,
      'enableAnalytics': enableAnalytics,
      'enableDeepLinking': enableDeepLinking,
      'enableReferrals': enableReferrals,
      'timeoutMs': timeout.inMilliseconds,
      'maxRetries': maxRetries,
      'debugMode': debugMode,
      'customDomain': customDomain,
      'defaultParameters': defaultParameters,
    };
  }

  SynctraConfig copyWith({
    String? apiKey,
    String? baseUrl,
    String? projectId,
    bool? enableAnalytics,
    bool? enableDeepLinking,
    bool? enableReferrals,
    Duration? timeout,
    int? maxRetries,
    bool? debugMode,
    String? customDomain,
    Map<String, String>? defaultParameters,
  }) {
    return SynctraConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      projectId: projectId ?? this.projectId,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableDeepLinking: enableDeepLinking ?? this.enableDeepLinking,
      enableReferrals: enableReferrals ?? this.enableReferrals,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      debugMode: debugMode ?? this.debugMode,
      customDomain: customDomain ?? this.customDomain,
      defaultParameters: defaultParameters ?? this.defaultParameters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SynctraConfig &&
        other.apiKey == apiKey &&
        other.projectId == projectId;
  }

  @override
  int get hashCode => Object.hash(apiKey, projectId);

  @override
  String toString() {
    return 'SynctraConfig(projectId: $projectId, baseUrl: $baseUrl, debugMode: $debugMode)';
  }
}
