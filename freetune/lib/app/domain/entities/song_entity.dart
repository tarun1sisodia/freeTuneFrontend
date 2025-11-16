import 'package:equatable/equatable.dart';

class SongEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtUrl;
  final int durationMs;
  final String r2Key;
  final Map<String, int> fileSizes;
  final int playCount;
  final DateTime lastUpdated;
  final double popularityScore;
  final DateTime createdAt;

  const SongEntity({
    required this.id,
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
  });

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        albumArtUrl,
        durationMs,
        r2Key,
        fileSizes,
        playCount,
        lastUpdated,
        popularityScore,
        createdAt,
      ];
}