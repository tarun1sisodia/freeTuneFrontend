import '../datasources/remote/playlists_api.dart';
import '../datasources/local/isar_database.dart';
import '../models/playlist/playlist_model.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/utils/network_utils.dart';
import '../../domain/entities/playlist_entity.dart';
import '../mappers/playlist_mapper.dart';

class PlaylistRepository {
  final PlaylistsApi _playlistsApi;

  PlaylistRepository(this._playlistsApi);

  Future<List<PlaylistEntity>> getPlaylists() async {
    try {
      final isConnected = await NetworkUtils.isConnected();

      if (!isConnected) {
        // Return cached playlists if offline
        final isar = await IsarDatabase.getInstance();
        final cachedModels = await isar.playlistModels.where().findAll();
        return cachedModels.map((e) => PlaylistMapper.fromModel(e)).toList();
      }

      final playlists = await _playlistsApi.getPlaylists();

      // Cache playlists
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.putAll(playlists);
      });

      return playlists.map((e) => PlaylistMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PlaylistEntity> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final playlistModel = await _playlistsApi.createPlaylist(
        name: name,
        description: description,
        isPublic: isPublic,
      );

      // Cache the new playlist
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.put(playlistModel);
      });

      return PlaylistMapper.fromModel(playlistModel);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PlaylistEntity> getPlaylistById(String id) async {
    try {
      final isConnected = await NetworkUtils.isConnected();

      if (!isConnected) {
        // Return cached playlist if offline
        final isar = await IsarDatabase.getInstance();
        final cached = await isar.playlistModels.filter().idEqualTo(id).findFirst();
        if (cached != null) return PlaylistMapper.fromModel(cached);
      }

      final playlistModel = await _playlistsApi.getPlaylistById(id);

      // Cache playlist
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.put(playlistModel);
      });

      return PlaylistMapper.fromModel(playlistModel);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<PlaylistEntity> updatePlaylist({
    required String id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final playlistModel = await _playlistsApi.updatePlaylist(
        id: id,
        name: name,
        description: description,
        isPublic: isPublic,
      );

      // Update cache
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.put(playlistModel);
      });

      return PlaylistMapper.fromModel(playlistModel);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _playlistsApi.deletePlaylist(id);

      // Remove from cache
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.filter().idEqualTo(id).deleteFirst();
      });
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      await _playlistsApi.addSongToPlaylist(
        playlistId: playlistId,
        songId: songId,
      );

      // Refresh playlist in cache
      final playlistModel = await _playlistsApi.getPlaylistById(playlistId);
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.put(playlistModel);
      });
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    try {
      await _playlistsApi.removeSongFromPlaylist(
        playlistId: playlistId,
        songId: songId,
      );

      // Refresh playlist in cache
      final playlistModel = await _playlistsApi.getPlaylistById(playlistId);
      final isar = await IsarDatabase.getInstance();
      await isar.writeTxn(() async {
        await isar.playlistModels.put(playlistModel);
      });
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
