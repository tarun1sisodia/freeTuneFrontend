import 'package:get/get.dart';
import '../presentation/controllers/songs_controller.dart';
import '../presentation/controllers/playlist_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SongController>(() => SongController(Get.find()));
    Get.lazyPut<PlaylistController>(() => PlaylistController(Get.find()));
  }
}
