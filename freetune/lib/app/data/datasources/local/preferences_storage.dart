import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/cache_keys.dart';

class PreferencesStorage {
  final SharedPreferences _prefs;

  PreferencesStorage(this._prefs);

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(CacheKeys.authToken, token);
  }

  String? getAuthToken() {
    return _prefs.getString(CacheKeys.authToken);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove(CacheKeys.authToken);
  }

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
}