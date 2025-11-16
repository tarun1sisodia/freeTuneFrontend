import 'package:shared_preferences/shared_preferences.dart';

class PreferencesStorage {
  static const String _themeKey = 'theme_mode';
  static const String _audioQualityKey = 'audio_quality';
  static const String _autoPlayKey = 'auto_play';
  static const String _downloadQualityKey = 'download_quality';

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> setAudioQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_audioQualityKey, quality);
  }

  Future<String?> getAudioQuality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_audioQualityKey) ?? 'medium';
  }

  Future<void> setAutoPlay(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, enabled);
  }

  Future<bool> getAutoPlay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPlayKey) ?? true;
  }

  Future<void> setDownloadQuality(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadQualityKey, quality);
  }

  Future<String?> getDownloadQuality() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_downloadQualityKey) ?? 'medium';
  }
}
