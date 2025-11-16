import 'package:equatable/equatable.dart';
import '../user/user_model.dart';

class AuthResponse extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;

  const AuthResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { statusCode, success, message, data: { user, accessToken, refreshToken }, timestamp }
    final data = json['data'] ?? json;
    return AuthResponse(
      accessToken: data['accessToken'] ?? '',
      refreshToken: data['refreshToken'],
      user: UserModel.fromJson(data['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}