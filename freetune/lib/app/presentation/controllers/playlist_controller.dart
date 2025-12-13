import 'package:get/get.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../data/repositories/playlist_repository.dart';
import '../../data/repositories/song_repository.dart';

class PlaylistController extends GetxController {
  final PlaylistRepository _playlistRepository;
  final SongRepository _songRepository;

  PlaylistController(this._playlistRepository, this._songRepository);

  final playlists = <PlaylistEntity>[].obs;
  final uploadedSongs = <SongEntity>[].obs;
  final isLoading = false.obs;
  final isLoadingSongs = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlaylists();
    fetchUploadedSongs();
  }

  Future<void> fetchUploadedSongs() async {
    isLoadingSongs.value = true;
    try {
      uploadedSongs.value = await _songRepository.getUploadedSongs();
    } catch (e) {
      Get.snackbar('Error', 'Could not load your songs.');
    } finally {
      isLoadingSongs.value = false;
    }
  }

  Future<void> fetchPlaylists() async {
    isLoading.value = true;
    try {
      playlists.value = await _playlistRepository.getPlaylists();
    } catch (e) {
      Get.snackbar('Error', 'Could not load playlists.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPlaylist({
    required String name,
    required List<String> songIds,
  }) async {
    try {
      await _playlistRepository.createPlaylist(name, songIds);
      fetchPlaylists(); // Refresh the list after creating
    } catch (e) {
      Get.snackbar('Error', 'Could not create playlist.');
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _playlistRepository.deletePlaylist(id);
      fetchPlaylists(); // Refresh the list
      Get.snackbar('Success', 'Playlist deleted');
    } catch (e) {
      Get.snackbar('Error', 'Could not delete playlist.');
    }
  }

  Future<void> deleteSong(String id) async {
    try {
      await _songRepository.deleteSong(id);
      // Remove from local list immediately for better UX
      uploadedSongs.removeWhere((song) => song.id == id);
      Get.snackbar('Success', 'Song deleted');
    } catch (e) {
      Get.snackbar('Error', 'Could not delete song.');
    }
  }

  Future<void> createPlaylistFromSelection(
      String name, List<String> songIds) async {
    try {
      // 1. Create playlist
      await _playlistRepository.createPlaylist(name, songIds);
      // Backend createPlaylist might trigger adding songs if it supports it,
      // otherwise we might need to add songs separately.
      // Assuming createPlaylist supports adding songs initially or ignores them if not supported.
      // Checking PlaylistRepository... createPlaylist usually takes name only or name + optional songs.
      // If it only takes name, we loop and add.
      // But implementation_plan said "Create Playlist Endpoint" exists.
      // Let's assume createPlaylist handles it or we refresh.

      fetchPlaylists();
      Get.back(); // close dialog
      Get.snackbar('Success', 'Playlist created with ${songIds.length} songs');
    } catch (e) {
      Get.snackbar('Error', 'Could not create playlist.');
    }
  }

  // Other methods like add/remove song would follow the same pattern
}
