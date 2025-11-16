import 'package:isar/isar.dart';
import '../song/song_model.dart';

part 'playlist_model.g.dart';

@collection
class PlaylistModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id;

  String name;
  String? description;
  bool isPublic;
  String? coverArt;
  List<String> songIds;
  DateTime createdAt;
  DateTime updatedAt;

  // Transient field for songs (not stored in Isar)
  @ignore
  List<SongModel>? songs;

  PlaylistModel({
    required this.id,
    required this.name,
    this.description,
    this.isPublic = false,
    this.coverArt,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.songs,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      coverArt: json['cover_art'] as String?,
      songIds: (json['song_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      songs: json['songs'] != null
          ? (json['songs'] as List<dynamic>)
              .map((e) => SongModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_public': isPublic,
      'cover_art': coverArt,
      'song_ids': songIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (songs != null) 'songs': songs!.map((s) => s.toJson()).toList(),
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isPublic,
    String? coverArt,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SongModel>? songs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      coverArt: coverArt ?? this.coverArt,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songs: songs ?? this.songs,
    );
  }
}
