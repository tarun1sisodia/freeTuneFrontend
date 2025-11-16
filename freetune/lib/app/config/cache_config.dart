class CacheConfig {
  static const int maxCacheSizeMb = 500; // 500 MB
  static const Duration defaultCacheDuration = Duration(days: 7); // 7 days
  static const String songCacheKey = 'song_cache';
}