import 'package:isar/isar.dart';

part 'user_interaction_model.g.dart';

@collection
class UserInteractionModel {
  Id id = Isar.autoIncrement;
  final String interactionId;
  final String userId;
  final String songId;
  final String actionType; // play, like, skip, download
  final String? sessionId;
  final DateTime createdAt;

  UserInteractionModel({
    required this.interactionId,
    required this.userId,
    required this.songId,
    required this.actionType,
    this.sessionId,
    required this.createdAt,
  });

  factory UserInteractionModel.fromJson(Map<String, dynamic> json) {
    return UserInteractionModel(
      interactionId: json['id'],
      userId: json['userId'],
      songId: json['songId'],
      actionType: json['actionType'],
      sessionId: json['sessionId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': interactionId,
      'userId': userId,
      'songId': songId,
      'actionType': actionType,
      'sessionId': sessionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
