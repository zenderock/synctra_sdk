import 'package:meta/meta.dart';

@immutable
class ReferralCode {
  final String code;
  final String userId;
  final String? campaignId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int maxUses;
  final int currentUses;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final double? rewardAmount;
  final String? rewardType;

  const ReferralCode({
    required this.code,
    required this.userId,
    this.campaignId,
    required this.createdAt,
    this.expiresAt,
    this.maxUses = -1,
    this.currentUses = 0,
    this.isActive = true,
    this.metadata = const {},
    this.rewardAmount,
    this.rewardType,
  });

  factory ReferralCode.fromJson(Map<String, dynamic> json) {
    return ReferralCode(
      code: json['code'] as String,
      userId: json['userId'] as String,
      campaignId: json['campaignId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
      maxUses: json['maxUses'] as int? ?? -1,
      currentUses: json['currentUses'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble(),
      rewardType: json['rewardType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'userId': userId,
      'campaignId': campaignId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'maxUses': maxUses,
      'currentUses': currentUses,
      'isActive': isActive,
      'metadata': metadata,
      'rewardAmount': rewardAmount,
      'rewardType': rewardType,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get hasReachedMaxUses {
    if (maxUses == -1) return false;
    return currentUses >= maxUses;
  }

  bool get isValid => isActive && !isExpired && !hasReachedMaxUses;

  ReferralCode copyWith({
    String? code,
    String? userId,
    String? campaignId,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? maxUses,
    int? currentUses,
    bool? isActive,
    Map<String, dynamic>? metadata,
    double? rewardAmount,
    String? rewardType,
  }) {
    return ReferralCode(
      code: code ?? this.code,
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      rewardType: rewardType ?? this.rewardType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReferralCode && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return 'ReferralCode(code: $code, isValid: $isValid, uses: $currentUses/$maxUses)';
  }
}
