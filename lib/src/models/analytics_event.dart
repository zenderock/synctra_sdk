import 'package:meta/meta.dart';

enum AnalyticsEventType {
  linkCreated,
  linkClicked,
  linkOpened,
  appInstalled,
  appOpened,
  referralUsed,
  conversionCompleted,
  customEvent,
}

@immutable
class AnalyticsEvent {
  final String id;
  final AnalyticsEventType type;
  final String linkId;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final String? userId;
  final String? sessionId;
  final String? deviceId;
  final String? platform;
  final String? appVersion;
  final String? userAgent;
  final String? ipAddress;
  final String? country;
  final String? city;
  final String? referrer;

  const AnalyticsEvent({
    required this.id,
    required this.type,
    required this.linkId,
    required this.timestamp,
    this.properties = const {},
    this.userId,
    this.sessionId,
    this.deviceId,
    this.platform,
    this.appVersion,
    this.userAgent,
    this.ipAddress,
    this.country,
    this.city,
    this.referrer,
  });

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      id: json['id'] as String,
      type: AnalyticsEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AnalyticsEventType.customEvent,
      ),
      linkId: json['linkId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
      userId: json['userId'] as String?,
      sessionId: json['sessionId'] as String?,
      deviceId: json['deviceId'] as String?,
      platform: json['platform'] as String?,
      appVersion: json['appVersion'] as String?,
      userAgent: json['userAgent'] as String?,
      ipAddress: json['ipAddress'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      referrer: json['referrer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'linkId': linkId,
      'timestamp': timestamp.toIso8601String(),
      'properties': properties,
      'userId': userId,
      'sessionId': sessionId,
      'deviceId': deviceId,
      'platform': platform,
      'appVersion': appVersion,
      'userAgent': userAgent,
      'ipAddress': ipAddress,
      'country': country,
      'city': city,
      'referrer': referrer,
    };
  }

  AnalyticsEvent copyWith({
    String? id,
    AnalyticsEventType? type,
    String? linkId,
    DateTime? timestamp,
    Map<String, dynamic>? properties,
    String? userId,
    String? sessionId,
    String? deviceId,
    String? platform,
    String? appVersion,
    String? userAgent,
    String? ipAddress,
    String? country,
    String? city,
    String? referrer,
  }) {
    return AnalyticsEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      linkId: linkId ?? this.linkId,
      timestamp: timestamp ?? this.timestamp,
      properties: properties ?? this.properties,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      deviceId: deviceId ?? this.deviceId,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      userAgent: userAgent ?? this.userAgent,
      ipAddress: ipAddress ?? this.ipAddress,
      country: country ?? this.country,
      city: city ?? this.city,
      referrer: referrer ?? this.referrer,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnalyticsEvent(id: $id, type: $type, linkId: $linkId)';
  }
}
