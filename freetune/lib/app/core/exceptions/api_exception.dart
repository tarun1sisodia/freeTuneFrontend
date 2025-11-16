import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
              'Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] as String? ??
              error.response?.statusMessage ??
              'An error occurred';
          return ApiException(message, statusCode: statusCode);
        case DioExceptionType.cancel:
          return ApiException('Request was cancelled');
        case DioExceptionType.unknown:
        default:
          return ApiException('Network error. Please check your connection.');
      }
    }
    return ApiException(error.toString());
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: [Status Code: $statusCode] $message';
    }
    return 'ApiException: $message';
  }
}
