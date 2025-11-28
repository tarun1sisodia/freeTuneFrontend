import 'package:get/get.dart';
import '../presentation/controllers/song_search_controller.dart';
import '../data/repositories/song_repository.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SongSearchController>(
      () => SongSearchController(Get.find<SongRepository>()),
    );
  }
}
