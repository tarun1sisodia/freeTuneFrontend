import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/user/auth_response.dart';
import '../../models/user/user_model.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<AuthResponse> register(String email, String password) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password},
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
    return UserModel.fromJson(response.data);
  }
}