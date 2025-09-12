import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../models/synctra_config.dart';
import '../exceptions/exceptions.dart';

@immutable
class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  const ApiResponse({
    this.data,
    required this.success,
    this.message,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.success(T data, {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse(
      data: data,
      success: true,
      statusCode: statusCode,
      metadata: metadata,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, Map<String, dynamic>? metadata}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      metadata: metadata,
    );
  }
}

class ApiService {
  final SynctraConfig _config;
  final http.Client _client;

  ApiService(this._config) : _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_config.apiKey}',
    'X-Project-ID': _config.projectId,
    'User-Agent': 'SynctraSDK/1.0.0',
  };

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_config.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_config.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_config.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(_config.timeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final baseUri = Uri.parse(_config.baseUrl);
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    
    return baseUri.replace(
      path: '${baseUri.path}$path',
      queryParameters: queryParams,
    );
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    
    if (statusCode >= 200 && statusCode < 300) {
      try {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (fromJson != null && jsonData['data'] != null) {
          final data = fromJson(jsonData['data'] as Map<String, dynamic>);
          return ApiResponse.success(data, statusCode: statusCode, metadata: jsonData);
        }
        
        return ApiResponse.success(
          jsonData as T,
          statusCode: statusCode,
        );
      } catch (e) {
        throw NetworkException(
          'Erreur lors du décodage de la réponse JSON',
          code: 'JSON_DECODE_ERROR',
          originalError: e,
        );
      }
    } else {
      _throwNetworkException(statusCode, response.body);
    }
    
    throw NetworkException(
      'Réponse inattendue du serveur',
      code: 'UNEXPECTED_RESPONSE',
    );
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is NetworkException) {
      return ApiResponse.error(error.message, statusCode: error.statusCode);
    }
    
    if (error is SocketException) {
      throw NetworkException.noConnection();
    }
    
    if (error is HttpException) {
      throw NetworkException.serverError(500, error.message);
    }
    
    throw NetworkException(
      'Erreur réseau inattendue: ${error.toString()}',
      code: 'UNKNOWN_ERROR',
      originalError: error,
    );
  }

  void _throwNetworkException(int statusCode, String responseBody) {
    String? message;
    
    try {
      final jsonData = jsonDecode(responseBody) as Map<String, dynamic>;
      message = jsonData['message'] as String?;
    } catch (_) {
      // Ignore JSON decode errors for error responses
    }

    switch (statusCode) {
      case 401:
        throw NetworkException.unauthorized();
      case 403:
        throw NetworkException.forbidden();
      case 404:
        throw NetworkException.notFound();
      case 429:
        throw NetworkException.rateLimited();
      default:
        throw NetworkException.serverError(statusCode, message);
    }
  }

  void dispose() {
    _client.close();
  }
}
