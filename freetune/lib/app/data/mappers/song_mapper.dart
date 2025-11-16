import '../../domain/entities/song_entity.dart';
import '../models/song/song_model.dart';

class SongMapper {
  static SongEntity fromModel(SongModel model) {
    return SongEntity(
      id: model.id,
      title: model.title,
      artist: model.artist,
      album: model.album ?? '',
      albumArt: model.albumArt,
      duration: Duration(milliseconds: model.durationMs),
      audioUrl: '', // This will be fetched separately or passed
    );
  }

  static SongModel toModel(SongEntity entity) {
    return SongModel(
      id: entity.id,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      albumArt: entity.albumArt,
      durationMs: entity.duration.inMilliseconds,
    );
  }
}
