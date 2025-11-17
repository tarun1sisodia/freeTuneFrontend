import '../../domain/entities/song_entity.dart';
import '../models/song/song_model.dart';
import '../models/song/file_size_model.dart';

class SongMapper {
  static SongEntity fromModel(SongModel model) {
    return SongEntity(
      id: model.songId,
      title: model.title,
      artist: model.artist,
      album: model.album,
      albumArtUrl: model.albumArtUrl,
      durationMs: model.durationMs,
      r2Key: model.r2Key,
      fileSizes: {for (var fs in model.fileSizes) fs.quality: fs.size},
      playCount: model.playCount,
      lastUpdated: model.lastUpdated,
      popularityScore: model.popularityScore,
      createdAt: model.createdAt,
      isFavorite: model.isFavorite,
      isPopular: model.isPopular,
    );
  }

  static SongModel toModel(SongEntity entity) {
    return SongModel(
      songId: entity.id,
      title: entity.title,
      artist: entity.artist,
      album: entity.album,
      albumArtUrl: entity.albumArtUrl,
      durationMs: entity.durationMs,
      r2Key: entity.r2Key,
      fileSizes: entity.fileSizes.entries
          .map((e) => FileSize()
            ..quality = e.key
            ..size = e.value)
          .toList(),
      playCount: entity.playCount,
      lastUpdated: entity.lastUpdated,
      popularityScore: entity.popularityScore,
      createdAt: entity.createdAt,
      isFavorite: entity.isFavorite,
      isPopular: entity.isPopular,
    );
  }
}