import 'package:isar/isar.dart';

import 'file_size_model.dart';

part 'song_model.g.dart';

@collection
class SongModel {
  Id id = Isar.autoIncrement;
  final String songId;
  final String title;
  final String artist;
  final String album;
  final String? albumArtUrl;
  final int durationMs;
  final String r2Key;
  final List<FileSize> fileSizes; // e.g., {'high': 12345, 'medium': 6789}
  final int playCount;
  final DateTime lastUpdated;
  final double popularityScore;

  SongModel({
    required this.songId,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtUrl,
    required this.durationMs,
    required this.r2Key,
    required this.fileSizes,
    this.playCount = 0,
    required this.lastUpdated,
    this.popularityScore = 0.0,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      songId: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      albumArtUrl: json['albumArtUrl'],
      durationMs: json['durationMs'],
      r2Key: json['r2Key'],
      fileSizes: (Map<String, int>.from(json['fileSizes'])).entries.map((e) => FileSize()..quality = e.key..size = e.value).toList(),
      playCount: json['playCount'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      popularityScore: json['popularityScore']?.toDouble() ?? 0.0,
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
      'fileSizes': { for (var v in fileSizes) v.quality : v.size },
      'playCount': playCount,
      'lastUpdated': lastUpdated.toIso8601String(),
      'popularityScore': popularityScore,
    };
  }
}