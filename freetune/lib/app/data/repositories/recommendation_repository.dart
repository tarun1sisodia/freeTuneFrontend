import '../datasources/remote/recommendations_api.dart';
import '../../core/exceptions/api_exception.dart';
import '../../domain/entities/song_entity.dart';
import '../mappers/song_mapper.dart';

class RecommendationRepository {
  final RecommendationsApi _recommendationsApi;

  RecommendationRepository(this._recommendationsApi);

  Future<List<SongEntity>> getRecommendations({
    String? genre,
    String? mood,
    int limit = 20,
  }) async {
    try {
      final songModels = await _recommendationsApi.getRecommendations(
        genre: genre,
        mood: mood,
        limit: limit,
      );
      return songModels.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SongEntity>> getSimilarSongs({
    required String songId,
    int limit = 20,
  }) async {
    try {
      final songModels = await _recommendationsApi.getSimilarSongs(
        songId: songId,
        limit: limit,
      );
      return songModels.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SongEntity>> getTrendingRecommendations({int limit = 20}) async {
    try {
      final songModels = await _recommendationsApi.getTrendingRecommendations(limit: limit);
      return songModels.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<SongEntity>> getUserTopSongsRecommendations({int limit = 20}) async {
    try {
      final songModels = await _recommendationsApi.getUserTopSongsRecommendations(limit: limit);
      return songModels.map((e) => SongMapper.fromModel(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
