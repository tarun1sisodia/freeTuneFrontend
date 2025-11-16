import 'package:equatable/equatable.dart';
import 'song_entity.dart';

class PlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isPublic;
  final String? coverArt;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SongEntity>? songs;

  const PlaylistEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        isPublic,
        coverArt,
        songIds,
        createdAt,
        updatedAt,
        songs,
      ];
}
