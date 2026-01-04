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
  Future<String?> getCachedAudioPath(String url) async {
    try {
      final file = await _cacheManager.getSingleFile(url);
      logger.d('📦 Retrieved audio from cache: $url');
      return file.path;
    } catch (e) {
      logger.e('Failed to get cached audio: $e');
      return null;
    }
  }

  /// Pre-cache audio file
  Future<void> cacheAudio(String url) async {
    try {
      await _cacheManager.downloadFile(url);
      logger.d('💾 Cached audio file: $url');
    } catch (e) {
      logger.e('Failed to cache audio: $e');
    }
  }

  /// Remove specific file from cache
  Future<void> removeFile(String url) async {
    try {
      await _cacheManager.removeFile(url);
      logger.d('🗑️ Removed audio from cache: $url');
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
