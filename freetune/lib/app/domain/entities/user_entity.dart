import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? profileImageUrl;
  final String? bio;
  final bool? emailVerified;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.profileImageUrl,
    this.bio,
    this.emailVerified,
  });

  @override
  List<Object?> get props =>
      [id, email, username, fullName, profileImageUrl, bio, emailVerified];
}
