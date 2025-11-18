import 'package:isar/isar.dart';

import 'file_size_model.dart';

part 'song_model.g.dart';

@collection
class SongModel {
  Id id = Isar.autoIncrement;
  
  final String songId;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtUrl;
  final int durationMs;
  final String r2Key;
  final List<FileSize> fileSizes;
  int playCount;
  final DateTime lastUpdated;
  final double popularityScore;
  final DateTime createdAt;
  
  // Cache-specific fields
  DateTime? updatedAt;
  bool? isFavorite;
  bool? isPopular;

  SongModel({
    required this.songId,
    required this.title,
    required this.artist,
    this.album,
    this.albumArtUrl,
    required this.durationMs,
    required this.r2Key,
    required this.fileSizes,
    this.playCount = 0,
    required this.lastUpdated,
    this.popularityScore = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.isFavorite,
    this.isPopular,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      songId: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? 'Unknown',
      album: json['album'],
      albumArtUrl: json['albumArtUrl'],
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
      r2Key: json['r2Key'] ?? '',
      fileSizes: json['fileSizes'] != null
          ? (json['fileSizes'] as Map<String, dynamic>)
              .entries
              .map((e) => FileSize()
                ..quality = e.key
                ..size = (e.value as num).toInt())
              .toList()
          : [],
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
      popularityScore: (json['popularityScore'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isFavorite: json['isFavorite'],
      isPopular: json['isPopular'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': songId,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArtUrl': albumArtUrl,
      'durationMs': durationMs,
      'r2Key': r2Key,
      'fileSizes': {for (var v in fileSizes) v.quality: v.size},
      'playCount': playCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'popularityScore': popularityScore,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isPopular != null) 'isPopular': isPopular,
    };
  }
}