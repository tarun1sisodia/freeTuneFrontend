import '../../domain/entities/user_entity.dart';
import '../datasources/local/preferences_storage.dart';
import '../datasources/local/secure_storage.dart';
import '../datasources/remote/auth_api.dart';
import '../mappers/user_mapper.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password,
      {String? username});
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<UserEntity> updateProfile(
      {String? username, String? bio, String? avatarUrl});
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _authApi;
  final PreferencesStorage _preferencesStorage;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl(
      this._authApi, this._preferencesStorage, this._secureStorage);

  @override
  Future<UserEntity> login(String email, String password) async {
    final authResponse = await _authApi.login(email, password);
    await _secureStorage.saveAuthToken(authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await _secureStorage.saveRefreshToken(authResponse.refreshToken!);
    }
    return UserMapper.fromModel(authResponse.user);
  }

  @override
  Future<UserEntity> register(String email, String password,
      {String? username}) async {
    final authResponse =
        await _authApi.register(email, password, username: username);
    await _secureStorage.saveAuthToken(authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await _secureStorage.saveRefreshToken(authResponse.refreshToken!);
    }
    return UserMapper.fromModel(authResponse.user);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _secureStorage.getAuthToken();
    if (token == null) return null;
    try {
      final userModel = await _authApi.getCurrentUser();
      return UserMapper.fromModel(userModel);
    } catch (e) {
      await _secureStorage.clearAuthToken();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearAuthToken();
    await _secureStorage.clearRefreshToken();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _authApi.forgotPassword(email);
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _authApi.changePassword(currentPassword, newPassword);
  }

  @override
  Future<UserEntity> updateProfile(
      {String? username, String? bio, String? avatarUrl}) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    final userModel = await _authApi.updateProfile(data);
    return UserMapper.fromModel(userModel);
  }
}
