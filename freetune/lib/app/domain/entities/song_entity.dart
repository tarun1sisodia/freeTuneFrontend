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
  final bool? isFavorite;
  final bool? isPopular;

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
    this.isFavorite,
    this.isPopular,
    this.downloadUrl,
  });

  final String? downloadUrl;

  /// Convenience getter for songId (alias for id)
  String get songId => id;

  /// Create a copy with optional field updates
  SongEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArtUrl,
    int? durationMs,
    String? r2Key,
    Map<String, int>? fileSizes,
    int? playCount,
    DateTime? lastUpdated,
    double? popularityScore,
    DateTime? createdAt,
    bool? isFavorite,
    bool? isPopular,
    String? downloadUrl,
  }) {
    return SongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      durationMs: durationMs ?? this.durationMs,
      r2Key: r2Key ?? this.r2Key,
      fileSizes: fileSizes ?? this.fileSizes,
      playCount: playCount ?? this.playCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      popularityScore: popularityScore ?? this.popularityScore,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isPopular: isPopular ?? this.isPopular,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

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
        isFavorite,
        isPopular,
        downloadUrl,
      ];
}
