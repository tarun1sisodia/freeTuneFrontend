import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/song/song_model.dart';

class RecommendationsApi {
  final Dio _dio;

  RecommendationsApi(this._dio);

  Future<List<SongModel>> getRecommendations({String? userId}) async {
    final response = await _dio.get(
      ApiEndpoints.recommendations,
      queryParameters: userId != null ? {'userId': userId} : null,
    );
    return (response.data as List).map((e) => SongModel.fromJson(e)).toList();
  }

  Future<List<SongModel>> getSimilarSongs(String songId) async {
    final response = await _dio.get(
      '${ApiEndpoints.recommendations}/similar/$songId',
    );
    return (response.data as List).map((e) => SongModel.fromJson(e)).toList();
  }
}