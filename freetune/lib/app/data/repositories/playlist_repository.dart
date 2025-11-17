import '../../core/exceptions/api_exception.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/playlist_entity.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/playlists_api.dart';
import '../mappers/playlist_mapper.dart';
import '../models/playlist/playlist_model.dart';

/// Repository interface for Playlist operations
abstract class PlaylistRepository {
  Future<List<PlaylistEntity>> getPlaylists({bool forceRefresh = false});
  Future<PlaylistEntity> getPlaylistById(String id, {bool forceRefresh = false});
  Future<PlaylistEntity> createPlaylist(String name, List<String> songIds);
  Future<PlaylistEntity> updatePlaylist(String id, {String? name, List<String>? songIds});
  Future<void> deletePlaylist(String id);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
  Future<void> savePlaylist(PlaylistEntity playlist);
  Future<void> clearCache();
}

/// Production-grade Playlist Repository implementation
class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistsApi _playlistsApi;
  final CacheManager _cacheManager;

  PlaylistRepositoryImpl(this._playlistsApi, this._cacheManager);

  @override
  Future<List<PlaylistEntity>> getPlaylists({bool forceRefresh = false}) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedPlaylists = await _getCachedPlaylists();
        if (cachedPlaylists.isNotEmpty) {
          logger.i('📦 Returning ${cachedPlaylists.length} cached playlists');
          return cachedPlaylists
              .map((model) => PlaylistMapper.fromModel(model))
              .toList();
        }
      }

      // Fetch from API
      logger.i('🌐 Fetching playlists from API');
      final apiPlaylists = await _playlistsApi.getPlaylists();
      
      // Cache the results
      if (apiPlaylists.isNotEmpty) {
        await _cachePlaylists(apiPlaylists);
      }
      
      return apiPlaylists
          .map((model) => PlaylistMapper.fromModel(model))
          .toList();
    } on ApiException {
      // Try cache as fallback
      logger.w('API failed, attempting to return cached playlists');
      final cachedPlaylists = await _getCachedPlaylists();
      if (cachedPlaylists.isNotEmpty) {
        return cachedPlaylists
            .map((model) => PlaylistMapper.fromModel(model))
            .toList();
      }
      rethrow;
    } catch (e) {
      logger.e('Error getting playlists: $e');
      throw ApiException(message: 'Failed to get playlists: $e');
    }
  }

  @override
  Future<PlaylistEntity> getPlaylistById(String id, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cachedPlaylist = await _cacheManager.getPlaylistById(id);
        if (cachedPlaylist != null) {
          logger.i('📦 Returning cached playlist: ${cachedPlaylist.name}');
          return PlaylistMapper.fromModel(cachedPlaylist);
        }
      }

      // Fetch from API
      logger.i('🌐 Fetching playlist from API: $id');
      final playlistModel = await _playlistsApi.getPlaylistById(id);

      // Cache the result
      await _cacheManager.cachePlaylist(playlistModel);

      return PlaylistMapper.fromModel(playlistModel);
    } on ApiException {
      // Try cache as fallback
      final cachedPlaylist = await _cacheManager.getPlaylistById(id);
      if (cachedPlaylist != null) {
        logger.w('API failed, returning cached playlist');
        return PlaylistMapper.fromModel(cachedPlaylist);
      }
      rethrow;
    } catch (e) {
      logger.e('Error getting playlist by ID: $e');
      throw ApiException(message: 'Failed to get playlist: $e');
    }
  }

  @override
  Future<PlaylistEntity> createPlaylist(String name, List<String> songIds) async {
    try {
      logger.i('Creating playlist: $name');
      final newPlaylistModel = await _playlistsApi.createPlaylist(name, songIds);
      
      // Cache the new playlist
      await _cacheManager.cachePlaylist(newPlaylistModel);
      
      // Invalidate playlists cache to force refresh
      await _cacheManager.clearPlaylistsCache();
      
      return PlaylistMapper.fromModel(newPlaylistModel);
    } catch (e) {
      logger.e('Error creating playlist: $e');
      throw ApiException(message: 'Failed to create playlist: $e');
    }
  }

  @override
  Future<PlaylistEntity> updatePlaylist(
    String id, {
    String? name,
    List<String>? songIds,
  }) async {
    try {
      logger.i('Updating playlist: $id');
      final updatedPlaylist = await _playlistsApi.updatePlaylist(
        id,
        name: name,
        songIds: songIds,
      );
      
      // Update cache
      await _cacheManager.cachePlaylist(updatedPlaylist);
      
      return PlaylistMapper.fromModel(updatedPlaylist);
    } catch (e) {
      logger.e('Error updating playlist: $e');
      throw ApiException(message: 'Failed to update playlist: $e');
    }
  }

  @override
  Future<void> deletePlaylist(String id) async {
    try {
      logger.i('Deleting playlist: $id');
      await _playlistsApi.deletePlaylist(id);
      
      // Remove from cache
      await _cacheManager.deletePlaylist(id);
    } catch (e) {
      logger.e('Error deleting playlist: $e');
      throw ApiException(message: 'Failed to delete playlist: $e');
    }
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      logger.i('Adding song $songId to playlist $playlistId');
      await _playlistsApi.addSongToPlaylist(playlistId, songId);
      
      // Invalidate playlist cache to force refresh
      await _cacheManager.deletePlaylist(playlistId);
    } catch (e) {
      logger.e('Error adding song to playlist: $e');
      throw ApiException(message: 'Failed to add song to playlist: $e');
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      logger.i('Removing song $songId from playlist $playlistId');
      await _playlistsApi.removeSongFromPlaylist(playlistId, songId);
      
      // Invalidate playlist cache to force refresh
      await _cacheManager.deletePlaylist(playlistId);
    } catch (e) {
      logger.e('Error removing song from playlist: $e');
      throw ApiException(message: 'Failed to remove song from playlist: $e');
    }
  }

  @override
  Future<void> savePlaylist(PlaylistEntity playlist) async {
    try {
      logger.i('Saving playlist: ${playlist.name}');
      final playlistModel = PlaylistMapper.toModel(playlist);
      await _cacheManager.cachePlaylist(playlistModel);
    } catch (e) {
      logger.e('Error saving playlist: $e');
      throw ApiException(message: 'Failed to save playlist: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      logger.i('🗑️ Clearing playlist cache');
      await _cacheManager.clearPlaylistsCache();
      logger.d('Playlist cache cleared successfully');
    } catch (e) {
      logger.e('Error clearing cache: $e');
      throw ApiException(message: 'Failed to clear cache: $e');
    }
  }

  // Private helper methods

  Future<List<PlaylistModel>> _getCachedPlaylists() async {
    try {
      return await _cacheManager.getCachedPlaylists();
    } catch (e) {
      logger.w('Failed to get cached playlists: $e');
      return [];
    }
  }

  Future<void> _cachePlaylists(List<PlaylistModel> playlists) async {
    try {
      await _cacheManager.cachePlaylists(playlists);
      logger.d('💾 Cached ${playlists.length} playlists');
    } catch (e) {
      logger.w('Failed to cache playlists: $e');
    }
  }
}
