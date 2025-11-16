import '../../domain/entities/song_entity.dart';
import '../datasources/remote/recommendations_api.dart';
import '../mappers/song_mapper.dart';

abstract class RecommendationRepository {
  Future<List<SongEntity>> getRecommendations({String? userId});
  Future<List<SongEntity>> getSimilarSongs(String songId);
}

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationsApi _recommendationsApi;

  RecommendationRepositoryImpl(this._recommendationsApi);

  @override
  Future<List<SongEntity>> getRecommendations({String? userId}) async {
    final songModels = await _recommendationsApi.getRecommendations(userId: userId);
    return songModels.map((model) => SongMapper.fromModel(model)).toList();
  }

  @override
  Future<List<SongEntity>> getSimilarSongs(String songId) async {
    final songModels = await _recommendationsApi.getSimilarSongs(songId);
    return songModels.map((model) => SongMapper.fromModel(model)).toList();
  }
}