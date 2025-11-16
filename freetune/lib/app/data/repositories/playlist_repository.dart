import '../../domain/entities/playlist_entity.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/playlists_api.dart';
import '../mappers/playlist_mapper.dart';

abstract class PlaylistRepository {
  Future<List<PlaylistEntity>> getPlaylists();
  Future<PlaylistEntity> createPlaylist(String name, List<String> songIds);
  // Add other playlist related methods
}

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistsApi _playlistsApi;
  final CacheManager _cacheManager;

  PlaylistRepositoryImpl(this._playlistsApi, this._cacheManager);

  @override
  Future<List<PlaylistEntity>> getPlaylists() async {
    // Try to get from cache first
    final cachedPlaylists = await _cacheManager.getPlaylists();
    if (cachedPlaylists.isNotEmpty) {
      return cachedPlaylists
          .map((model) => PlaylistMapper.fromModel(model))
          .toList();
    }

    // If not in cache, fetch from API
    final apiPlaylists = await _playlistsApi.getPlaylists();
    await _cacheManager.savePlaylists(apiPlaylists); // Save to cache
    return apiPlaylists
        .map((model) => PlaylistMapper.fromModel(model))
        .toList();
  }

  @override
  Future<PlaylistEntity> createPlaylist(
      String name, List<String> songIds) async {
    final newPlaylistModel = await _playlistsApi.createPlaylist(name, songIds);
    // Optionally update cache after creation
    return PlaylistMapper.fromModel(newPlaylistModel);
  }
}
