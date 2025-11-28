import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/user/auth_response.dart';
import '../../models/user/user_model.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> register(String email, String password,
      {String? username}) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'confirmPassword': password, // Backend requires this for validation
        if (username != null) 'username': username,
      },
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _dio.get(ApiEndpoints.me);
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data);
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await _dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put(
      ApiEndpoints.updateProfile,
      data: data,
    );
    final responseData = response.data['data'] ?? response.data;
    return UserModel.fromJson(responseData);
  }
}
