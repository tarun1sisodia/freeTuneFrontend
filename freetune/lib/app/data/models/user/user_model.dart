import 'package:isar/isar.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;
  final String userId;
  final String email;
  final String? username;
  final String? fullName;
  final String? profileImageUrl;
  final bool? emailVerified;

  UserModel({
    required this.userId,
    required this.email,
    this.username,
    this.fullName,
    this.profileImageUrl,
    this.emailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      fullName: json['fullName'] ?? json['full_name'],
      profileImageUrl: json['profileImageUrl'] ?? json['profile_image_url'],
      emailVerified: json['emailVerified'] ?? json['email_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'username': username,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'emailVerified': emailVerified,
    };
  }
}