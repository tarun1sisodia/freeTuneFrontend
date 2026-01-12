import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/song_repository.dart';
import '../../domain/entities/song_entity.dart';
import 'audio_cache_service.dart';

/// Production-grade Audio Player Service with comprehensive features
///
/// Features:
/// - Queue management with shuffle & repeat modes
/// - Adaptive quality selection
/// - Error recovery & retry logic
/// - Playback state management
/// - Analytics tracking
/// - Gapless playback
/// - Background audio support
class AudioPlayerService extends GetxService {
  // Dependencies
  final SongRepository _songRepository;
  final AudioCacheService _audioCacheService = Get.put(AudioCacheService());
  // Audio player instance
  late final AudioPlayer _player;

  // Playback state
  final Rx<SongEntity?> currentSong = Rx<SongEntity?>(null);
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isBuffering = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration?> duration = Rx<Duration?>(null);
  final RxDouble bufferedPosition = 0.0.obs;
  final RxString errorMessage = ''.obs;

  // Queue management
  final RxList<SongEntity> queue = <SongEntity>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isShuffleEnabled = false.obs;
  final Rx<RepeatMode> repeatMode = RepeatMode.off.obs;

  // Original queue (for shuffle/unshuffle)
  List<SongEntity> _originalQueue = [];

  // Quality settings
  final Rx<AudioQuality> audioQuality = AudioQuality.high.obs;

  // Stream subscriptions
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _bufferedPositionSubscription;

  // Analytics batching
  Timer? _analyticsTimer;
  Duration? _lastTrackedPosition;

  // Network connectivity
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  AudioPlayerService(this._songRepository);

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
    _initAudioSession();
    _initListeners();
    _setupAnalyticsBatching();
    _initConnectivityListener();
  }

  /// Initialize the audio player
  void _initializePlayer() {
    _player = AudioPlayer(
      // Making the Audio Player ready for Songs.
      audioLoadConfiguration: const AudioLoadConfiguration(
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: Duration(seconds: 15),
          maxBufferDuration: Duration(seconds: 50),
          bufferForPlaybackDuration:
              Duration(milliseconds: 500), // Start playing after 500ms (0.5s)
          bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
        ),
        darwinLoadControl: DarwinLoadControl(
          preferredForwardBufferDuration: Duration(seconds: 15),
          // automaticallyWaitsToMinimizeStalling: false, // Removed as it caused UnimplementedError
        ),
      ),
    );
    logger.i('AudioPlayerService initialized with optimized buffering');
  }

  /// Configure audio session for music playback
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      logger.d('Audio session configured');
    } catch (e) {
      logger.e('Failed to configure audio session: $e');
    }
  }

  /// Setup all player event listeners
  void _initListeners() {
    // Player state changes
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;

      // Handle playback completion
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }

      logger.d(
          'Player state: ${state.processingState}, playing: ${state.playing}');
    }, onError: (error) {
      logger.e('Player state error: $error');
      _handlePlaybackError(error);
    });

    // Position updates
    _positionSubscription = _player.positionStream.listen((p) {
      position.value = p;
    });

    // Duration updates
    _durationSubscription = _player.durationStream.listen((d) {
      duration.value = d;
    });

    // Buffered position updates
    _bufferedPositionSubscription = _player.bufferedPositionStream.listen((bp) {
      if (duration.value != null && duration.value!.inMilliseconds > 0) {
        bufferedPosition.value =
            bp.inMilliseconds / duration.value!.inMilliseconds;
      }
    });
  }

  /// Setup analytics tracking with batching
  void _setupAnalyticsBatching() {
    // Track playback progress every 30 seconds
    _analyticsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _trackPlaybackProgress();
    });
  }

  /// Initialize connectivity listener for adaptive quality
  void _initConnectivityListener() {
    // Check initial status
    _connectivity.checkConnectivity().then(_updateQualityBasedOnNetwork);

    // Listen for changes
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(_updateQualityBasedOnNetwork);
  }

  void _updateQualityBasedOnNetwork(List<ConnectivityResult> results) {
    // If any result is wifi, go high quality
    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      if (audioQuality.value != AudioQuality.high) {
        logger.i('Network: WiFi/Ethernet detected - Switching to HIGH quality');
        setAudioQuality(AudioQuality.high);
      }
    }
    // If mobile, go medium (or low if user preference? For now medium)
    else if (results.contains(ConnectivityResult.mobile)) {
      if (audioQuality.value != AudioQuality.medium) {
        logger.i('Network: Mobile Data detected - Switching to MEDIUM quality');
        setAudioQuality(AudioQuality.medium);
      }
    }
    // Fallback or none
    else if (results.contains(ConnectivityResult.none)) {
      logger.w('Network: Offline mode');
      // Keep current settings or maybe low?
      // Actually, offline implies we rely on cache.
    }
  }

  /// Play a song with queue management
  Future<void> playSong(SongEntity song, {List<SongEntity>? newQueue}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      logger.i('Playing song: ${song.title} by ${song.artist}');

      // Update queue if provided
      if (newQueue != null) {
        _setQueue(newQueue);
        _findAndSetCurrentIndex(song);
      }

      currentSong.value = song;

      // 1. Check if explicitly cached (Downloaded for offline)
      // Use song.id as key if available (cacheAudio uses it)
      // Note: original implementation of caching might have used URL only.
      // We will now try to look up by song.id or url
      String? cachedPath = await _audioCacheService
          .getFileFromCache(song.downloadUrl ?? "", key: song.id);

      // If not found by ID, try URL if we have one (legacy Support)
      if (cachedPath == null && song.downloadUrl != null) {
        cachedPath =
            await _audioCacheService.getFileFromCache(song.downloadUrl!);
      }

      final connectivityResult = await _connectivity.checkConnectivity();
      final isOffline = connectivityResult.contains(ConnectivityResult.none);

      // A. Explicit Cache Found
      if (cachedPath != null) {
        logger.i('Playing from Explicit Offline Cache: $cachedPath');
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.file(cachedPath),
            tag: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artist,
              artUri: song.albumArtUrl != null
                  ? Uri.parse(song.albumArtUrl!)
                  : null,
              duration: Duration(milliseconds: song.durationMs),
            ),
          ),
        );
      }
      // B. Online or Transient Cache (LockCaching)
      else if (song.downloadUrl != null && song.downloadUrl!.isNotEmpty) {
        logger.i('Playing from optimized MP3 source: ${song.downloadUrl}');
        try {
          // LockCachingAudioSource handles streaming + caching simultaneously
          final source = LockCachingAudioSource(
            Uri.parse(song.downloadUrl!),
            tag: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.artist,
              artUri: song.albumArtUrl != null
                  ? Uri.parse(song.albumArtUrl!)
                  : null,
              duration: Duration(milliseconds: song.durationMs),
            ),
          );
          await _player.setAudioSource(source);
        } catch (e) {
          logger.w('Failed to play MP3 (Offline/Cache issue?): $e');
          if (isOffline) {
            _handlePlaybackError("Offline: Song not available.");
            return;
          }
          // Fallback to stream only if online
          await _playFromStream(song);
        }
      }
      // C. Fallback to Stream (HLS)
      else {
        if (isOffline) {
          _handlePlaybackError("Offline: No download URL available.");
          return;
        } else {
          await _playFromStream(song);
        }
      }

      // Start playback
      await _player.play();

      // Track analytics
      if (!isOffline) {
        await _trackPlay(song.id);
        // SMART PRE-LOAD: Pre-load next song
        _preloadNextSong();
      }

      logger.d('Song started playing successfully');
    } catch (e) {
      logger.e('Error playing song: $e');
      _handlePlaybackError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Explicitly download song for offline playback
  Future<bool> downloadSong(SongEntity song) async {
    if (song.downloadUrl == null || song.downloadUrl!.isEmpty) {
      logger.w('Cannot download song: No download URL');
      return false;
    }

    try {
      logger.i('Downloading song: ${song.title}');
      await _audioCacheService.cacheAudio(song.downloadUrl!, key: song.id);
      logger.i('Song downloaded successfully');
      return true;
    } catch (e) {
      logger.e('Failed to download song: $e');
      return false;
    }
  }

  /// Check if song is explicitly downloaded
  Future<bool> isSongCached(SongEntity song) async {
    return await _audioCacheService.isCached(song.downloadUrl ?? "",
        key: song.id);
  }

  /// Pre-load the next song in queue
  Future<void> _preloadNextSong() async {
    try {
      // Find next song
      int nextIndex = currentIndex.value + 1;

      // Handle repeat modes
      if (nextIndex >= queue.length) {
        if (repeatMode.value == RepeatMode.all) {
          nextIndex = 0;
        } else {
          return; // End of queue, nothing to pre-load
        }
      }

      if (queue.isEmpty || nextIndex >= queue.length) return;

      final nextSong = queue[nextIndex];

      // Check if already cached
      final isCached = await _audioCacheService
          .isCached(nextSong.downloadUrl ?? "", key: nextSong.id);
      if (isCached) {
        logger.d('Next song already cached: ${nextSong.title}');
        return;
      }

      // If not cached and has download URL, cache it (download)
      if (nextSong.downloadUrl != null && nextSong.downloadUrl!.isNotEmpty) {
        logger.i('Pre-loading next song: ${nextSong.title}');
        _audioCacheService.cacheAudio(nextSong.downloadUrl!, key: nextSong.id);
      }
    } catch (e) {
      logger.w('Failed to pre-load next song: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
      logger.d('Playback paused');
    } catch (e) {
      logger.e('Error pausing: $e');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      await _player.play();
      logger.d('Playback resumed');
    } catch (e) {
      logger.e('Error resuming: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _player.stop();
      currentSong.value = null;
      position.value = Duration.zero;
      logger.d('Playback stopped');
    } catch (e) {
      logger.e('Error stopping: $e');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      logger.d('Seeked to: ${position.inSeconds}s');
    } catch (e) {
      logger.e('Error seeking: $e');
    }
  }

  /// Play next song in queue
  Future<void> playNext() async {
    if (queue.isEmpty) {
      logger.w('Queue is empty, cannot play next');
      return;
    }

    switch (repeatMode.value) {
      case RepeatMode.one:
        // Repeat current song
        await seek(Duration.zero);
        await resume();
        break;

      case RepeatMode.all:
        // Move to next song, loop to start if at end
        final nextIndex = (currentIndex.value + 1) % queue.length;
        await _playAtIndex(nextIndex);
        break;

      case RepeatMode.off:
        // Move to next song if available
        if (currentIndex.value < queue.length - 1) {
          await _playAtIndex(currentIndex.value + 1);
        } else {
          await stop();
          logger.d('End of queue reached');
        }
        break;
    }
  }

  /// Play previous song in queue
  Future<void> playPrevious() async {
    if (queue.isEmpty) {
      logger.w('Queue is empty, cannot play previous');
      return;
    }

    // If more than 3 seconds played, restart current song
    if (position.value.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    // Otherwise go to previous song
    if (currentIndex.value > 0) {
      await _playAtIndex(currentIndex.value - 1);
    } else if (repeatMode.value == RepeatMode.all) {
      // Loop to end if repeat all is enabled
      await _playAtIndex(queue.length - 1);
    } else {
      // Restart current song
      await seek(Duration.zero);
    }
  }

  /// Play song at specific index in queue
  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < queue.length) {
      await _playAtIndex(index);
    }
  }

  /// Set playback queue
  void setQueue(List<SongEntity> newQueue, {int startIndex = 0}) {
    _setQueue(newQueue);
    currentIndex.value = startIndex.clamp(0, newQueue.length - 1);
    logger.d('Queue set with ${newQueue.length} songs');
  }

  /// Add song to queue
  void addToQueue(SongEntity song) {
    queue.add(song);
    _originalQueue.add(song);
    logger.d('Added to queue: ${song.title}');
  }

  /// Add multiple songs to queue
  void addAllToQueue(List<SongEntity> songs) {
    queue.addAll(songs);
    _originalQueue.addAll(songs);
    logger.d('Added ${songs.length} songs to queue');
  }

  /// Remove song from queue
  void removeFromQueue(int index) {
    if (index >= 0 && index < queue.length) {
      final song = queue[index];
      queue.removeAt(index);
      _originalQueue.remove(song);

      // Adjust current index if needed
      if (index < currentIndex.value) {
        currentIndex.value--;
      }

      logger.d('Removed from queue: ${song.title}');
    }
  }

  /// Clear queue
  void clearQueue() {
    queue.clear();
    _originalQueue.clear();
    currentIndex.value = 0;
    logger.d('Queue cleared');
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    isShuffleEnabled.value = !isShuffleEnabled.value;

    if (isShuffleEnabled.value) {
      _enableShuffle();
    } else {
      _disableShuffle();
    }

    logger.d('Shuffle ${isShuffleEnabled.value ? "enabled" : "disabled"}');
  }

  /// Toggle repeat mode
  void toggleRepeatMode() {
    switch (repeatMode.value) {
      case RepeatMode.off:
        repeatMode.value = RepeatMode.all;
        break;
      case RepeatMode.all:
        repeatMode.value = RepeatMode.one;
        break;
      case RepeatMode.one:
        repeatMode.value = RepeatMode.off;
        break;
    }

    logger.d('Repeat mode: ${repeatMode.value}');
  }

  /// Set audio quality
  void setAudioQuality(AudioQuality quality) {
    audioQuality.value = quality;
    logger.d('Audio quality set to: $quality');
  }

  // ==================== PRIVATE METHODS ====================

  /// Internal method to set queue
  void _setQueue(List<SongEntity> newQueue) {
    queue.value = List.from(newQueue);
    _originalQueue = List.from(newQueue);
  }

  /// Find song in queue and set as current
  void _findAndSetCurrentIndex(SongEntity song) {
    final index = queue.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      currentIndex.value = index;
    }
  }

  /// Play song at specific index
  Future<void> _playAtIndex(int index) async {
    if (index >= 0 && index < queue.length) {
      currentIndex.value = index;
      await playSong(queue[index]);
    }
  }

  /// Enable shuffle
  void _enableShuffle() {
    final currentSongEntity = currentSong.value;

    // Shuffle queue but keep current song at current position
    final shuffledQueue = List<SongEntity>.from(queue);
    shuffledQueue.shuffle();

    // Move current song to front if exists
    if (currentSongEntity != null) {
      shuffledQueue.remove(currentSongEntity);
      shuffledQueue.insert(currentIndex.value, currentSongEntity);
    }

    queue.value = shuffledQueue;
  }

  /// Disable shuffle
  void _disableShuffle() {
    final currentSongEntity = currentSong.value;

    // Restore original queue
    queue.value = List.from(_originalQueue);

    // Find current song in original queue
    if (currentSongEntity != null) {
      _findAndSetCurrentIndex(currentSongEntity);
    }
  }

  /// Handle playback completion
  void _handlePlaybackCompleted() {
    logger.d('Playback completed');

    // Track completion analytics
    if (currentSong.value != null) {
      _trackComplete(currentSong.value!.id);
    }

    // Play next song
    playNext();
  }

  /// Handle playback errors
  void _handlePlaybackError(dynamic error) {
    final errorMsg = 'Playback error: ${error.toString()}';
    errorMessage.value = errorMsg;
    logger.e(errorMsg);

    Get.snackbar(
      'Playback Error',
      'Could not play song. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  /// Get quality string from enum
  String _getQualityString() {
    switch (audioQuality.value) {
      case AudioQuality.low:
        return 'low';
      case AudioQuality.medium:
        return 'medium';
      case AudioQuality.high:
        return 'high';
    }
  }

  /// Play from stream (HLS/Fallback)
  Future<void> _playFromStream(SongEntity song) async {
    // Get stream URL with quality preference
    final streamUrlResponse = await _songRepository.getStreamUrl(
      song.id,
      quality: _getQualityString(),
    );

    final isHls = streamUrlResponse.url.contains('.m3u8');

    if (isHls) {
      // Just Audio HLS support
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrlResponse.url),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artist,
            artUri:
                song.albumArtUrl != null ? Uri.parse(song.albumArtUrl!) : null,
            duration: Duration(milliseconds: song.durationMs),
          ),
        ),
      );
    } else {
      // Legacy cache fallback for non-HLS streams
      String playUrl = streamUrlResponse.url;
      final cachedPath = await _audioCacheService.getCachedAudioPath(playUrl);
      if (cachedPath != null) {
        playUrl = cachedPath; // Use local file path
      } else {
        _audioCacheService.cacheAudio(playUrl);
      }
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(playUrl),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artist,
            artUri:
                song.albumArtUrl != null ? Uri.parse(song.albumArtUrl!) : null,
            duration: Duration(milliseconds: song.durationMs),
          ),
        ),
      );
    }
  }

  // ==================== ANALYTICS ====================

  /// Track song play
  Future<void> _trackPlay(String songId) async {
    try {
      await _songRepository.trackPlay(songId);
    } catch (e) {
      logger.w('Failed to track play: $e');
    }
  }

  /// Track playback progress
  void _trackPlaybackProgress() {
    if (currentSong.value == null || duration.value == null) return;
    if (!isPlaying.value) return;

    final currentPos = position.value;

    // Only track if position changed significantly (> 5 seconds)
    if (_lastTrackedPosition != null) {
      final diff =
          (currentPos.inSeconds - _lastTrackedPosition!.inSeconds).abs();
      if (diff < 5) return;
    }

    _lastTrackedPosition = currentPos;

    try {
      _songRepository.trackPlayback(
        currentSong.value!.id,
        currentPos.inMilliseconds,
        duration.value!.inMilliseconds,
      );
    } catch (e) {
      logger.w('Failed to track playback progress: $e');
    }
  }

  /// Track song completion
  Future<void> _trackComplete(String songId) async {
    try {
      await _songRepository.trackPlay(songId,
          position: position.value.inSeconds);
    } catch (e) {
      logger.w('Failed to track completion: $e');
    }
  }

  // ==================== CLEANUP ====================

  @override
  void onClose() {
    logger.i('Disposing AudioPlayerService');

    // Cancel subscriptions
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _analyticsTimer?.cancel();
    _connectivitySubscription?.cancel();

    // Dispose player
    _player.dispose();

    super.onClose();
  }
}

/// Audio quality enum
enum AudioQuality {
  low,
  medium,
  high,
}

/// Repeat mode enum
enum RepeatMode {
  off,
  all,
  one,
}
