import '../../domain/entities/user_entity.dart';
import '../datasources/local/preferences_storage.dart';
import '../datasources/remote/auth_api.dart';
import '../mappers/user_mapper.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final PreferencesStorage _preferencesStorage;

  AuthRepositoryImpl(this._authApi, this._preferencesStorage);

  @override
  Future<UserEntity> login(String email, String password) async {
    final authResponse = await _authApi.login(email, password);
    await _preferencesStorage.saveAuthToken(authResponse.token);
    return UserMapper.fromModel(authResponse.user);
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    final authResponse = await _authApi.register(email, password);
    await _preferencesStorage.saveAuthToken(authResponse.token);
    return UserMapper.fromModel(authResponse.user);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = _preferencesStorage.getAuthToken();
    if (token == null) return null;
    try {
      final userModel = await _authApi.getCurrentUser();
      return UserMapper.fromModel(userModel);
    } catch (e) {
      // Token might be invalid or expired, clear it
      await _preferencesStorage.clearAuthToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _preferencesStorage.clearAuthToken();
    // Optionally call a logout API if needed
  }
}