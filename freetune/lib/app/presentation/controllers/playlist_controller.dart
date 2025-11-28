import 'package:get/get.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../data/repositories/playlist_repository.dart';

class PlaylistController extends GetxController {
  final PlaylistRepository _playlistRepository;
  PlaylistController(this._playlistRepository);

  final playlists = <PlaylistEntity>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlaylists();
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

  // Other methods like add/remove song would follow the same pattern
}
