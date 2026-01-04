import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/cache_keys.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage(this._storage);

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: CacheKeys.authToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: CacheKeys.authToken);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: CacheKeys.authToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: CacheKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: CacheKeys.refreshToken);
  }

  Future<void> clearRefreshToken() async {
    await _storage.delete(key: CacheKeys.refreshToken);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
