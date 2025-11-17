import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/utils/logger.dart';
import '../../models/playlist/playlist_model.dart';

/// Production-grade Playlists API client
class PlaylistsApi {
  final Dio _dio;

  PlaylistsApi(this._dio);

  /// Get all user playlists
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      logger.i('Fetching user playlists');
      final response = await _dio.get(ApiEndpoints.playlists);
      
      final playlists = (response.data['data'] as List)
          .map((json) => PlaylistModel.fromJson(json))
          .toList();
      
      logger.d('Playlists fetched: ${playlists.length} playlists');
      return playlists;
    } on DioException catch (e) {
      logger.e('Failed to get playlists: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting playlists: $e');
      throw ApiException(message: 'Failed to get playlists: $e');
    }
  }

  /// Get single playlist by ID
  Future<PlaylistModel> getPlaylistById(String id) async {
    try {
      logger.i('Fetching playlist by ID: $id');
      final response = await _dio.get(
        ApiEndpoints.getPlaylist.replaceFirst('{id}', id),
      );
      
      logger.d('Playlist fetched: ${response.data['data']['name']}');
      return PlaylistModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      logger.e('Failed to get playlist $id: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error getting playlist: $e');
      throw ApiException(message: 'Failed to get playlist: $e');
    }
  }

  /// Create new playlist
  Future<PlaylistModel> createPlaylist(String name, List<String> songIds) async {
    try {
      logger.i('Creating playlist: $name');
      final response = await _dio.post(
        ApiEndpoints.playlists,
        data: {'name': name, 'songIds': songIds},
      );
      
      logger.d('Playlist created successfully');
      return PlaylistModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      logger.e('Failed to create playlist: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error creating playlist: $e');
      throw ApiException(message: 'Failed to create playlist: $e');
    }
  }

  /// Update playlist
  Future<PlaylistModel> updatePlaylist(
    String id, {
    String? name,
    List<String>? songIds,
  }) async {
    try {
      logger.i('Updating playlist: $id');
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (songIds != null) data['songIds'] = songIds;

      final response = await _dio.put(
        ApiEndpoints.updatePlaylist.replaceFirst('{id}', id),
        data: data,
      );
      
      logger.d('Playlist updated successfully');
      return PlaylistModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      logger.e('Failed to update playlist: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error updating playlist: $e');
      throw ApiException(message: 'Failed to update playlist: $e');
    }
  }

  /// Delete playlist
  Future<void> deletePlaylist(String id) async {
    try {
      logger.i('Deleting playlist: $id');
      await _dio.delete(
        ApiEndpoints.deletePlaylist.replaceFirst('{id}', id),
      );
      logger.d('Playlist deleted successfully');
    } on DioException catch (e) {
      logger.e('Failed to delete playlist: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error deleting playlist: $e');
      throw ApiException(message: 'Failed to delete playlist: $e');
    }
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      logger.i('Adding song $songId to playlist $playlistId');
      await _dio.post(
        ApiEndpoints.addToPlaylist
            .replaceFirst('{playlistId}', playlistId)
            .replaceFirst('{songId}', songId),
      );
      logger.d('Song added to playlist successfully');
    } on DioException catch (e) {
      logger.e('Failed to add song to playlist: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error adding song to playlist: $e');
      throw ApiException(message: 'Failed to add song to playlist: $e');
    }
  }

  /// Remove song from playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      logger.i('Removing song $songId from playlist $playlistId');
      await _dio.delete(
        ApiEndpoints.removeFromPlaylist
            .replaceFirst('{playlistId}', playlistId)
            .replaceFirst('{songId}', songId),
      );
      logger.d('Song removed from playlist successfully');
    } on DioException catch (e) {
      logger.e('Failed to remove song from playlist: ${e.message}');
      throw ApiException.fromDioError(e);
    } catch (e) {
      logger.e('Unexpected error removing song from playlist: $e');
      throw ApiException(message: 'Failed to remove song from playlist: $e');
    }
  }
}
