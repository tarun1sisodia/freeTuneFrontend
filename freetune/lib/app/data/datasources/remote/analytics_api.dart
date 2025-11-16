import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';

class AnalyticsApi {
  final Dio _dio;

  AnalyticsApi(this._dio);

  Future<void> trackListening({
    required String songId,
    required String action,
    int? positionMs,
    int? durationMs,
  }) async {
    await _dio.post(
      ApiEndpoints.trackListening,
      data: {
        'songId': songId,
        'action': action,
        'positionMs': positionMs,
        'durationMs': durationMs,
      },
    );
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _dio.get(ApiEndpoints.userStats);
    return response.data as Map<String, dynamic>;
  }
}