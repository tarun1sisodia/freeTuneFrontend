import 'package:dio/dio.dart';
import '../../models/playlist/playlist_model.dart';
import '../../../core/constants/api_endpoints.dart';

class PlaylistsApi {
  final Dio _dio;

  PlaylistsApi(this._dio);

  // GET /api/v1/playlists
  Future<List<PlaylistModel>> getPlaylists() async {
    final response = await _dio.get(ApiEndpoints.playlists);
    return (response.data['data'] as List)
        .map((json) => PlaylistModel.fromJson(json))
        .toList();
  }

  // POST /api/v1/playlists
  Future<PlaylistModel> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    final response = await _dio.post(ApiEndpoints.playlists, data: {
      'name': name,
      'description': description,
      'is_public': isPublic,
    });
    return PlaylistModel.fromJson(response.data['data']);
  }

  // GET /api/v1/playlists/:id
  Future<PlaylistModel> getPlaylistById(String id) async {
    final response = await _dio.get(ApiEndpoints.playlistById(id));
    return PlaylistModel.fromJson(response.data['data']);
  }

  // PATCH /api/v1/playlists/:id
  Future<PlaylistModel> updatePlaylist({
    required String id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final response = await _dio.patch(ApiEndpoints.playlistById(id), data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isPublic != null) 'is_public': isPublic,
    });
    return PlaylistModel.fromJson(response.data['data']);
  }

  // DELETE /api/v1/playlists/:id
  Future<void> deletePlaylist(String id) async {
    await _dio.delete(ApiEndpoints.playlistById(id));
  }

  // POST /api/v1/playlists/:id/songs
  Future<void> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    await _dio.post(ApiEndpoints.addSongToPlaylist(playlistId), data: {
      'song_id': songId,
    });
  }

  // DELETE /api/v1/playlists/:id/songs/:songId
  Future<void> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    await _dio.delete(
      ApiEndpoints.removeSongFromPlaylist(playlistId, songId),
    );
  }
}
