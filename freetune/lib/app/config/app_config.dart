class AppConfig {
  static const String appName = 'FreeTune';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Zero-cost personal music streaming platform';
  
  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;
  
  // Cache Settings
  static const int maxCacheSizeMB = 500;
  static const int cacheExpiryDays = 7;
  
  // Audio Settings
  static const int defaultAudioQuality = 320; // kbps
  static const List<int> availableQualities = [128, 192, 320];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}