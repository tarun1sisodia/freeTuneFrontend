import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/api_config.dart';
import '../../../core/constants/cache_keys.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(CacheKeys.authToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Handle token expiration or other auth errors
        if (error.response?.statusCode == 401) {
          // Potentially refresh token or redirect to login
          // For now, just clear token and redirect
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(CacheKeys.authToken);
          // Get.offAllNamed(Routes.LOGIN); // Requires GetX to be initialized
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}