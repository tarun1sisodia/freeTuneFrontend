import 'package:isar/isar.dart';

part 'user_preferences_model.g.dart';

@collection
class UserPreferencesModel {
  Id id = Isar.autoIncrement;
  final String userId;
  final String preferredQuality;
  final bool autoDownload;
  final String downloadQuality;
  final bool dataSaverMode;
  final String theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferencesModel({
    required this.userId,
    this.preferredQuality = 'high',
    this.autoDownload = false,
    this.downloadQuality = 'medium',
    this.dataSaverMode = false,
    this.theme = 'dark',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userId: json['userId'],
      preferredQuality: json['preferredQuality'] ?? 'high',
      autoDownload: json['autoDownload'] ?? false,
      downloadQuality: json['downloadQuality'] ?? 'medium',
      dataSaverMode: json['dataSaverMode'] ?? false,
      theme: json['theme'] ?? 'dark',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'preferredQuality': preferredQuality,
      'autoDownload': autoDownload,
      'downloadQuality': downloadQuality,
      'dataSaverMode': dataSaverMode,
      'theme': theme,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
