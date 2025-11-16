import '../datasources/remote/songs_api.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/local/isar_database.dart';
import '../models/song/song_model.dart';
import '../models/song/stream_url_response.dart';
import '../models/common/paginated_response.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/network_utils.dart';
import '../../domain/entities/song_entity.dart';
import '../mappers/song_mapper.dart';

class SongRepository {
  final SongsApi _songsApi;
  final CacheManager _cacheManager;

  SongRepository(this._songsApi, this._cacheManager);

  Future<PaginatedResponse<SongEntity>> getSongs({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final isConnected = await NetworkUtils.isConnected();

      if (!isConnected) {
        // Return cached songs if offline
        final isar = await IsarDatabase.getInstance();
        final cachedModels = await isar.songModels.where().findAll();
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;
        final paginatedSongs = cachedModels.length > startIndex
            ? cachedModels.sublist(
                startIndex,
                endIndex > cachedModels.length ? cachedModels.length : endIndex,
              )
            : <SongModel>[];

        return PaginatedResponse<SongEntity>(
          data: paginatedSongs.map((e) => SongMapper.fromModel(e)).toList(),
          page: page,
          limit: limit,
          total: cachedModels.length,
          hasMore: endIndex < cachedModels.length,
        );
      }

      final response = await _songsApi.getSongs(page: page, limit: limit);

      // Cache songs
      if (response.data.isNotEmpty) {
        await _cacheManager.autoCacheTopSongs(response.data);
      }

      return PaginatedResponse<SongEntity>(
        data: response.data.map((e) => SongMapper.fromModel(e)).toList(),
        page: response.page,
        limit: response.limit,
        total: response.total,
        hasMore: response.hasMore,
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PaginatedResponse<SongEntity>> searchSongs({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _songsApi.searchSongs(
          query: query, page: page, limit: limit);
      return PaginatedResponse<SongEntity>(
        data: response.data.map((e) => SongMapper.fromModel(e)).toList(),
        page: response.page,
        limit: response.limit,
        total: response.total,
        hasMore: response.hasMore,
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SongEntity>> getPopularSongs({int limit = 20}) async {
    try {
      final songs = await _songsApi.getPopularSongs(limit: limit);
      await _cacheManager.autoCacheTopSongs(songs);
      return songs.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SongEntity>> getRecentlyPlayed({int limit = 20}) async {
    try {
      final songs = await _songsApi.getRecentlyPlayed(limit: limit);
      return songs.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SongEntity>> getFavorites({int limit = 20}) async {
    try {
      final songs = await _songsApi.getFavorites(limit: limit);
      return songs.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<SongEntity> getSongById(String id) async {
    try {
      // Check cache first
      final cached = await _cacheManager.getCachedSong(id);
      if (cached != null) {
        return SongMapper.fromModel(cached);
      }

      final songModel = await _songsApi.getSongById(id);
      await _cacheManager.cacheSong(songModel);
      return SongMapper.fromModel(songModel);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<StreamUrlResponse> getStreamUrl({
    required String songId,
    String quality = 'high',
  }) async {
    try {
      return await _songsApi.getStreamUrl(songId: songId, quality: quality);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<bool> toggleFavorite(String songId) async {
    try {
      return await _songsApi.toggleFavorite(songId);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> trackPlay({required String songId, String? sessionId}) async {
    try {
      await _songsApi.trackPlay(songId: songId, sessionId: sessionId);
    } catch (e) {
      // Don't throw, just log
    }
  }

  Future<void> trackPlayback({
    required String songId,
    required int positionMs,
    required int durationMs,
    double? progress,
  }) async {
    try {
      await _songsApi.trackPlayback(
        songId: songId,
        positionMs: positionMs,
        durationMs: durationMs,
        progress: progress,
      );
    } catch (e) {
      // Don't throw, just log
    }
  }
}
