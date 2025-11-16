import 'package:dio/dio.dart';
import '../../models/user/user_model.dart';
import '../../models/user/auth_response.dart';
import '../../../core/constants/api_endpoints.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  // POST /api/v1/auth/register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _dio.post(ApiEndpoints.register, data: {
      'email': email,
      'password': password,
      'name': name,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  // POST /api/v1/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  // GET /api/v1/auth/me
  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data['data']);
  }

  // PATCH /api/v1/auth/profile
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch(ApiEndpoints.updateProfile, data: data);
    return UserModel.fromJson(response.data['data']);
  }

  // POST /api/v1/auth/change-password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post(ApiEndpoints.changePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  // POST /api/v1/auth/logout
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  // POST /api/v1/auth/refresh-token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(ApiEndpoints.refreshToken, data: {
      'refresh_token': refreshToken,
    });
    return AuthResponse.fromJson(response.data['data']);
  }

  // POST /api/v1/auth/forgot-password
  Future<void> forgotPassword(String email) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  // POST /api/v1/auth/reset-password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post(ApiEndpoints.resetPassword, data: {
      'token': token,
      'new_password': newPassword,
    });
  }

  // POST /api/v1/auth/verify-email
  Future<void> verifyEmail(String token) async {
    await _dio.post(ApiEndpoints.verifyEmail, data: {'token': token});
  }

  // POST /api/v1/auth/resend-verification
  Future<void> resendVerification(String email) async {
    await _dio.post(ApiEndpoints.resendVerification, data: {'email': email});
  }
}
