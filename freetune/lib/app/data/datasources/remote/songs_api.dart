import 'package:dio/dio.dart';
import 'package:freetune/app/core/utils/logger.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../models/common/paginated_response.dart';
import '../../models/song/song_model.dart';
import '../../models/song/stream_url_response.dart';

/// Production-grade Songs API client with comprehensive error handling
class SongsApi {
  final Dio _dio;

  SongsApi(this._dio);

  /// Get paginated list of songs
  Future<PaginatedResponse<SongModel>> getSongs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      logger.i('Fetching songs - page: $page, limit: $limit');
      final response = await _dio.get(
        ApiEndpoints.songs,
        queryParameters: {'page': page, 'limit': limit},
      );

      logger.d(
          'Songs fetched successfully: ${response.data['pagination']['total']} total');
      return PaginatedResponse.fromJson(response.data, SongModel.fromJson);
    } on DioException catch (e) {
      logger.e('Failed to get songs: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting songs: $e');
      throw ApiException(message: 'Failed to get songs: $e');
    }
  }

  /// Get single song by ID
  Future<SongModel> getSongById(String id) async {
    try {
      logger.i('Fetching song by ID: $id');
      final response = await _dio.get(
        ApiEndpoints.getSong.replaceFirst('{id}', id),
      );

      logger.d('Song fetched successfully: ${response.data['data']['title']}');
      return SongModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      logger.e('Failed to get song $id: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting songs By ID: $e');
      throw ApiException(message: 'Failed to get song: $e');
    }
  }

  /// Get popular/trending songs
  Future<List<SongModel>> getPopularSongs({int limit = 20}) async {
    try {
      logger.i('Fetching popular songs - limit: $limit');
      final response = await _dio.get(
        ApiEndpoints.popularSongs,
        queryParameters: {'limit': limit},
      );

      final songs = (response.data['data'] as List)
          .map((json) => SongModel.fromJson(json))
          .toList();

      logger.d('Popular songs fetched: ${songs.length} songs');
      return songs;
    } on DioException catch (e) {
      logger.e('Failed to get popular songs: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting popular songs: $e');
      throw ApiException(message: 'Failed to get popular songs: $e');
    }
  }

  /// Get recently played songs
  Future<List<SongModel>> getRecentlyPlayed({int limit = 20}) async {
    try {
      logger.i('Fetching recently played songs - limit: $limit');
      final response = await _dio.get(
        ApiEndpoints.recentSongs,
        queryParameters: {'limit': limit},
      );

      // Backend returns data.songs array, not data array directly
      final songsData = response.data['data']['songs'] as List;
      final songs = songsData
          .map((json) => SongModel.fromJson(json as Map<String, dynamic>))
          .toList();

      logger.d('Recent songs fetched: ${songs.length} songs');
      return songs;
    } on DioException catch (e) {
      logger.e('Failed to get recent songs: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting recent songs: $e');
      throw ApiException(message: 'Failed to get recent songs: $e');
    }
  }

  /// Get user's favorite songs
  Future<List<SongModel>> getFavorites() async {
    try {
      logger.i('Fetching favorite songs');
      final response = await _dio.get(ApiEndpoints.favoriteSongs);

      final songs = (response.data['data'] as List)
          .map((json) => SongModel.fromJson(json))
          .toList();

      logger.d('Favorites fetched: ${songs.length} songs');
      return songs;
    } on DioException catch (e) {
      logger.e('Failed to get favorites: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting favorites: $e');
      throw ApiException(message: 'Failed to get favorites: $e');
    }
  }

  /// Toggle favorite status (add/remove)
  Future<void> toggleFavorite(String songId) async {
    try {
      logger.i('Toggling favorite for song: $songId');
      await _dio.post(
        ApiEndpoints.addFavorite.replaceFirst('{id}', songId),
      );
      logger.d('Favorite toggled successfully');
    } on DioException catch (e) {
      logger.e('Failed to toggle favorite: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error toggling favorite: $e');
      throw ApiException(message: 'Failed to toggle favorite: $e');
    }
  }

  /// Search songs by query
  Future<PaginatedResponse<SongModel>> searchSongs(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      logger.i('Searching songs - query: "$query", page: $page');
      final response = await _dio.get(
        ApiEndpoints.searchSongs,
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
        cancelToken: cancelToken,
      );

      logger.d('Search results: ${response.data['pagination']['total']} songs');
      return PaginatedResponse.fromJson(response.data, SongModel.fromJson);
    } on DioException catch (e) {
      logger.e('Failed to search songs: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error searching songs: $e');
      throw ApiException(message: 'Failed to search songs: $e');
    }
  }

  /// Get stream URL for a song
  Future<StreamUrlResponse> getStreamUrl(
    String songId, {
    String quality = 'medium',
  }) async {
    try {
      logger.i('Getting stream URL - songId: $songId, quality: $quality');
      final response = await _dio.get(
        ApiEndpoints.streamUrl.replaceFirst('{id}', songId),
        queryParameters: {'quality': quality},
        options: Options(
          responseType: ResponseType.json,
          followRedirects: false,
        ),
      );

      logger.d('Stream URL obtained successfully');
      logger.d('Response data type: ${response.data.runtimeType}');
      logger.d('Response data: ${response.data}');
      return StreamUrlResponse.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('Failed to get stream URL: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting stream URL: $e');
      throw ApiException(message: 'Failed to get stream URL: $e');
    }
  }

  /// Track song play (analytics)
  Future<void> trackPlay(String songId, {int position = 0}) async {
    try {
      logger.d('Tracking play for song: $songId');
      await _dio.post(
        ApiEndpoints.trackPlay.replaceFirst('{id}', songId),
        data: {'position': position},
      );
    } on DioException catch (e) {
      // Don't throw error for analytics - just log it
      logger.w('Failed to track play: ${e.message}');
    } catch (e) {
      logger.w('Unexpected error tracking play: $e');
    }
  }

  /// Track playback position (analytics)
  Future<void> trackPlayback(
    String songId,
    int positionMs,
    int durationMs,
  ) async {
    try {
      logger.d('Tracking playback - song: $songId, position: $positionMs');
      await _dio.post(
        ApiEndpoints.trackPlayback.replaceFirst('{id}', songId),
        data: {
          'positionMs': positionMs,
          'durationMs': durationMs,
        },
      );
    } on DioException catch (e) {
      // Don't throw error for analytics - just log it
      logger.w('Failed to track playback: ${e.message}');
    } catch (e) {
      logger.w('Unexpected error tracking playback: $e');
    }
  }

  /// Get similar songs (recommendations)
  Future<List<SongModel>> getSimilarSongs(String songId,
      {int limit = 10}) async {
    try {
      logger.i('Fetching similar songs for: $songId');
      final response = await _dio.get(
        ApiEndpoints.similarSongs.replaceFirst('{songId}', songId),
        queryParameters: {'limit': limit},
      );

      final songs = (response.data['data'] as List)
          .map((json) => SongModel.fromJson(json))
          .toList();

      logger.d('Similar songs fetched: ${songs.length} songs');
      return songs;
    } on DioException catch (e) {
      logger.e('Failed to get similar songs: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting similar songs: $e');
      throw ApiException(message: 'Failed to get similar songs: $e');
    }
  }

  /// Upload song (if supported by backend)
  Future<SongModel> uploadSong(FormData formData) async {
    try {
      logger.i('Uploading song');
      final response = await _dio.post(
        ApiEndpoints.uploadSong,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      logger.d('Song uploaded successfully');
      // Backend returns { data: { song: {...}, upload: {...} } }
      final responseData = response.data['data'];
      return SongModel.fromJson(responseData['song']);
    } on DioException catch (e) {
      logger.e('Failed to upload song: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error uploading song: $e');
      throw ApiException(message: 'Failed to upload song: $e');
    }
  }

  /// Request song import from YouTube
  Future<void> importSong({String? query, String? url}) async {
    try {
      logger.i('Requesting song import - query: "$query", url: "$url"');
      await _dio.post(
        ApiEndpoints.importSong,
        data: {
          if (query != null) 'query': query,
          if (url != null) 'url': url,
        },
      );
      logger.d('Song import requested successfully');
    } on DioException catch (e) {
      logger.e('Failed to request song import: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error requesting song import: $e');
      throw ApiException(message: 'Failed to request song import: $e');
    }
  }

  /// Get songs uploaded by the current user
  Future<PaginatedResponse<SongModel>> getUploadedSongs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      logger.i('Fetching uploaded songs - page: $page, limit: $limit');
      final response = await _dio.get(
        ApiEndpoints.userSongs,
        queryParameters: {'page': page, 'limit': limit},
      );

      final responseData = response.data['data'];
      logger.d(
          'Uploaded songs fetched: ${responseData['pagination']['total']} songs');

      return PaginatedResponse(
        data: List<SongModel>.from(
            (responseData['songs'] as List).map((x) => SongModel.fromJson(x))),
        total: responseData['pagination']['total'],
        page: responseData['pagination']['page'],
        limit: responseData['pagination']['limit'],
      );
    } on DioException catch (e) {
      logger.e('Failed to get uploaded songs: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting uploaded songs: $e');
      throw ApiException(message: 'Failed to get uploaded songs: $e');
    }
  }

  /// Update song metadata
  Future<SongModel> updateSong(String songId, Map<String, dynamic> data) async {
    try {
      logger.i('Updating song: $songId');
      final response = await _dio.put(
        ApiEndpoints.updateSong.replaceFirst('{id}', songId),
        data: data,
      );

      logger.d('Song updated successfully');
      return SongModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      logger.e('Failed to update song: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error updating song: $e');
      throw ApiException(message: 'Failed to update song: $e');
    }
  }

  /// Delete song
  Future<void> deleteSong(String songId) async {
    try {
      logger.i('Deleting song: $songId');
      await _dio.delete(
        ApiEndpoints.deleteSong.replaceFirst('{id}', songId),
      );
      logger.d('Song deleted successfully');
    } on DioException catch (e) {
      logger.e('Failed to delete song: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error deleting song: $e');
      throw ApiException(message: 'Failed to delete song: $e');
    }
  }
}
