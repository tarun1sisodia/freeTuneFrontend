import 'package:get/get.dart';
import '../presentation/controllers/main_controller.dart';
import '../presentation/controllers/songs_controller.dart';
import '../presentation/controllers/audio_player_controller.dart';
import '../presentation/controllers/song_search_controller.dart';
import '../presentation/controllers/playlist_controller.dart';
import '../data/repositories/song_repository.dart';
import '../data/repositories/playlist_repository.dart';
// Note: We might want headers injected lazily or globally.

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories (Ensure they are found or put)
    // Note: SongRepository is likely in InitialBinding, but let's be safe or rely on Get.find()

    // Core Controllers for Tabs
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<SongController>(
        () => SongController(Get.find<SongRepository>()),
        fenix: true);
    Get.lazyPut<AudioPlayerController>(() => AudioPlayerController(),
        fenix: true);
    Get.lazyPut<SongSearchController>(
        () => SongSearchController(Get.find<SongRepository>()),
        fenix: true);
    Get.lazyPut<PlaylistController>(
        () => PlaylistController(
            Get.find<PlaylistRepository>(), Get.find<SongRepository>()),
        fenix: true);
  }
}
