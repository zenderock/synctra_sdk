import 'package:meta/meta.dart';

@immutable
class DeepLink {
  final String id;
  final String originalUrl;
  final String shortUrl;
  final Map<String, dynamic> parameters;
  final String? fallbackUrl;
  final String? iosAppStoreUrl;
  final String? androidPlayStoreUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? campaignId;
  final String? referralCode;

  const DeepLink({
    required this.id,
    required this.originalUrl,
    required this.shortUrl,
    required this.parameters,
    this.fallbackUrl,
    this.iosAppStoreUrl,
    this.androidPlayStoreUrl,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.campaignId,
    this.referralCode,
  });

  factory DeepLink.fromJson(Map<String, dynamic> json) {
    return DeepLink(
      id: json['id'] as String,
      originalUrl: json['originalUrl'] as String,
      shortUrl: json['shortUrl'] as String,
      parameters: Map<String, dynamic>.from(json['parameters'] as Map),
      fallbackUrl: json['fallbackUrl'] as String?,
      iosAppStoreUrl: json['iosAppStoreUrl'] as String?,
      androidPlayStoreUrl: json['androidPlayStoreUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      campaignId: json['campaignId'] as String?,
      referralCode: json['referralCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalUrl': originalUrl,
      'shortUrl': shortUrl,
      'parameters': parameters,
      'fallbackUrl': fallbackUrl,
      'iosAppStoreUrl': iosAppStoreUrl,
      'androidPlayStoreUrl': androidPlayStoreUrl,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'campaignId': campaignId,
      'referralCode': referralCode,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => isActive && !isExpired;

  DeepLink copyWith({
    String? id,
    String? originalUrl,
    String? shortUrl,
    Map<String, dynamic>? parameters,
    String? fallbackUrl,
    String? iosAppStoreUrl,
    String? androidPlayStoreUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    String? campaignId,
    String? referralCode,
  }) {
    return DeepLink(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      shortUrl: shortUrl ?? this.shortUrl,
      parameters: parameters ?? this.parameters,
      fallbackUrl: fallbackUrl ?? this.fallbackUrl,
      iosAppStoreUrl: iosAppStoreUrl ?? this.iosAppStoreUrl,
      androidPlayStoreUrl: androidPlayStoreUrl ?? this.androidPlayStoreUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      campaignId: campaignId ?? this.campaignId,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeepLink && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DeepLink(id: $id, shortUrl: $shortUrl, isActive: $isActive)';
  }
}
