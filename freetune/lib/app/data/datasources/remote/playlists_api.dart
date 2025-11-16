import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/playlist/playlist_model.dart';

class PlaylistsApi {
  final Dio _dio;

  PlaylistsApi(this._dio);

  Future<List<PlaylistModel>> getPlaylists() async {
    final response = await _dio.get(ApiEndpoints.playlists);
    return (response.data as List).map((e) => PlaylistModel.fromJson(e)).toList();
  }

  Future<PlaylistModel> createPlaylist(String name, List<String> songIds) async {
    final response = await _dio.post(
      ApiEndpoints.playlists,
      data: {'name': name, 'songIds': songIds},
    );
    return PlaylistModel.fromJson(response.data);
  }
}