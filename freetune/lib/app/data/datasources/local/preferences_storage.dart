import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/cache_keys.dart';

class PreferencesStorage {
  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  // Auth tokens are now handled by SecureStorage

  // Generic methods for other preferences
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // User Preferences
  Future<void> saveTheme(String theme) async {
    await _prefs.setString(CacheKeys.theme, theme);
  }

  String getTheme() {
    return _prefs.getString(CacheKeys.theme) ?? 'dark';
  }

  Future<void> saveAudioQuality(String quality) async {
    await _prefs.setString(CacheKeys.audioQuality, quality);
  }

  String getAudioQuality() {
    return _prefs.getString(CacheKeys.audioQuality) ?? 'high';
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(CacheKeys.notificationsEnabled, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(CacheKeys.notificationsEnabled) ?? true;
  }
}
