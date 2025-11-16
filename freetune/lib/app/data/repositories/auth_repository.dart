import '../datasources/remote/auth_api.dart';
import '../datasources/remote/api_client.dart';
import '../models/user/user_model.dart';
import '../../core/exceptions/api_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../mappers/user_mapper.dart';

class AuthRepository {
  final AuthApi _authApi;
  final ApiClient _apiClient;

  AuthRepository(this._authApi, this._apiClient);
// login 
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await _authApi.login(email: email, password: password);
      await _apiClient.saveTokens(response.accessToken, response.refreshToken);
      return UserMapper.fromModel(response.user);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
// Register
  Future<UserEntity> register(String email, String password, String name) async {
    try {
      final response = await _authApi.register(
        email: email,
        password: password,
        name: name,
      );
      await _apiClient.saveTokens(response.accessToken, response.refreshToken);
      return UserMapper.fromModel(response.user);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _authApi.getCurrentUser();
      return UserMapper.fromModel(userModel);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
      await _apiClient.clearTokens();
    } catch (e) {
      // Even if logout fails, clear local tokens
      await _apiClient.clearTokens();
    }
  }

  Future<UserEntity> updateProfile(Map<String, dynamic> data) async {
    try {
      final userModel = await _authApi.updateProfile(data);
      return UserMapper.fromModel(userModel);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      await _authApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authApi.forgotPassword(email);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _authApi.resetPassword(token: token, newPassword: newPassword);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
