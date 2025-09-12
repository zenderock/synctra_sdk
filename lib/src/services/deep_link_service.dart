import 'dart:async';
import 'package:meta/meta.dart';

import '../models/models.dart';
import '../exceptions/exceptions.dart';
import '../utils/utils.dart';
import 'api_service.dart';

class DeepLinkService {
  final ApiService _apiService;
  final LinkValidator _validator;

  DeepLinkService(this._apiService) : _validator = LinkValidator();

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
    _validator.validateUrl(originalUrl, 'originalUrl');
    
    if (fallbackUrl != null) {
      _validator.validateUrl(fallbackUrl, 'fallbackUrl');
    }
    
    if (iosAppStoreUrl != null) {
      _validator.validateUrl(iosAppStoreUrl, 'iosAppStoreUrl');
    }
    
    if (androidPlayStoreUrl != null) {
      _validator.validateUrl(androidPlayStoreUrl, 'androidPlayStoreUrl');
    }

    final body = {
      'originalUrl': originalUrl,
      'parameters': parameters ?? {},
      'fallbackUrl': fallbackUrl,
      'iosAppStoreUrl': iosAppStoreUrl,
      'androidPlayStoreUrl': androidPlayStoreUrl,
      'expiresAt': expiresAt?.toIso8601String(),
      'campaignId': campaignId,
      'referralCode': referralCode,
      'metadata': metadata?.toJson(),
    };

    final response = await _apiService.post<DeepLink>(
      '/links',
      body: body,
      fromJson: DeepLink.fromJson,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la création du lien',
        code: 'LINK_CREATION_FAILED',
      );
    }

    return response.data!;
  }

  Future<DeepLink?> getLink(String linkId) async {
    if (linkId.isEmpty) {
      throw ValidationException.required('linkId');
    }

    final response = await _apiService.get<DeepLink>(
      '/links/$linkId',
      fromJson: DeepLink.fromJson,
    );

    if (!response.success) {
      if (response.statusCode == 404) {
        return null;
      }
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération du lien',
        code: 'LINK_FETCH_FAILED',
      );
    }

    return response.data;
  }

  Future<List<DeepLink>> getLinks({
    int? limit,
    int? offset,
    String? campaignId,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{};
    
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();
    if (campaignId != null) queryParams['campaignId'] = campaignId;
    if (isActive != null) queryParams['isActive'] = isActive.toString();

    final response = await _apiService.get<List<DeepLink>>(
      '/links',
      queryParams: queryParams,
      fromJson: (json) => (json['links'] as List)
          .map((item) => DeepLink.fromJson(item as Map<String, dynamic>))
          .toList(),
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération des liens',
        code: 'LINKS_FETCH_FAILED',
      );
    }

    return response.data!;
  }

  Future<DeepLink> updateLink(
    String linkId, {
    String? originalUrl,
    Map<String, dynamic>? parameters,
    String? fallbackUrl,
    String? iosAppStoreUrl,
    String? androidPlayStoreUrl,
    DateTime? expiresAt,
    bool? isActive,
    String? campaignId,
    String? referralCode,
  }) async {
    if (linkId.isEmpty) {
      throw ValidationException.required('linkId');
    }

    final body = <String, dynamic>{};
    
    if (originalUrl != null) {
      _validator.validateUrl(originalUrl, 'originalUrl');
      body['originalUrl'] = originalUrl;
    }
    
    if (parameters != null) body['parameters'] = parameters;
    if (fallbackUrl != null) {
      _validator.validateUrl(fallbackUrl, 'fallbackUrl');
      body['fallbackUrl'] = fallbackUrl;
    }
    if (iosAppStoreUrl != null) {
      _validator.validateUrl(iosAppStoreUrl, 'iosAppStoreUrl');
      body['iosAppStoreUrl'] = iosAppStoreUrl;
    }
    if (androidPlayStoreUrl != null) {
      _validator.validateUrl(androidPlayStoreUrl, 'androidPlayStoreUrl');
      body['androidPlayStoreUrl'] = androidPlayStoreUrl;
    }
    if (expiresAt != null) body['expiresAt'] = expiresAt.toIso8601String();
    if (isActive != null) body['isActive'] = isActive;
    if (campaignId != null) body['campaignId'] = campaignId;
    if (referralCode != null) body['referralCode'] = referralCode;

    final response = await _apiService.put<DeepLink>(
      '/links/$linkId',
      body: body,
      fromJson: DeepLink.fromJson,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la mise à jour du lien',
        code: 'LINK_UPDATE_FAILED',
      );
    }

    return response.data!;
  }

  Future<void> deleteLink(String linkId) async {
    if (linkId.isEmpty) {
      throw ValidationException.required('linkId');
    }

    final response = await _apiService.delete('/links/$linkId');

    if (!response.success) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la suppression du lien',
        code: 'LINK_DELETE_FAILED',
      );
    }
  }

  Future<Map<String, dynamic>> getLinkAnalytics(
    String linkId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (linkId.isEmpty) {
      throw ValidationException.required('linkId');
    }

    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await _apiService.get<Map<String, dynamic>>(
      '/links/$linkId/analytics',
      queryParams: queryParams,
    );

    if (!response.success || response.data == null) {
      throw NetworkException(
        response.message ?? 'Erreur lors de la récupération des analytics',
        code: 'ANALYTICS_FETCH_FAILED',
      );
    }

    return response.data!;
  }

  Future<String> shortenUrl(String originalUrl) async {
    _validator.validateUrl(originalUrl, 'originalUrl');

    final link = await createLink(originalUrl: originalUrl);
    return link.shortUrl;
  }

  @visibleForTesting
  LinkValidator get validator => _validator;
}
