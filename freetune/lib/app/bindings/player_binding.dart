import 'package:get/get.dart';
import '../presentation/controllers/audio_player_controller.dart';

class PlayerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AudioPlayerController>(() => AudioPlayerController());
  }
}
