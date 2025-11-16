import '../../domain/entities/song_entity.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/songs_api.dart';
import '../mappers/song_mapper.dart';
import '../models/song/stream_url_response.dart';

abstract class SongRepository {
  Future<List<SongEntity>> getSongs({int page = 1, int limit = 10});
  Future<List<SongEntity>> searchSongs(String query, {int page = 1, int limit = 10});
  Future<StreamUrlResponse> getStreamUrl(String songId, String quality);
  Future<void> trackPlay(String songId);
  Future<void> trackPlayback(String songId, int positionMs, int durationMs);
  Future<SongEntity?> getSongDetails(String songId);
}

class SongRepositoryImpl implements SongRepository {
  final SongsApi _songsApi;
  final CacheManager _cacheManager;

  SongRepositoryImpl(this._songsApi, this._cacheManager);

  @override
  Future<List<SongEntity>> getSongs({int page = 1, int limit = 10}) async {
    // For simplicity, not caching paginated lists directly here, but could be added.
    final paginatedResponse = await _songsApi.getSongs(page: page, limit: limit);
    return paginatedResponse.data.map((model) => SongMapper.fromModel(model)).toList();
  }

  @override
  Future<List<SongEntity>> searchSongs(String query, {int page = 1, int limit = 10}) async {
    final paginatedResponse = await _songsApi.searchSongs(query, page: page, limit: limit);
    return paginatedResponse.data.map((model) => SongMapper.fromModel(model)).toList();
  }

  @override
  Future<StreamUrlResponse> getStreamUrl(String songId, String quality) async {
    return await _songsApi.getStreamUrl(songId, quality);
  }

  @override
  Future<void> trackPlay(String songId) async {
    await _songsApi.trackPlay(songId);
  }

  @override
  Future<void> trackPlayback(String songId, int positionMs, int durationMs) async {
    await _songsApi.trackPlayback(songId, positionMs, durationMs);
  }

  @override
  Future<SongEntity?> getSongDetails(String songId) async {
    // Try to get from cache first
    final cachedSong = await _cacheManager.getSongById(songId);
    if (cachedSong != null) {
      return SongMapper.fromModel(cachedSong);
    }
    // If not in cache, fetch from API (assuming there's a get song by ID endpoint)
    // For now, we'll just return null if not in cache, or fetch from a list if available
    // A dedicated API endpoint for single song details would be ideal.
    return null; // Placeholder
  }
}