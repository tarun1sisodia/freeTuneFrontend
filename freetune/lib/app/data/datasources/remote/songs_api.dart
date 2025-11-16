import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/common/paginated_response.dart';
import '../../models/song/song_model.dart';
import '../../models/song/stream_url_response.dart';

class SongsApi {
  final Dio _dio;

  SongsApi(this._dio);

  Future<PaginatedResponse<SongModel>> getSongs({int page = 1, int limit = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.songs,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse.fromJson(response.data, SongModel.fromJson);
  }

  Future<PaginatedResponse<SongModel>> searchSongs(String query, {int page = 1, int limit = 10}) async {
    final response = await _dio.get(
      ApiEndpoints.searchSongs,
      queryParameters: {'q': query, 'page': page, 'limit': limit},
    );
    return PaginatedResponse.fromJson(response.data, SongModel.fromJson);
  }

  Future<StreamUrlResponse> getStreamUrl(String songId, String quality) async {
    final response = await _dio.get(
      ApiEndpoints.streamUrl.replaceFirst('{id}', songId),
      queryParameters: {'quality': quality},
    );
    return StreamUrlResponse.fromJson(response.data);
  }

  Future<void> trackPlay(String songId) async {
    await _dio.post(ApiEndpoints.trackPlay.replaceFirst('{id}', songId));
  }

  Future<void> trackPlayback(String songId, int positionMs, int durationMs) async {
    await _dio.post(
      ApiEndpoints.trackPlayback.replaceFirst('{id}', songId),
      data: {'positionMs': positionMs, 'durationMs': durationMs},
    );
  }
}