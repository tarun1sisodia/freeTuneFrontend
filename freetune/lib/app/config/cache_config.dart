/// Centralized and extensible cache configuration.
/// Supports global/cache-type overrides, size unit conversions, and feature flags.
class CacheConfig {
  /// Default max cache size across the app (in megabytes)
  static const int defaultMaxCacheSizeMB = 500;

  /// Target size for cleanup trigger (in megabytes, buffer for overflow)
  static const int defaultTargetCacheSizeMB = 400;

  /// Minimum allowed cache size (safety net)
  static const int minCacheSizeMB = 50;

  /// Per-cache-type configurations (extensible)
  static const Map<CacheType, CacheLimits> cacheTypeLimits = {
    CacheType.audio: CacheLimits(maxMB: 300, targetMB: 250),
    CacheType.image: CacheLimits(maxMB: 100, targetMB: 80),
    CacheType.metadata: CacheLimits(maxMB: 50, targetMB: 40),
    // Add additional cache type configs as needed
  };

  /// Feature flags for advanced cache management techniques
  static const bool enableProactiveCleanup = true; // background clean
  static const bool enableLRU = true; // least-recently used eviction
  static const bool debugLogging = false;

  /// Returns cache size in bytes for any cache type, with sensible fallback.
  static int getMaxCacheSizeBytes([CacheType? type]) {
    final maxMB = type != null && cacheTypeLimits.containsKey(type)
        ? cacheTypeLimits[type]!.maxMB
        : defaultMaxCacheSizeMB;
    return mbToBytes(maxMB);
  }

  static int getTargetCacheSizeBytes([CacheType? type]) {
    final targetMB = type != null && cacheTypeLimits.containsKey(type)
        ? cacheTypeLimits[type]!.targetMB
        : defaultTargetCacheSizeMB;
    return mbToBytes(targetMB);
  }

  /// Utility: Convert MB to bytes
  static int mbToBytes(int mb) => mb * 1024 * 1024;
}

/// Defines cache types for fine-grained limits and behaviors.
enum CacheType { audio, image, metadata }

/// Strong type for cache size limits per cache type.
class CacheLimits {
  final int maxMB;
  final int targetMB;
  const CacheLimits({required this.maxMB, required this.targetMB});
}
