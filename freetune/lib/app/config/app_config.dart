/// Global application configuration for FreeTune.
/// See comprehensive structure in ap.md

class AppConfig {
  // App Info
  static const String appName = 'FreeTune';
  static const String appVersion = '1.0.0+1';

  // Environment
  static const bool isProduction = false; // Set to true for release builds

  // Caching
  static const int maxCacheSizeMB = 500;
  static const int targetCacheSizeMB = 400; // 20% buffer for proactive cleanup

  // Network
  static const int connectionTimeoutMs = 10000;
  static const int receiveTimeoutMs = 12000;

  // Theme
  static const String defaultTheme =
      'system'; // can be 'light', 'dark', 'system'

  // Pagination
  static const int defaultPageSize = 20;

  // Offline Mode
  static const bool enableOfflineMode = true;

  // Analytics
  static const bool analyticsEnabled = true;

  // Features (toggle for A/B testing or hot rollout)
  static const bool enableRecommendations = true;
  static const bool enablePlaylists = true;
  static const bool enableShimmerPlaceholders = true;

  // Add any other global app-wide constant or switch here.
}
