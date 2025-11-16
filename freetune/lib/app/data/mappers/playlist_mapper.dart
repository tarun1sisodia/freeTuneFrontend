import '../../domain/entities/playlist_entity.dart';
import '../models/playlist/playlist_model.dart';
import 'song_mapper.dart';

class PlaylistMapper {
  static PlaylistEntity fromModel(PlaylistModel model) {
    return PlaylistEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      isPublic: model.isPublic,
      coverArt: model.coverArt,
      songIds: model.songIds,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      songs: model.songs?.map((e) => SongMapper.fromModel(e)).toList(),
    );
  }

  static PlaylistModel toModel(PlaylistEntity entity) {
    return PlaylistModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      isPublic: entity.isPublic,
      coverArt: entity.coverArt,
      songIds: entity.songIds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      songs: entity.songs?.map((e) => SongMapper.toModel(e)).toList(),
    );
  }
}
