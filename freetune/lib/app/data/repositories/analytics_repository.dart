import '../datasources/remote/analytics_api.dart';

abstract class AnalyticsRepository {
  Future<void> trackListening({
    required String songId,
    required String action,
    int? positionMs,
    int? durationMs,
  });
  Future<Map<String, dynamic>> getUserStats();
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsApi _analyticsApi;

  AnalyticsRepositoryImpl(this._analyticsApi);

  @override
  Future<void> trackListening({
    required String songId,
    required String action,
    int? positionMs,
    int? durationMs,
  }) async {
    await _analyticsApi.trackListening(
      songId: songId,
      action: action,
      positionMs: positionMs,
      durationMs: durationMs,
    );
  }

  @override
  Future<Map<String, dynamic>> getUserStats() async {
    return await _analyticsApi.getUserStats();
  }
}