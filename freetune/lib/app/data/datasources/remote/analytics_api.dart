import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';

class AnalyticsApi {
  final Dio _dio;

  AnalyticsApi(this._dio);

  // POST /api/v1/analytics/track
  Future<void> trackListening({
    required String songId,
    required String action, // e.g., 'play', 'pause', 'complete', 'progress'
    int? positionMs,
    int? durationMs,
  }) async {
    await _dio.post(ApiEndpoints.trackListening, data: {
      'song_id': songId,
      'action': action,
      if (positionMs != null) 'position_ms': positionMs,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  // GET /api/v1/analytics/stats
  Future<Map<String, dynamic>> getUserStats() async {
    final response = await _dio.get(ApiEndpoints.analyticsStats);
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /api/v1/analytics/top-songs
  Future<Map<String, dynamic>> getTopSongsAnalytics({int limit = 10}) async {
    final response = await _dio.get(ApiEndpoints.topSongsAnalytics, queryParameters: {
      'limit': limit,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /api/v1/analytics/time-patterns
  Future<Map<String, dynamic>> getTimePatterns() async {
    final response = await _dio.get(ApiEndpoints.timePatterns);
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /api/v1/analytics/genre-preferences
  Future<Map<String, dynamic>> getGenrePreferences() async {
    final response = await _dio.get(ApiEndpoints.genrePreferences);
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /api/v1/analytics/mood-preferences
  Future<Map<String, dynamic>> getMoodPreferences() async {
    final response = await _dio.get(ApiEndpoints.moodPreferences);
    return response.data['data'] as Map<String, dynamic>;
  }

  // GET /api/v1/analytics/trending
  Future<Map<String, dynamic>> getTrendingAnalytics({int limit = 10}) async {
    final response = await _dio.get(ApiEndpoints.trendingAnalytics, queryParameters: {
      'limit': limit,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}