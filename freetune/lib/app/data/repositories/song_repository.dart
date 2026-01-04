import 'package:dio/dio.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/exceptions/cache_exception.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/song_entity.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/songs_api.dart';
import '../mappers/song_mapper.dart';
import '../models/song/song_model.dart';
import '../models/song/stream_url_response.dart';

/// Repository interface for Song operations
abstract class SongRepository {
  Future<List<SongEntity>> getSongs(
      {int page = 1, int limit = 20, bool forceRefresh = false});
  Future<SongEntity> getSongById(String id, {bool forceRefresh = false});
  Future<List<SongEntity>> getPopularSongs(
      {int limit = 20, bool forceRefresh = false});
  Future<List<SongEntity>> getRecentlyPlayed({int limit = 20});
  Future<List<SongEntity>> getFavorites({bool forceRefresh = false});
  Future<void> toggleFavorite(String songId);
  Future<List<SongEntity>> searchSongs(String query,
      {int page = 1, int limit = 20, CancelToken? cancelToken});
  Future<List<SongEntity>> getSimilarSongs(String songId, {int limit = 10});
  Future<StreamUrlResponse> getStreamUrl(String songId,
      {String quality = 'medium'});
  Future<void> trackPlay(String songId, {int position = 0});
  Future<void> trackPlayback(String songId, int positionMs, int durationMs);
  Future<SongEntity> uploadSong(String filePath, String title, String artist,
      [String? album, String? coverPath]);
  Future<List<SongEntity>> getUploadedSongs({int page = 1, int limit = 20});
  Future<void> deleteSong(String songId);
  Future<void> requestSongImport(String query);
  Future<void> clearCache();
  Future<void> refreshCache();
}

/// Production-grade Song Repository implementation with cache-first strategy
class SongRepositoryImpl implements SongRepository {
  final SongsApi _songsApi;
  final CacheManager _cacheManager;

  // Cache TTL configuration
  static const Duration _cacheDuration = Duration(hours: 6);
  static const Duration _popularCacheDuration = Duration(hours: 1);
  static const Duration _favoritesCacheDuration = Duration(minutes: 30);

  SongRepositoryImpl(this._songsApi, this._cacheManager);

  @override
  Future<List<SongEntity>> getSongs({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first if not forcing refresh and page 1
      if (!forceRefresh && page == 1) {
        final cachedSongs = await _getCachedSongs();
        if (cachedSongs.isNotEmpty) {
          logger.i('📦 Returning ${cachedSongs.length} cached songs');
          return cachedSongs
              .map((model) => SongMapper.fromModel(model))
              .toList();
        }
      }

      // Fetch from API
      logger.i('🌐 Fetching songs from API - page: $page');
      final paginatedResponse = await _songsApi.getSongs(
        page: page,
        limit: limit,
      );

      // Cache first page results
      if (page == 1 && paginatedResponse.data.isNotEmpty) {
        await _cacheSongs(paginatedResponse.data);
      }

      return paginatedResponse.data
          .map((model) => SongMapper.fromModel(model))
          .toList();
    } on ApiException {
      // If API fails, try to return cached data as fallback
      logger.w('API failed, attempting to return cached data');
      final cachedSongs = await _getCachedSongs();
      if (cachedSongs.isNotEmpty) {
        return cachedSongs.map((model) => SongMapper.fromModel(model)).toList();
      }
      rethrow;
    } catch (e) {
      logger.e('Error getting songs: $e');
      throw ApiException(message: 'Failed to get songs: $e');
    }
  }

  @override
  Future<SongEntity> getSongById(String id, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedSong = await _cacheManager.getSongById(id);
        if (cachedSong != null) {
          logger.i('📦 Returning cached song: ${cachedSong.title}');
          return SongMapper.fromModel(cachedSong);
        }
      }

      // Fetch from API
      logger.i('🌐 Fetching song from API: $id');
      final songModel = await _songsApi.getSongById(id);

      // Cache the result
      await _cacheManager.cacheSong(songModel);

      return SongMapper.fromModel(songModel);
    } on ApiException {
      // Try cache as fallback
      final cachedSong = await _cacheManager.getSongById(id);
      if (cachedSong != null) {
        logger.w('API failed, returning cached song');
        return SongMapper.fromModel(cachedSong);
      }
      rethrow;
    } catch (e) {
      logger.e('Error getting song by ID: $e');
      throw ApiException(message: 'Failed to get song: $e');
    }
  }

  @override
  Future<List<SongEntity>> getPopularSongs({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedPopular = await _getCachedPopularSongs();
        if (cachedPopular.isNotEmpty) {
          logger.i('📦 Returning ${cachedPopular.length} cached popular songs');
          return cachedPopular
              .map((model) => SongMapper.fromModel(model))
              .toList();
        }
      }

      // Fetch from API
      logger.i('🌐 Fetching popular songs from API');
      final songs = await _songsApi.getPopularSongs(limit: limit);

      // Cache the results
      if (songs.isNotEmpty) {
        await _cachePopularSongs(songs);
      }

      return songs.map((model) => SongMapper.fromModel(model)).toList();
    } on ApiException {
      // Try cache as fallback
      final cachedPopular = await _getCachedPopularSongs();
      if (cachedPopular.isNotEmpty) {
        logger.w('API failed, returning cached popular songs');
        return cachedPopular
            .map((model) => SongMapper.fromModel(model))
            .toList();
      }
      rethrow;
    } catch (e) {
      logger.e('Error getting popular songs: $e');
      throw ApiException(message: 'Failed to get popular songs: $e');
    }
  }

  @override
  Future<List<SongEntity>> getRecentlyPlayed({int limit = 20}) async {
    try {
      logger.i('🌐 Fetching recently played songs');
      final songs = await _songsApi.getRecentlyPlayed(limit: limit);

      // Optionally cache recent songs
      // Not caching here as this is user-specific and changes frequently

      return songs.map((model) => SongMapper.fromModel(model)).toList();
    } catch (e) {
      logger.e('Error getting recently played: $e');
      throw ApiException(message: 'Failed to get recently played songs: $e');
    }
  }

  @override
  Future<List<SongEntity>> getFavorites({bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedFavorites = await _getCachedFavorites();
        if (cachedFavorites.isNotEmpty) {
          logger.i('📦 Returning ${cachedFavorites.length} cached favorites');
          return cachedFavorites
              .map((model) => SongMapper.fromModel(model))
              .toList();
        }
      }

      // Fetch from API
      logger.i('🌐 Fetching favorites from API');
      final songs = await _songsApi.getFavorites();

      // Cache the results
      if (songs.isNotEmpty) {
        await _cacheFavorites(songs);
      }

      return songs.map((model) => SongMapper.fromModel(model)).toList();
    } on ApiException {
      // Try cache as fallback
      final cachedFavorites = await _getCachedFavorites();
      if (cachedFavorites.isNotEmpty) {
        logger.w('API failed, returning cached favorites');
        return cachedFavorites
            .map((model) => SongMapper.fromModel(model))
            .toList();
      }
      rethrow;
    } catch (e) {
      logger.e('Error getting favorites: $e');
      throw ApiException(message: 'Failed to get favorites: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String songId) async {
    try {
      logger.i('Toggling favorite for song: $songId');
      await _songsApi.toggleFavorite(songId);

      // Update cache
      await _updateFavoriteInCache(songId);

      // Clear favorites cache to force refresh on next fetch
      await _cacheManager.clearFavoritesCache();

      logger.d('Favorite toggled successfully');
    } catch (e) {
      logger.e('Error toggling favorite: $e');
      throw ApiException(message: 'Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<SongEntity>> searchSongs(
    String query, {
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      logger.i('🔍 Searching songs: "$query"');
      final paginatedResponse = await _songsApi.searchSongs(
        query,
        page: page,
        limit: limit,
        cancelToken: cancelToken,
      );

      return paginatedResponse.data
          .map((model) => SongMapper.fromModel(model))
          .toList();
    } catch (e) {
      logger.e('Error searching songs: $e');
      throw ApiException(message: 'Failed to search songs: $e');
    }
  }

  @override
  Future<List<SongEntity>> getSimilarSongs(String songId,
      {int limit = 10}) async {
    try {
      logger.i('Fetching similar songs for: $songId');
      final songs = await _songsApi.getSimilarSongs(songId, limit: limit);

      return songs.map((model) => SongMapper.fromModel(model)).toList();
    } catch (e) {
      logger.e('Error getting similar songs: $e');
      throw ApiException(message: 'Failed to get similar songs: $e');
    }
  }

  @override
  Future<StreamUrlResponse> getStreamUrl(
    String songId, {
    String quality = 'medium',
  }) async {
    try {
      logger.i('Getting stream URL for song: $songId');
      return await _songsApi.getStreamUrl(songId, quality: quality);
    } catch (e) {
      logger.e('Error getting stream URL: $e');
      throw ApiException(message: 'Failed to get stream URL: $e');
    }
  }

  @override
  Future<void> trackPlay(String songId, {int position = 0}) async {
    try {
      await _songsApi.trackPlay(songId, position: position);
    } catch (e) {
      // Don't throw error for analytics - just log it
      logger.w('Failed to track play: $e');
    }
  }

  @override
  Future<void> trackPlayback(
      String songId, int positionMs, int durationMs) async {
    try {
      await _songsApi.trackPlayback(songId, positionMs, durationMs);
    } catch (e) {
      // Don't throw error for analytics - just log it
      logger.w('Failed to track playback: $e');
    }
  }

  @override
  Future<SongEntity> uploadSong(String filePath, String title, String artist,
      [String? album, String? coverPath]) async {
    try {
      logger.i('📤 Uploading song: $title by $artist');

      // Send placeholder duration - backend will extract actual duration
      const int placeholderDuration = 0; // Backend extracts real duration

      final map = {
        'audio': await MultipartFile.fromFile(filePath),
        'title': title,
        'artist': artist,
        'duration_ms': placeholderDuration.toString(),
      };

      if (album != null && album.isNotEmpty) {
        map['album'] = album;
      }

      if (coverPath != null && coverPath.isNotEmpty) {
        map['image'] = await MultipartFile.fromFile(coverPath);
      }

      final formData = FormData.fromMap(map);

      logger.d('Sending upload request - backend will extract duration');
      final songModel = await _songsApi.uploadSong(formData);
      logger.i('✅ Song uploaded successfully: ${songModel.title}');

      // Invalidate cache to ensure new song appears in lists
      await clearCache();

      return SongMapper.fromModel(songModel);
    } catch (e) {
      logger.e('Error uploading song: $e');
      throw ApiException(message: 'Failed to upload song: $e');
    }
  }

  @override
  Future<List<SongEntity>> getUploadedSongs(
      {int page = 1, int limit = 20}) async {
    try {
      logger.i('🌐 Fetching uploaded songs');
      final paginatedResponse =
          await _songsApi.getUploadedSongs(page: page, limit: limit);

      return paginatedResponse.data
          .map((model) => SongMapper.fromModel(model))
          .toList();
    } catch (e) {
      logger.e('Error getting uploaded songs: $e');
      throw ApiException(message: 'Failed to get uploaded songs: $e');
    }
  }

  @override
  Future<void> deleteSong(String songId) async {
    try {
      logger.i('Deleting song: $songId');
      await _songsApi.deleteSong(songId);

      // Invalidate relevant caches
      await _cacheManager.clearSongsCache();

      logger.d('Song deleted successfully from repository');
    } catch (e) {
      logger.e('Error deleting song: $e');
      throw ApiException(message: 'Failed to delete song: $e');
    }
  }

  @override
  Future<void> requestSongImport(String query) async {
    try {
      logger.i('Requesting song import for: "$query"');
      await _songsApi.importSong(query: query);
      logger.d('Song import requested successfully via repository');
    } catch (e) {
      logger.e('Error requesting song import: $e');
      throw ApiException(message: 'Failed to request song import: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      logger.i('🗑️ Clearing song cache');
      await _cacheManager.clearSongsCache();
      logger.d('Song cache cleared successfully');
    } catch (e) {
      logger.e('Error clearing cache: $e');
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> refreshCache() async {
    try {
      logger.i('🔄 Refreshing song cache');

      // Refresh all songs
      final songs = await getSongs(forceRefresh: true);
      logger.d('Refreshed ${songs.length} songs');

      // Refresh popular songs
      final popular = await getPopularSongs(forceRefresh: true);
      logger.d('Refreshed ${popular.length} popular songs');

      // Refresh favorites
      final favorites = await getFavorites(forceRefresh: true);
      logger.d('Refreshed ${favorites.length} favorites');

      logger.i('✅ Cache refresh complete');
    } catch (e) {
      logger.w('Failed to refresh cache: $e');
      // Don't throw error - cache refresh is best effort
    }
  }

  // Private helper methods

  Future<List<SongModel>> _getCachedSongs() async {
    try {
      return await _cacheManager.getCachedSongs();
    } catch (e) {
      logger.w('Failed to get cached songs: $e');
      return [];
    }
  }

  Future<void> _cacheSongs(List<SongModel> songs) async {
    try {
      await _cacheManager.cacheSongs(songs);
      logger.d('💾 Cached ${songs.length} songs');
    } catch (e) {
      logger.w('Failed to cache songs: $e');
    }
  }

  Future<List<SongModel>> _getCachedPopularSongs() async {
    try {
      return await _cacheManager.getCachedPopularSongs();
    } catch (e) {
      logger.w('Failed to get cached popular songs: $e');
      return [];
    }
  }

  Future<void> _cachePopularSongs(List<SongModel> songs) async {
    try {
      await _cacheManager.cachePopularSongs(songs);
      logger.d('💾 Cached ${songs.length} popular songs');
    } catch (e) {
      logger.w('Failed to cache popular songs: $e');
    }
  }

  Future<List<SongModel>> _getCachedFavorites() async {
    try {
      return await _cacheManager.getCachedFavorites();
    } catch (e) {
      logger.w('Failed to get cached favorites: $e');
      return [];
    }
  }

  Future<void> _cacheFavorites(List<SongModel> songs) async {
    try {
      await _cacheManager.cacheFavorites(songs);
      logger.d('💾 Cached ${songs.length} favorites');
    } catch (e) {
      logger.w('Failed to cache favorites: $e');
    }
  }

  Future<void> _updateFavoriteInCache(String songId) async {
    try {
      final song = await _cacheManager.getSongById(songId);
      if (song != null) {
        // Toggle the favorite status in cache
        song.isFavorite = !(song.isFavorite ?? false);
        await _cacheManager.cacheSong(song);
        logger.d('Updated favorite status in cache');
      }
    } catch (e) {
      logger.w('Failed to update favorite in cache: $e');
    }
  }
}
