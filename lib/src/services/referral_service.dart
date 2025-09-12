import 'dart:async';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../exceptions/exceptions.dart';
import '../utils/utils.dart';
import 'api_service.dart';

class ReferralService {
  final ApiService _apiService;
  final LinkValidator _validator;

  ReferralService(this._apiService) : _validator = LinkValidator();

  Future<ReferralCode> createReferralCode({
    required String userId,
    String? customCode,
    String? campaignId,
    DateTime? expiresAt,
    int maxUses = -1,
    double? rewardAmount,
    String? rewardType,
    Map<String, dynamic>? metadata,
  }) async {
    _validator.validateRequired(userId, 'userId');
    
    if (customCode != null) {
      _validator.validateReferralCode(customCode, 'customCode');
    }

    final body = {
      'userId': userId,
      'code': customCode ?? CryptoUtils.generateReferralCode(),
      'campaignId': campaignId,
      'expiresAt': expiresAt?.toIso8601String(),
      'maxUses': maxUses,
      'rewardAmount': rewardAmount,
      'rewardType': rewardType,
      'metadata': metadata ?? {},
    };

    final response = await _apiService.post<ReferralCode>(
      '/referrals',
      body: body,
      fromJson: ReferralCode.fromJson,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la création du code de parrainage',
        code: 'REFERRAL_CREATION_FAILED',
      );
    }

    return response.data!;
  }

  Future<ReferralCode?> getReferralCode(String code) async {
    _validator.validateReferralCode(code, 'code');

    final response = await _apiService.get<ReferralCode>(
      '/referrals/$code',
      fromJson: ReferralCode.fromJson,
    );

    if (!response.success) {
      if (response.statusCode == 404) {
        return null;
      }
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération du code de parrainage',
        code: 'REFERRAL_FETCH_FAILED',
      );
    }

    return response.data;
  }

  Future<List<ReferralCode>> getUserReferralCodes(String userId) async {
    _validator.validateRequired(userId, 'userId');

    final response = await _apiService.get<List<ReferralCode>>(
      '/referrals',
      queryParams: {'userId': userId},
      fromJson: (json) => (json['referrals'] as List)
          .map((item) => ReferralCode.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération des codes de parrainage',
        code: 'REFERRALS_FETCH_FAILED',
      );
    }

    return response.data!;
  }

  Future<bool> validateReferralCode(String code) async {
    try {
      final referralCode = await getReferralCode(code);
      return referralCode?.isValid ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<ReferralCode> useReferralCode(String code, String userId) async {
    _validator.validateReferralCode(code, 'code');
    _validator.validateRequired(userId, 'userId');

    final body = {
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final response = await _apiService.post<ReferralCode>(
      '/referrals/$code/use',
      body: body,
      fromJson: ReferralCode.fromJson,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de l\'utilisation du code de parrainage',
        code: 'REFERRAL_USE_FAILED',
      );
    }

    return response.data!;
  }

  Future<ReferralCode> updateReferralCode(
    String code, {
    DateTime? expiresAt,
    int? maxUses,
    bool? isActive,
    double? rewardAmount,
    String? rewardType,
    Map<String, dynamic>? metadata,
  }) async {
    _validator.validateReferralCode(code, 'code');

    final body = <String, dynamic>{};
    
    if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();
    if (maxUses != null) body['maxUses'] = maxUses;
    if (isActive != null) body['isActive'] = isActive;
    if (rewardAmount != null) body['rewardAmount'] = rewardAmount;
    if (rewardType != null) body['rewardType'] = rewardType;
    if (metadata != null) body['metadata'] = metadata;

    final response = await _apiService.put<ReferralCode>(
      '/referrals/$code',
      body: body,
      fromJson: ReferralCode.fromJson,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la mise à jour du code de parrainage',
        code: 'REFERRAL_UPDATE_FAILED',
      );
    }

    return response.data!;
  }

  Future<void> deleteReferralCode(String code) async {
    _validator.validateReferralCode(code, 'code');

    final response = await _apiService.delete('/referrals/$code');

    if (!response.success) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la suppression du code de parrainage',
        code: 'REFERRAL_DELETE_FAILED',
      );
    }
  }

  Future<Map<String, dynamic>> getReferralAnalytics(
    String code, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _validator.validateReferralCode(code, 'code');

    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      '/referrals/$code/analytics',
      queryParams: queryParams,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération des analytics de parrainage',
        code: 'REFERRAL_ANALYTICS_FAILED',
      );
    }

    return response.data!;
  }

  Future<void> saveReferralData(String code, Map<String, dynamic> data) async {
    final referralData = {
      'code': code,
      'timestamp': DateTime.now().toIso8601String(),
      'data': data,
    };
    
    await StorageUtils.setReferralData(referralData);
  }

  Future<Map<String, dynamic>?> getSavedReferralData() async {
    return await StorageUtils.getReferralData();
  }

  Future<void> clearSavedReferralData() async {
    await StorageUtils.remove('referral_data');
  }

  @visibleForTesting
  LinkValidator get validator => _validator;
}
