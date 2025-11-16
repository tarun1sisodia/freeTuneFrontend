import 'package:isar/isar.dart';
import '../../models/song/song_model.dart';
import 'isar_database.dart';

class CacheManager {
  static const int maxCacheSizeMB = 500;
  static const int targetCacheSizeMB = 400; // 20% buffer

  // Auto-cache top 100 most played songs
  Future<void> autoCacheTopSongs(List<SongModel> songs) async {
    final isar = await IsarDatabase.getInstance();
    final top100 = songs.take(100).toList();

    await isar.writeTxn(() async {
      await isar.songModels.putAll(top100);
    });
  }

  // LRU Eviction Policy
  Future<void> evictIfNeeded() async {
    final isar = await IsarDatabase.getInstance();
    // Use .build().findAll() to retrieve all songModels
    final cachedSongs = await isar.songModels.where().build().findAll();

    // Calculate current cache size (simplified)
    final currentSizeMB =
        cachedSongs.length * 3.6; // ~3.6MB per song (medium quality)

    if (currentSizeMB > maxCacheSizeMB) {
      // Sort by: play_count (desc) → cached_at (desc)
      cachedSongs.sort((a, b) {
        final playCountCompare = b.playCount.compareTo(a.playCount);
        if (playCountCompare != 0) return playCountCompare;
        if (a.cachedAt == null && b.cachedAt == null) return 0;
        if (a.cachedAt == null) return 1;
        if (b.cachedAt == null) return -1;
        return b.cachedAt!.compareTo(a.cachedAt!);
      });

      // Remove oldest/least played songs
      final toRemove = cachedSongs.length - (targetCacheSizeMB ~/ 3.6).toInt();
      if (toRemove > 0) {
        final songsToDelete =
            cachedSongs.sublist(cachedSongs.length - toRemove);

        await isar.writeTxn(() async {
          await isar.songModels
              .deleteAll(songsToDelete.map((s) => s.id as Id).toList());
        });
      }
    }
  }

  // Check if song is cached
  Future<bool> isCached(Id songId) async {
    final isar = await IsarDatabase.getInstance();
    return await isar.songModels.get(songId) != null;
  }

  // Get cached song
  Future<SongModel?> getCachedSong(Id songId) async {
    final isar = await IsarDatabase.getInstance();
    return await isar.songModels.get(songId);
  }

  // Cache song
  Future<void> cacheSong(SongModel song) async {
    final isar = await IsarDatabase.getInstance();
    await isar.writeTxn(() async {
      await isar.songModels.put(song.copyWith(cachedAt: DateTime.now()));
    });
  }
}
