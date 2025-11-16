import 'package:isar/isar.dart';
import '../../models/song/song_model.dart';
import '../../models/playlist/playlist_model.dart';
import '../../models/user/user_model.dart';

class CacheManager {
  final Isar _isar;

  CacheManager(this._isar);

  // Songs
  Future<void> saveSongs(List<SongModel> songs) async {
    await _isar.writeTxn(() async {
      await _isar.songModels.putAll(songs);
    });
    await _evictOldSongs();
  }

  Future<List<SongModel>> getSongs() async {
    return await _isar.songModels.where().findAll();
  }

  Future<SongModel?> getSongById(String songId) async {
    return await _isar.songModels.filter().songIdEqualTo(songId).findFirst();
  }

  Future<void> deleteSong(String songId) async {
    await _isar.writeTxn(() async {
      await _isar.songModels.filter().songIdEqualTo(songId).deleteAll();
    });
  }

  // Playlists
  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    await _isar.writeTxn(() async {
      await _isar.playlistModels.putAll(playlists);
    });
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    return await _isar.playlistModels.where().findAll();
  }

  // Users
  Future<void> saveUser(UserModel user) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.put(user);
    });
  }

  Future<UserModel?> getUser() async {
    return await _isar.userModels.where().findFirst();
  }

  Future<void> clearAllCache() async {
    await _isar.writeTxn(() async {
      await _isar.clear();
    });
  }

  Future<void> _evictOldSongs() async {
    // Implement LRU eviction based on CacheConfig.maxCacheSizeMb
    // This is a simplified example, actual implementation would involve checking file sizes
    final allSongs = await _isar.songModels.where().findAll();
    if (allSongs.length > 100) { // Example: keep only 100 songs
      final songsToDelete = allSongs.sublist(100);
      await _isar.writeTxn(() async {
        await _isar.songModels.deleteAll(songsToDelete.map((e) => e.id).toList());
      });
    }
  }
}