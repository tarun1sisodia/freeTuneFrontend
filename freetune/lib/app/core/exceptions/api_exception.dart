import 'package:dio/dio.dart';

/// Production-grade API Exception with comprehensive error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.data,
  });

  /// Create ApiException from DioException with detailed error messages
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          errorCode: 'CONNECTION_TIMEOUT',
        );
      
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request timeout. Please try again.',
          statusCode: 408,
          errorCode: 'SEND_TIMEOUT',
        );
      
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Server response timeout. Please try again.',
          statusCode: 408,
          errorCode: 'RECEIVE_TIMEOUT',
        );
      
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled',
          errorCode: 'REQUEST_CANCELLED',
        );
      
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          statusCode: 503,
          errorCode: 'NO_CONNECTION',
        );
      
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Security certificate error. Cannot connect to server.',
          statusCode: 495,
          errorCode: 'BAD_CERTIFICATE',
        );
      
      case DioExceptionType.unknown:
      return ApiException(
          message: error.message ?? 'An unexpected error occurred',
          errorCode: 'UNKNOWN_ERROR',
          data: error.error,
        );
    }
  }

  /// Handle bad response errors with detailed status code mapping
  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    // Try to extract error message from response
    String message = 'Request failed';
    String? errorCode;
    
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? 
                responseData['error'] ?? 
                message;
      errorCode = responseData['code']?.toString();
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message.isNotEmpty ? message : 'Invalid request',
          statusCode: statusCode,
          errorCode: errorCode ?? 'BAD_REQUEST',
          data: responseData,
        );
      
      case 401:
        return ApiException(
          message: 'Unauthorized. Please login again.',
          statusCode: statusCode,
          errorCode: errorCode ?? 'UNAUTHORIZED',
          data: responseData,
        );
      
      case 403:
        return ApiException(
          message: 'Access denied. You don\'t have permission.',
          statusCode: statusCode,
          errorCode: errorCode ?? 'FORBIDDEN',
          data: responseData,
        );
      
      case 404:
        return ApiException(
          message: 'Resource not found',
          statusCode: statusCode,
          errorCode: errorCode ?? 'NOT_FOUND',
          data: responseData,
        );
      
      case 409:
        return ApiException(
          message: message.isNotEmpty ? message : 'Conflict occurred',
          statusCode: statusCode,
          errorCode: errorCode ?? 'CONFLICT',
          data: responseData,
        );
      
      case 422:
        return ApiException(
          message: message.isNotEmpty ? message : 'Validation failed',
          statusCode: statusCode,
          errorCode: errorCode ?? 'VALIDATION_ERROR',
          data: responseData,
        );
      
      case 429:
        return ApiException(
          message: 'Too many requests. Please try again later.',
          statusCode: statusCode,
          errorCode: errorCode ?? 'RATE_LIMIT',
          data: responseData,
        );
      
      case 500:
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
          errorCode: errorCode ?? 'SERVER_ERROR',
          data: responseData,
        );
      
      case 502:
        return ApiException(
          message: 'Bad gateway. Server temporarily unavailable.',
          statusCode: statusCode,
          errorCode: errorCode ?? 'BAD_GATEWAY',
          data: responseData,
        );
      
      case 503:
        return ApiException(
          message: 'Service unavailable. Please try again later.',
          statusCode: statusCode,
          errorCode: errorCode ?? 'SERVICE_UNAVAILABLE',
          data: responseData,
        );
      
      default:
        return ApiException(
          message: message.isNotEmpty ? message : 'Request failed with status $statusCode',
          statusCode: statusCode,
          errorCode: errorCode ?? 'HTTP_ERROR',
          data: responseData,
        );
    }
  }

  /// Check if error is due to network issues
  bool get isNetworkError =>
      errorCode == 'NO_CONNECTION' ||
      errorCode == 'CONNECTION_TIMEOUT' ||
      errorCode == 'SEND_TIMEOUT' ||
      errorCode == 'RECEIVE_TIMEOUT';

  /// Check if error is due to authentication issues
  bool get isAuthError =>
      statusCode == 401 || errorCode == 'UNAUTHORIZED';

  /// Check if error is retryable
  bool get isRetryable =>
      isNetworkError ||
      statusCode == 408 ||
      statusCode == 429 ||
      statusCode == 500 ||
      statusCode == 502 ||
      statusCode == 503;

  @override
  String toString() {
    final parts = ['ApiException: $message'];
    if (statusCode != null) parts.add('Status: $statusCode');
    if (errorCode != null) parts.add('Code: $errorCode');
    return parts.join(' | ');
  }

  /// Get user-friendly error message
  String get userMessage {
    if (isNetworkError) {
      return 'No internet connection. Please check your network and try again.';
    }
    
    if (isAuthError) {
      return 'Session expired. Please login again.';
    }
    
    return message;
  }
}