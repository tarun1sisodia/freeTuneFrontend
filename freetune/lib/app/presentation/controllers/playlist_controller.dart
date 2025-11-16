import 'package:get/get.dart';
import '../../data/models/playlist/playlist_model.dart';
import '../../data/repositories/playlist_repository.dart';

class PlaylistController extends GetxController {
  final PlaylistRepository _playlistRepository;
  PlaylistController(this._playlistRepository);

  final playlists = <PlaylistModel>[].obs;
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
    String? description,
    bool isPublic = false,
  }) async {
    try {
      await _playlistRepository.createPlaylist(
          name: name, description: description, isPublic: isPublic);
      fetchPlaylists(); // Refresh the list after creating
    } catch (e) {
      Get.snackbar('Error', 'Could not create playlist.');
    }
  }

  Future<void> deletePlaylist(String id) async {
    try {
      await _playlistRepository.deletePlaylist(id);
      fetchPlaylists(); // Refresh the list
    } catch (e) {
      Get.snackbar('Error', 'Could not delete playlist.');
    }
  }

  // Other methods like add/remove song would follow the same pattern
}