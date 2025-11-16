import 'package:equatable/equatable.dart';
import '../user/user_model.dart';

class AuthResponse extends Equatable {
  final String token;
  final UserModel user;

  const AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }

  @override
  List<Object?> get props => [token, user];
}