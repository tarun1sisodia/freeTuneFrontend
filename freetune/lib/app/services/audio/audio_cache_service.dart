import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import '../../core/utils/logger.dart';

/// Service to handle audio file caching for offline playback
class AudioCacheService extends GetxService {
  static const key = 'customCacheKey';

  late final CacheManager _cacheManager;

  @override
  void onInit() {
    super.onInit();
    _initCacheManager();
  }

  void _initCacheManager() {
    _cacheManager = CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 100,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
    logger.i('AudioCacheService initialized');
  }

  /// Get file from cache or download it
  /// [key] is optional. If provided, it maps the URL to this key (e.g., song ID).
  Future<String?> getCachedAudioPath(String url, {String? key}) async {
    try {
      final file = await _cacheManager.getSingleFile(url, key: key);
      logger.d('📦 Retrieved audio from cache: $url (Key: $key)');
      return file.path;
    } catch (e) {
      logger.e('Failed to get cached audio: $e');
      return null;
    }
  }

  /// Get file ONLY if it exists in cache (no download)
  Future<String?> getFileFromCache(String url, {String? key}) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(key ?? url);
      if (fileInfo != null) {
        return fileInfo.file.path;
      }
      return null;
    } catch (e) {
      logger.e('Error checking cache: $e');
      return null;
    }
  }

  /// Check if file is cached
  Future<bool> isCached(String url, {String? key}) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(key ?? url);
      return fileInfo != null;
    } catch (e) {
      return false;
    }
  }

  /// Pre-cache audio file
  Future<void> cacheAudio(String url, {String? key}) async {
    try {
      await _cacheManager.downloadFile(url, key: key);
      logger.d('💾 Cached audio file: $url (Key: $key)');
    } catch (e) {
      logger.e('Failed to cache audio: $e');
      rethrow; // Allow caller to handle error
    }
  }

  /// Remove specific file from cache
  Future<void> removeFile(String url, {String? key}) async {
    try {
      await _cacheManager.removeFile(key ?? url);
      logger.d('🗑️ Removed audio from cache: $url (Key: $key)');
    } catch (e) {
      logger.e('Failed to remove audio from cache: $e');
    }
  }

  /// Clear all cached audio
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      logger.d('🗑️ Cleared all audio cache');
    } catch (e) {
      logger.e('Failed to clear audio cache: $e');
    }
  }
}
