import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/song_repository.dart';
import '../../domain/entities/song_entity.dart';

class AudioPlayerService extends GetxService {
  final AudioPlayer _player = AudioPlayer();
  final SongRepository _songRepository;
  final AnalyticsRepository _analyticsRepository;

  final Rx<SongEntity?> currentSong = Rx<SongEntity?>(null);
  final RxBool playing = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration?> duration = Rx<Duration?>(null);

  List<SongEntity> _queue = [];
  int _currentIndex = 0;

  AudioPlayerService(this._songRepository, this._analyticsRepository) {
    _initAudioSession();
    _initListeners();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _initListeners() {
    _player.playerStateStream.listen((state) {
      playing.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (currentSong.value != null) {
          _analyticsRepository.trackListening(
              songId: currentSong.value!.id, action: 'complete');
        }
        playNext();
      }
    });

    _player.positionStream.listen((p) {
      position.value = p;
      _trackPlaybackProgress(p);
    });
    _player.durationStream.listen((d) => duration.value = d);
  }

  void setQueue(List<SongEntity> queue, {int startIndex = 0}) {
    _queue = queue;
    _currentIndex = startIndex;
  }

  Future<void> play(SongEntity song) async {
    currentSong.value = song;
    try {
      final streamUrlResponse = await _songRepository.getStreamUrl(
          song.id, quality: 'high'); // Default to high quality
      await _player.setUrl(streamUrlResponse.url);
      await _player.play();
      _analyticsRepository.trackListening(songId: song.id, action: 'play');
    } catch (e) {
      // Handle error, e.g., show a snackbar
      Get.snackbar('Playback Error', 'Could not play song: ${song.title}');
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void playNext() {
    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      play(_queue[_currentIndex]);
    } else {
      // End of playlist, stop or loop
      _player.stop();
      currentSong.value = null;
    }
  }

  void playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      play(_queue[_currentIndex]);
    } else {
      // Beginning of playlist, restart current song or do nothing
      seek(Duration.zero);
    }
  }

  void _trackPlaybackProgress(Duration currentPosition) {
    if (currentSong.value == null || duration.value == null) return;

    // Batch send updates (e.g., every 30s) to avoid spamming the API
    if (currentPosition.inSeconds > 0 && currentPosition.inSeconds % 30 == 0) {
      _analyticsRepository.trackListening(
        songId: currentSong.value!.id,
        action: 'progress',
        positionMs: currentPosition.inMilliseconds,
        durationMs: duration.value!.inMilliseconds,
      );
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
