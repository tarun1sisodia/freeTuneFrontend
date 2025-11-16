import 'package:isar/isar.dart';

part 'song_model.g.dart';

@collection
class SongModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id;
  String title;
  String artist;
  String? album;
  String? albumArt;
  int durationMs;
  String? genre;
  int playCount;
  bool isFavorite;
  DateTime? cachedAt;
  String? localFilePath;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArt,
    required this.durationMs,
    this.genre,
    this.playCount = 0,
    this.isFavorite = false,
    this.cachedAt,
    this.localFilePath,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      albumArt: json['album_art'] as String?,
      durationMs: json['duration_ms'] as int,
      genre: json['genre'] as String?,
      playCount: json['play_count'] as int? ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      cachedAt: json['cached_at'] != null
          ? DateTime.parse(json['cached_at'] as String)
          : null,
      localFilePath: json['local_file_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'album_art': albumArt,
      'duration_ms': durationMs,
      'genre': genre,
      'play_count': playCount,
      'is_favorite': isFavorite,
      'cached_at': cachedAt?.toIso8601String(),
      'local_file_path': localFilePath,
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    int? durationMs,
    String? genre,
    int? playCount,
    bool? isFavorite,
    DateTime? cachedAt,
    String? localFilePath,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      durationMs: durationMs ?? this.durationMs,
      genre: genre ?? this.genre,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
      cachedAt: cachedAt ?? this.cachedAt,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  @ignore
  Duration get duration => Duration(milliseconds: durationMs);
}
