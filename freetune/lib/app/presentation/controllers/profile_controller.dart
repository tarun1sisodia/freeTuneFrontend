import 'package:get/get.dart';
import '../../core/mixins/error_handler_mixin.dart';
import '../../core/mixins/loading_mixin.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/local/cache_manager.dart';
import '../../data/datasources/local/preferences_storage.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController
    with ErrorHandlerMixin, LoadingMixin {
  final CacheManager _cacheManager;
  final PreferencesStorage _preferencesStorage;
  final AuthController _authController = Get.find<AuthController>();

  // Observable state
  final RxInt totalSongsPlayed = 0.obs;
  final RxInt totalPlaylists = 0.obs;
  final RxInt totalFavorites = 0.obs;
  final RxString selectedTheme = 'dark'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString audioQuality = 'high'.obs;

  ProfileController(this._cacheManager, this._preferencesStorage);

  @override
  void onInit() {
    super.onInit();
    _loadProfileStats();
    _loadUserPreferences();
  }

  UserEntity? get currentUser => _authController.user.value;

  Future<void> _loadProfileStats() async {
    try {
      final cacheInfo = await _cacheManager.getCacheInfo();
      totalFavorites.value = cacheInfo['songs'] ?? 0;
      totalPlaylists.value = cacheInfo['playlists'] ?? 0;
      logger.d('Profile stats loaded');
    } catch (e) {
      logger.e('Failed to load profile stats: $e');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      selectedTheme.value = _preferencesStorage.getTheme();
      audioQuality.value = _preferencesStorage.getAudioQuality();
      notificationsEnabled.value =
          _preferencesStorage.getNotificationsEnabled();
      logger.d('User preferences loaded');
    } catch (e) {
      logger.e('Failed to load user preferences: $e');
    }
  }

  Future<void> updateTheme(String theme) async {
    try {
      selectedTheme.value = theme;
      await _preferencesStorage.saveTheme(theme);
      logger.d('Theme updated to: $theme');
      Get.snackbar(
        'Theme Updated',
        'Theme changed to ${theme.capitalize}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      handleError('Failed to update theme: $e');
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      notificationsEnabled.value = enabled;
      await _preferencesStorage.saveNotificationsEnabled(enabled);
      logger.d('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      handleError('Failed to update notifications: $e');
    }
  }

  Future<void> updateAudioQuality(String quality) async {
    try {
      audioQuality.value = quality;
      await _preferencesStorage.saveAudioQuality(quality);
      logger.d('Audio quality updated to: $quality');
      Get.snackbar(
        'Audio Quality Updated',
        'Quality changed to ${quality.toUpperCase()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      handleError('Failed to update audio quality: $e');
    }
  }

  Future<void> clearCache() async {
    showLoading();
    try {
      await _cacheManager.clearAllCache();
      await _loadProfileStats();
      Get.snackbar(
        'Success',
        'Cache cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      handleError('Failed to clear cache: $e');
    } finally {
      hideLoading();
    }
  }

  Future<void> logout() async {
    await _authController.logout();
  }

  void refreshStats() {
    _loadProfileStats();
  }
}
