import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/repositories/song_repository.dart';
import '../../data/repositories/analytics_repository.dart'; // Import analytics
import '../../domain/entities/song_entity.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final SongRepository _songRepository;
  final AnalyticsRepository _analyticsRepository; // Inject analytics repo

  // Reactive properties managed by the service, exposed to the controller
  final Rx<SongEntity?> currentSong = Rx<SongEntity?>(null);
  final RxBool playing = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration?> duration = Rx<Duration?>(null);

  // Private state
  List<SongEntity> _queue = [];
  int _currentIndex = 0;

  AudioPlayerService(this._songRepository, this._analyticsRepository) {
    _initListeners();
  }

  void _initListeners() {
    // Listen to player state
    _player.playerStateStream.listen((state) {
      playing.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        // Track completion event
        if (currentSong.value != null) {
          _analyticsRepository.trackListening(songId: currentSong.value!.id, action: 'complete');
        }
        playNext();
      }
    });

    // Listen to streams for UI updates
    _player.positionStream.listen((p) {
      position.value = p;
      _trackPlaybackProgress(p); // Track progress
    });
    _player.durationStream.listen((d) => duration.value = d);
  }
  
  Future<void> play(SongEntity song) async {
    currentSong.value = song;
    // ... (Get stream URL, set URL, etc.)
    // Placeholder for streamUrl retrieval
    final streamUrlResponse = await _songRepository.getStreamUrl(song.id);
    final streamUrl = streamUrlResponse.url;

    await _player.setUrl(streamUrl);
    await _player.play();

    // Track play event via Analytics API
    await _analyticsRepository.trackListening(songId: song.id, action: 'play');
  }
  
  // Track playback and send to backend analytics every 30 seconds
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

  void pause() => _player.pause();
  void resume() => _player.play();
  void seek(Duration position) => _player.seek(position);

  void setQueue(List<SongEntity> queue, {int startIndex = 0}) {
    _queue = queue;
    _currentIndex = startIndex;
  }

  void playNext() {
    if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
      _currentIndex++;
      play(_queue[_currentIndex]);
    } else if (_queue.isNotEmpty) {
      // Loop back to the beginning if at the end
      _currentIndex = 0;
      play(_queue[_currentIndex]);
    }
  }

  void playPrevious() {
    if (_queue.isNotEmpty && _currentIndex > 0) {
      _currentIndex--;
      play(_queue[_currentIndex]);
    } else if (_queue.isNotEmpty) {
      // Loop to the end if at the beginning
      _currentIndex = _queue.length - 1;
      play(_queue[_currentIndex]);
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
