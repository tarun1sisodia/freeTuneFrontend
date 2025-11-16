import 'package:get/get.dart';
import '../../domain/entities/song_entity.dart';
import '../../services/audio/audio_player_service.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayerService _audioPlayerService = Get.find();

  Rx<SongEntity?> get currentSong => _audioPlayerService.currentSong;
  RxBool get isPlaying => _audioPlayerService.playing;
  Rx<Duration> get position => _audioPlayerService.position;
  Rx<Duration?> get duration => _audioPlayerService.duration;

  void play(SongEntity song, List<SongEntity> queue) {
    _audioPlayerService.setQueue(queue, startIndex: queue.indexOf(song));
    _audioPlayerService.play(song);
  }

  void pause() {
    _audioPlayerService.pause();
  }

  void resume() {
    _audioPlayerService.resume();
  }

  void seek(Duration position) {
    _audioPlayerService.seek(position);
  }

  void playNext() {
    _audioPlayerService.playNext();
  }

  void playPrevious() {
    _audioPlayerService.playPrevious();
  }
}
