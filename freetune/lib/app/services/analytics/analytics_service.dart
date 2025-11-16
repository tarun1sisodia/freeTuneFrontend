import 'package:get/get.dart';

import '../../data/repositories/analytics_repository.dart';

class AnalyticsService extends GetxService {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsService(this._analyticsRepository);

  Future<void> trackListening({
    required String songId,
    required String action,
    int? positionMs,
    int? durationMs,
  }) async {
    try {
      await _analyticsRepository.trackListening(
        songId: songId,
        action: action,
        positionMs: positionMs,
        durationMs: durationMs,
      );
    } catch (e) {
      // Log error, but don't block the app
      print('Analytics tracking failed: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      return await _analyticsRepository.getUserStats();
    } catch (e) {
      print('Failed to get user stats: $e');
      return {};
    }
  }
}
