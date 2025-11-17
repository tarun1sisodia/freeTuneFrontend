import 'package:isar/isar.dart';
import '../../../config/cache_config.dart';
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
    // This is a best-effort implementation that:
    // - tries to read per-song size from common field names (fileSizeBytes, fileSize, size, byteSize)
    // - tries to read a last-access timestamp from common field names (lastAccessed, lastPlayedAt, updatedAt, accessedAt)
    // - falls back to Isar's auto-increment id (older ids treated as older items)
    // - falls back to a conservative per-item estimate if no size field is found
    int getSizeBytes(SongModel s) {
      try {
      final dyn = s as dynamic;
      final candidates = [
        dyn.fileSizeBytes,
        dyn.fileSize,
        dyn.size,
        dyn.byteSize,
      ];
      for (final v in candidates) {
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
        }
      }
      } catch (_) {}
      // Conservative fallback: assume 1 MB per song if unknown
      return 1 * 1024 * 1024;
    }

    int getAccessTimestamp(SongModel s) {
      try {
      final dyn = s as dynamic;
      final cand = dyn.lastAccessed ?? dyn.lastPlayedAt ?? dyn.updatedAt ?? dyn.accessedAt;
      if (cand is DateTime) return cand.millisecondsSinceEpoch;
      if (cand is int) return cand;
      } catch (_) {}
      // Fallback to id (older ids => older items)
      try {
      return (s as dynamic).id as int;
      } catch (_) {
      return 0;
      }
    }

    int? maxCacheMb;
    try {
      // Try to read CacheConfig.maxCacheSizeMb if available in project.
      maxCacheMb = (CacheConfig.maxCacheSizeMb as int?);
    } catch (_) {
      maxCacheMb = null;
    }

    // If CacheConfig not available, keep the existing simple threshold behavior.
    if (maxCacheMb == null) {
      // No-op here; existing length-based eviction below will run.
    } else {
      final allSongsForEviction = await _isar.songModels.where().findAll();
      var totalBytes = 0;
      final entries = <Map<String, dynamic>>[];
      for (final s in allSongsForEviction) {
      final size = getSizeBytes(s);
      final ts = getAccessTimestamp(s);
      totalBytes += size;
      entries.add({'song': s, 'size': size, 'ts': ts});
      }

      final maxBytes = maxCacheMb * 1024 * 1024;
      if (totalBytes > maxBytes) {
      // Sort by access timestamp ascending (oldest first). Tie-breaker: id.
      entries.sort((a, b) {
        final ta = a['ts'] as int;
        final tb = b['ts'] as int;
        if (ta != tb) return ta.compareTo(tb);
        final ida = (a['song'] as SongModel).id;
        final idb = (b['song'] as SongModel).id;
        return (ida).compareTo(idb);
      });

      final idsToDelete = <int>[];
      var bytesFreed = 0;
      for (final e in entries) {
        if (totalBytes - bytesFreed <= maxBytes) break;
        final s = e['song'] as SongModel;
        final size = e['size'] as int;
        final id = s.id;
        // ignore: unnecessary_null_comparison
        if (id != null) {
        idsToDelete.add(id);
        bytesFreed += size;
        }
      }

      if (idsToDelete.isNotEmpty) {
        await _isar.writeTxn(() async {
        await _isar.songModels.deleteAll(idsToDelete);
        });
      }
      }
    }
    final allSongs = await _isar.songModels.where().findAll();
    if (allSongs.length > 100) { // Example: keep only 100 songs
      final songsToDelete = allSongs.sublist(100);
      await _isar.writeTxn(() async {
        await _isar.songModels.deleteAll(songsToDelete.map((e) => e.id).toList());
      });
    }
  }
}