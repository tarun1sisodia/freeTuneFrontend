import 'package:isar/isar.dart';
import '../../../core/exceptions/cache_exception.dart';
import '../../../core/utils/logger.dart';
import '../../models/song/song_model.dart';
import '../../models/playlist/playlist_model.dart';
import '../../models/user/user_model.dart';

/// Production-grade Cache Manager with comprehensive caching strategies
class CacheManager {
  final Isar _isar;

  // Cache limits and metadata keys
  static const int _maxSongsCache = 500;
  static const int _maxPopularCache = 50;
  static const int _maxFavoritesCache = 200;
  static const String _popularCacheKey = 'popular_songs';
  static const String _favoritesCacheKey = 'favorite_songs';

  CacheManager(this._isar);

  // ==================== SONGS CACHE ====================

  /// Cache multiple songs
  Future<void> cacheSongs(List<SongModel> songs) async {
    try {
      if (songs.isEmpty) return;

      await _isar.writeTxn(() async {
        await _isar.songModels.putAll(songs);
      });

      logger.d('💾 Cached ${songs.length} songs');

      // Clean up old songs if cache is too large
      await _evictOldSongs();
    } catch (e) {
      logger.e('Failed to cache songs: $e');
      throw CacheException('Failed to cache songs: $e');
    }
  }

  /// Cache single song
  Future<void> cacheSong(SongModel song) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.songModels.put(song);
      });

      logger.d('💾 Cached song: ${song.title}');
    } catch (e) {
      logger.e('Failed to cache song: $e');
      throw CacheException('Failed to cache song: $e');
    }
  }

  /// Get all cached songs
  Future<List<SongModel>> getCachedSongs() async {
    try {
      final songs =
          await _isar.songModels.where().sortByCreatedAtDesc().findAll();

      logger.d('📦 Retrieved ${songs.length} cached songs');
      return songs;
    } catch (e) {
      logger.e('Failed to get cached songs: $e');
      return [];
    }
  }

  /// Search within cached songs
  Future<List<SongModel>> searchCachedSongs(String query) async {
    try {
      if (query.isEmpty) return [];

      final songs = await _isar.songModels
          .filter()
          .titleContains(query, caseSensitive: false)
          .or()
          .artistContains(query, caseSensitive: false)
          .or()
          .albumContains(query, caseSensitive: false)
          .findAll();

      logger.d('📦 Found ${songs.length} cached songs matching "$query"');
      return songs;
    } catch (e) {
      logger.e('Failed to search cached songs: $e');
      return [];
    }
  }

  /// Get song by ID
  Future<SongModel?> getSongById(String songId) async {
    try {
      final song =
          await _isar.songModels.filter().songIdEqualTo(songId).findFirst();

      if (song != null) {
        logger.d('📦 Retrieved cached song: ${song.title}');
      }

      return song;
    } catch (e) {
      logger.e('Failed to get song by ID: $e');
      return null;
    }
  }

  /// Delete specific song from cache
  Future<void> deleteSong(String songId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.songModels.filter().songIdEqualTo(songId).deleteAll();
      });

      logger.d('🗑️ Deleted song from cache: $songId');
    } catch (e) {
      logger.e('Failed to delete song: $e');
      throw CacheException('Failed to delete song: $e');
    }
  }

  /// Clear all songs from cache
  Future<void> clearSongsCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.songModels.clear();
      });

      logger.d('🗑️ Cleared all songs from cache');
    } catch (e) {
      logger.e('Failed to clear songs cache: $e');
      throw CacheException('Failed to clear songs cache: $e');
    }
  }

  // ==================== POPULAR SONGS CACHE ====================

  /// Cache popular songs (with metadata flag)
  Future<void> cachePopularSongs(List<SongModel> songs) async {
    try {
      if (songs.isEmpty) return;

      // Mark songs as popular and cache them
      final popularSongs = songs.map((song) {
        song.isPopular = true;
        return song;
      }).toList();

      await _isar.writeTxn(() async {
        // Clear old popular songs
        final allSongs = await _isar.songModels.where().findAll();
        final oldPopular =
            allSongs.where((song) => song.isPopular == true).toList();

        for (var song in oldPopular) {
          song.isPopular = false;
          await _isar.songModels.put(song);
        }

        // Cache new popular songs
        await _isar.songModels.putAll(popularSongs);
      });

      logger.d('💾 Cached ${popularSongs.length} popular songs');
    } catch (e) {
      logger.e('Failed to cache popular songs: $e');
    }
  }

  /// Get cached popular songs
  Future<List<SongModel>> getCachedPopularSongs() async {
    try {
      final allSongs = await _isar.songModels.where().findAll();
      final songs = allSongs.where((song) => song.isPopular == true).toList();

      logger.d('📦 Retrieved ${songs.length} cached popular songs');
      return songs;
    } catch (e) {
      logger.e('Failed to get cached popular songs: $e');
      return [];
    }
  }

  // ==================== FAVORITES CACHE ====================

  /// Cache favorite songs
  Future<void> cacheFavorites(List<SongModel> songs) async {
    try {
      if (songs.isEmpty) return;

      // Mark songs as favorites
      final favoriteSongs = songs.map((song) {
        song.isFavorite = true;
        return song;
      }).toList();

      await _isar.writeTxn(() async {
        await _isar.songModels.putAll(favoriteSongs);
      });

      logger.d('💾 Cached ${favoriteSongs.length} favorite songs');
    } catch (e) {
      logger.e('Failed to cache favorites: $e');
    }
  }

  /// Get cached favorites
  Future<List<SongModel>> getCachedFavorites() async {
    try {
      final allSongs = await _isar.songModels.where().findAll();
      final songs = allSongs.where((song) => song.isFavorite == true).toList();

      logger.d('📦 Retrieved ${songs.length} cached favorites');
      return songs;
    } catch (e) {
      logger.e('Failed to get cached favorites: $e');
      return [];
    }
  }

  /// Clear favorites cache
  Future<void> clearFavoritesCache() async {
    try {
      await _isar.writeTxn(() async {
        final allSongs = await _isar.songModels.where().findAll();
        final favorites =
            allSongs.where((song) => song.isFavorite == true).toList();

        for (var song in favorites) {
          song.isFavorite = false;
          await _isar.songModels.put(song);
        }
      });

      logger.d('🗑️ Cleared favorites cache');
    } catch (e) {
      logger.e('Failed to clear favorites cache: $e');
    }
  }

  // ==================== PLAYLISTS CACHE ====================

  /// Cache playlists
  Future<void> cachePlaylists(List<PlaylistModel> playlists) async {
    try {
      if (playlists.isEmpty) return;

      await _isar.writeTxn(() async {
        await _isar.playlistModels.putAll(playlists);
      });

      logger.d('💾 Cached ${playlists.length} playlists');
    } catch (e) {
      logger.e('Failed to cache playlists: $e');
      throw CacheException('Failed to cache playlists: $e');
    }
  }

  /// Cache single playlist
  Future<void> cachePlaylist(PlaylistModel playlist) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.playlistModels.put(playlist);
      });

      logger.d('💾 Cached playlist: ${playlist.name}');
    } catch (e) {
      logger.e('Failed to cache playlist: $e');
      throw CacheException('Failed to cache playlist: $e');
    }
  }

  /// Get all cached playlists
  Future<List<PlaylistModel>> getCachedPlaylists() async {
    try {
      final playlists = await _isar.playlistModels.where().findAll();
      logger.d('📦 Retrieved ${playlists.length} cached playlists');
      return playlists;
    } catch (e) {
      logger.e('Failed to get cached playlists: $e');
      return [];
    }
  }

  /// Get playlist by ID
  Future<PlaylistModel?> getPlaylistById(String playlistId) async {
    try {
      final playlist = await _isar.playlistModels
          .filter()
          .playlistIdEqualTo(playlistId)
          .findFirst();

      if (playlist != null) {
        logger.d('📦 Retrieved cached playlist: ${playlist.name}');
      }

      return playlist;
    } catch (e) {
      logger.e('Failed to get playlist by ID: $e');
      return null;
    }
  }

  /// Delete playlist from cache
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.playlistModels
            .filter()
            .playlistIdEqualTo(playlistId)
            .deleteAll();
      });

      logger.d('🗑️ Deleted playlist from cache: $playlistId');
    } catch (e) {
      logger.e('Failed to delete playlist: $e');
      throw CacheException('Failed to delete playlist: $e');
    }
  }

  /// Clear all playlists from cache
  Future<void> clearPlaylistsCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.playlistModels.clear();
      });

      logger.d('🗑️ Cleared all playlists from cache');
    } catch (e) {
      logger.e('Failed to clear playlists cache: $e');
      throw CacheException('Failed to clear playlists cache: $e');
    }
  }

  // ==================== USER CACHE ====================

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.userModels.put(user);
      });

      logger.d('💾 Cached user: ${user.username}');
    } catch (e) {
      logger.e('Failed to save user: $e');
      throw CacheException('Failed to save user: $e');
    }
  }

  /// Get current user
  Future<UserModel?> getUser() async {
    try {
      final user = await _isar.userModels.where().findFirst();

      if (user != null) {
        logger.d('📦 Retrieved cached user: ${user.username}');
      }

      return user;
    } catch (e) {
      logger.e('Failed to get user: $e');
      return null;
    }
  }

  /// Clear user data
  Future<void> clearUser() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.userModels.clear();
      });

      logger.d('🗑️ Cleared user cache');
    } catch (e) {
      logger.e('Failed to clear user: $e');
      throw CacheException('Failed to clear user: $e');
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await _isar.writeTxn(() async {
        await _isar.clear();
      });

      logger.i('🗑️ Cleared all cache');
    } catch (e) {
      logger.e('Failed to clear all cache: $e');
      throw CacheException('Failed to clear all cache: $e');
    }
  }

  /// Get cache size info
  Future<Map<String, int>> getCacheInfo() async {
    try {
      final songCount = await _isar.songModels.count();
      final playlistCount = await _isar.playlistModels.count();
      final userCount = await _isar.userModels.count();

      final info = {
        'songs': songCount,
        'playlists': playlistCount,
        'users': userCount,
        'total': songCount + playlistCount + userCount,
      };

      logger.d('📊 Cache info: $info');
      return info;
    } catch (e) {
      logger.e('Failed to get cache info: $e');
      return {'songs': 0, 'playlists': 0, 'users': 0, 'total': 0};
    }
  }

  /// Check if cache is healthy
  Future<bool> isCacheHealthy() async {
    try {
      // Try to perform a simple read operation
      await _isar.songModels.count();
      return true;
    } catch (e) {
      logger.e('Cache health check failed: $e');
      return false;
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Evict old songs when cache is too large (LRU strategy)
  Future<void> _evictOldSongs() async {
    try {
      final allSongs =
          await _isar.songModels.where().sortByCreatedAt().findAll();

      if (allSongs.length > _maxSongsCache) {
        final songsToDelete = allSongs.length - _maxSongsCache;
        final deleteSongs = allSongs.sublist(0, songsToDelete);

        await _isar.writeTxn(() async {
          for (var song in deleteSongs) {
            await _isar.songModels.delete(song.id);
          }
        });

        logger.d('🗑️ Evicted $songsToDelete old songs from cache');
      }
    } catch (e) {
      logger.w('Failed to evict old songs: $e');
    }
  }

  /// Update song metadata (last accessed, play count, etc.)
  Future<void> updateSongMetadata(
    String songId, {
    DateTime? lastAccessed,
    int? playCount,
  }) async {
    try {
      final song = await getSongById(songId);
      if (song != null) {
        if (lastAccessed != null) {
          song.updatedAt = lastAccessed;
        }
        if (playCount != null) {
          song.playCount = playCount;
        }

        await cacheSong(song);
      }
    } catch (e) {
      logger.w('Failed to update song metadata: $e');
    }
  }
}
