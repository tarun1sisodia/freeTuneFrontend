import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel extends Equatable {
  Id id = Isar.autoIncrement;
  final String userId;
  final String email;
  final String? username;
  final String? profileImageUrl;

  UserModel({
    required this.userId,
    required this.email,
    this.username,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'],
      email: json['email'],
      username: json['username'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
    };
  }

  @override
  List<Object?> get props => [userId, email, username, profileImageUrl];
}