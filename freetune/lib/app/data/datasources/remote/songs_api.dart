import 'package:dio/dio.dart';
import '../../models/song/song_model.dart';
import '../../models/song/stream_url_response.dart';
import '../../models/common/paginated_response.dart';
import '../../../core/constants/api_endpoints.dart';

class SongsApi {
  final Dio _dio;

  SongsApi(this._dio);

  // GET /api/v1/songs
  Future<PaginatedResponse<SongModel>> getSongs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiEndpoints.songs, queryParameters: {
      'page': page,
      'limit': limit,
    });
    return PaginatedResponse.fromJson(
      response.data,
      (json) => SongModel.fromJson(json),
    );
  }

  // GET /api/v1/songs/search
  Future<PaginatedResponse<SongModel>> searchSongs({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiEndpoints.searchSongs, queryParameters: {
      'q': query,
      'page': page,
      'limit': limit,
    });
    return PaginatedResponse.fromJson(
      response.data,
      (json) => SongModel.fromJson(json),
    );
  }

  // GET /api/v1/songs/popular
  Future<List<SongModel>> getPopularSongs({int limit = 20}) async {
    final response =
        await _dio.get(ApiEndpoints.popularSongs, queryParameters: {
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // GET /api/v1/songs/recently-played
  Future<List<SongModel>> getRecentlyPlayed({int limit = 20}) async {
    final response =
        await _dio.get(ApiEndpoints.recentlyPlayed, queryParameters: {
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // GET /api/v1/songs/favorites
  Future<List<SongModel>> getFavorites({int limit = 20}) async {
    final response = await _dio.get(ApiEndpoints.favorites, queryParameters: {
      'limit': limit,
    });
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // GET /api/v1/songs/:id
  Future<SongModel> getSongById(String id) async {
    final response = await _dio.get(ApiEndpoints.songById(id));
    return SongModel.fromJson(response.data['data']);
  }

  // GET /api/v1/songs/:id/stream-url
  Future<StreamUrlResponse> getStreamUrl({
    required String songId,
    String quality = 'high', // high, medium, low
  }) async {
    final response = await _dio.get(
      ApiEndpoints.streamUrl(songId),
      queryParameters: {'quality': quality},
    );
    return StreamUrlResponse.fromJson(response.data['data']);
  }

  // POST /api/v1/songs/:id/favorite
  Future<bool> toggleFavorite(String songId) async {
    final response = await _dio.post(ApiEndpoints.toggleFavorite(songId));
    return response.data['data']['is_favorite'] as bool;
  }

  // POST /api/v1/songs/:id/play
  Future<void> trackPlay({
    required String songId,
    String? sessionId,
  }) async {
    await _dio.post(ApiEndpoints.trackPlay(songId), data: {
      'session_id': sessionId,
    });
  }

  // POST /api/v1/songs/:id/playback
  Future<void> trackPlayback({
    required String songId,
    required int positionMs,
    required int durationMs,
    double? progress, // 0.0 to 1.0
  }) async {
    await _dio.post(ApiEndpoints.trackPlayback(songId), data: {
      'position_ms': positionMs,
      'duration_ms': durationMs,
      'progress': progress,
    });
  }

  // POST /api/v1/songs/upload
  Future<SongModel> uploadSong({
    required String filePath,
    required String title,
    required String artist,
    String? album,
    required int durationMs,
  }) async {
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(filePath),
      'title': title,
      'artist': artist,
      'album': album,
      'duration_ms': durationMs,
    });

    final response = await _dio.post(ApiEndpoints.uploadSong, data: formData);
    return SongModel.fromJson(response.data['data']);
  }

  // PATCH /api/v1/songs/:id/metadata
  Future<SongModel> updateMetadata({
    required String songId,
    required Map<String, dynamic> metadata,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.updateSongMetadata(songId),
      data: metadata,
    );
    return SongModel.fromJson(response.data['data']);
  }

  // DELETE /api/v1/songs/:id
  Future<void> deleteSong(String songId) async {
    await _dio.delete(ApiEndpoints.deleteSong(songId));
  }
}
