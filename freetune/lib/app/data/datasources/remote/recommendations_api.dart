import 'package:dio/dio.dart';
import '../../models/song/song_model.dart';
import '../../../core/constants/api_endpoints.dart';

class RecommendationsApi {
  final Dio _dio;

  RecommendationsApi(this._dio);

  // GET /api/v1/recommendations
  Future<List<SongModel>> getRecommendations({
    String? genre,
    String? mood,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiEndpoints.recommendations, queryParameters: {
      if (genre != null) 'genre': genre,
      if (mood != null) 'mood': mood,
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // GET /api/v1/recommendations/similar/:songId
  Future<List<SongModel>> getSimilarSongs({
    required String songId,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiEndpoints.similarSongs(songId), queryParameters: {
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // GET /api/v1/recommendations/trending
  Future<List<SongModel>> getTrendingRecommendations({int limit = 20}) async {
    final response = await _dio.get(ApiEndpoints.trendingRecommendations, queryParameters: {
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // GET /api/v1/recommendations/stats
  Future<List<SongModel>> getUserTopSongsRecommendations({int limit = 20}) async {
    final response = await _dio.get(ApiEndpoints.userTopSongsRecommendations, queryParameters: {
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }
}