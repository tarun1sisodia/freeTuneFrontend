import '../datasources/remote/analytics_api.dart';
import '../../core/exceptions/api_exception.dart';

class AnalyticsRepository {
  final AnalyticsApi _analyticsApi;

  AnalyticsRepository(this._analyticsApi);

  Future<void> trackListening({
    required String songId,
    required String action, // e.g., 'play', 'pause', 'complete', 'progress'
    int? positionMs,
    int? durationMs,
  }) async {
    try {
      await _analyticsApi.trackListening(
        songId: songId,
        action: action,
        positionMs: positionMs,
        durationMs: durationMs,
      );
    } catch (e) {
      // Log the error but don't rethrow, analytics should not block user experience
      print('Analytics tracking failed: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      return await _analyticsApi.getUserStats();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getTopSongsAnalytics({int limit = 10}) async {
    try {
      return await _analyticsApi.getTopSongsAnalytics(limit: limit);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getTimePatterns() async {
    try {
      return await _analyticsApi.getTimePatterns();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getGenrePreferences() async {
    try {
      return await _analyticsApi.getGenrePreferences();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMoodPreferences() async {
    try {
      return await _analyticsApi.getMoodPreferences();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getTrendingAnalytics({int limit = 10}) async {
    try {
      return await _analyticsApi.getTrendingAnalytics(limit: limit);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
