import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/song_entity.dart';
import '../../services/audio/audio_player_service.dart';
import 'songs_controller.dart';

/// Production-grade Audio Player Controller
///
/// This controller acts as a facade between the UI and AudioPlayerService,
/// providing a clean interface for audio playback operations.
class AudioPlayerController extends GetxController {
  // Service dependency
  late final AudioPlayerService _audioService;

  // ==================== GETTERS (Exposed State) ====================

  /// Current playing song
  Rx<SongEntity?> get currentSong => _audioService.currentSong;

  /// Is currently playing
  RxBool get isPlaying => _audioService.isPlaying;

  /// Is loading (buffering/preparing)
  RxBool get isLoading => _audioService.isLoading;

  /// Is buffering
  RxBool get isBuffering => _audioService.isBuffering;

  /// Current playback position
  Rx<Duration> get position => _audioService.position;

  /// Total duration of current song
  Rx<Duration?> get duration => _audioService.duration;

  /// Buffered position (0.0 to 1.0)
  RxDouble get bufferedPosition => _audioService.bufferedPosition;

  /// Current playback queue
  RxList<SongEntity> get queue => _audioService.queue;

  /// Current song index in queue
  RxInt get currentIndex => _audioService.currentIndex;

  /// Is shuffle enabled
  RxBool get isShuffleEnabled => _audioService.isShuffleEnabled;

  /// Current repeat mode
  Rx<RepeatMode> get repeatMode => _audioService.repeatMode;

  /// Current audio quality
  Rx<AudioQuality> get audioQuality => _audioService.audioQuality;

  /// Error message
  RxString get errorMessage => _audioService.errorMessage;

  // ==================== COMPUTED PROPERTIES ====================

  /// Is there a song currently playing or paused
  bool get hasSong => currentSong.value != null;

  /// Can play next song
  bool get canPlayNext =>
      currentIndex.value < queue.length - 1 ||
      repeatMode.value == RepeatMode.all;

  /// Can play previous song
  bool get canPlayPrevious =>
      currentIndex.value > 0 || repeatMode.value == RepeatMode.all;

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    if (duration.value == null || duration.value!.inMilliseconds == 0) {
      return 0.0;
    }
    return position.value.inMilliseconds / duration.value!.inMilliseconds;
  }

  /// Formatted position string (e.g., "3:45")
  String get positionString => _formatDuration(position.value);

  /// Formatted duration string (e.g., "5:23")
  String get durationString => _formatDuration(duration.value ?? Duration.zero);

  /// Remaining time string (e.g., "-1:38")
  String get remainingString {
    if (duration.value == null) return '-0:00';
    final remaining = duration.value! - position.value;
    return '-${_formatDuration(remaining)}';
  }

  // ==================== LIFECYCLE ====================

  /// Is current song cached for offline
  final RxBool isCurrentSongCached = false.obs;

  @override
  void onInit() {
    super.onInit();
    _audioService = Get.find<AudioPlayerService>();
    logger.i('AudioPlayerController initialized');

    // Monitor current song changes to update cache status
    ever(currentSong, (_) => _checkCacheStatus());
  }

  @override
  void onClose() {
    logger.i('AudioPlayerController disposed');
    super.onClose();
  }

  /// Check cache status for current song
  Future<void> _checkCacheStatus() async {
    final song = currentSong.value;
    if (song == null) {
      isCurrentSongCached.value = false;
      return;
    }
    isCurrentSongCached.value = await _audioService.isSongCached(song);
  }

  // ==================== PLAYBACK CONTROLS ====================

  /// Play a song with optional queue
  Future<void> playSong(
    SongEntity song, {
    List<SongEntity>? queue,
  }) async {
    try {
      logger.i('Playing song: ${song.title}');
      await _audioService.playSong(song, newQueue: queue);

      // Refresh recently played list
      try {
        if (Get.isRegistered<SongController>()) {
          // Delay slightly to allow backend/service to register the play
          Future.delayed(const Duration(seconds: 2), () {
            Get.find<SongController>().fetchRecentlyPlayed();
          });
        }
      } catch (e) {
        logger.w('Failed to refresh recently played: $e');
      }
    } catch (e) {
      logger.e('Error in playSong: $e');
      _showError('Failed to play song');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    try {
      await _audioService.togglePlayPause();
    } catch (e) {
      logger.e('Error in togglePlayPause: $e');
      _showError('Failed to toggle playback');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioService.pause();
    } catch (e) {
      logger.e('Error in pause: $e');
      _showError('Failed to pause');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      await _audioService.resume();
    } catch (e) {
      logger.e('Error in resume: $e');
      _showError('Failed to resume');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioService.stop();
    } catch (e) {
      logger.e('Error in stop: $e');
      _showError('Failed to stop');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (e) {
      logger.e('Error in seek: $e');
      _showError('Failed to seek');
    }
  }

  /// Seek to percentage (0.0 to 1.0)
  Future<void> seekToPercentage(double percentage) async {
    if (duration.value == null) return;
    final position = Duration(
      milliseconds: (duration.value!.inMilliseconds * percentage).round(),
    );
    await seek(position);
  }

  /// Skip forward by seconds
  Future<void> skipForward({int seconds = 10}) async {
    final newPosition = position.value + Duration(seconds: seconds);
    if (duration.value != null && newPosition < duration.value!) {
      await seek(newPosition);
    }
  }

  /// Skip backward by seconds
  Future<void> skipBackward({int seconds = 10}) async {
    final newPosition = position.value - Duration(seconds: seconds);
    if (newPosition > Duration.zero) {
      await seek(newPosition);
    } else {
      await seek(Duration.zero);
    }
  }

  // ==================== QUEUE MANAGEMENT ====================

  /// Play next song in queue
  Future<void> playNext() async {
    try {
      if (!canPlayNext && repeatMode.value == RepeatMode.off) {
        logger.w('Cannot play next - at end of queue');
        _showInfo('End of queue');
        return;
      }
      await _audioService.playNext();
    } catch (e) {
      logger.e('Error in playNext: $e');
      _showError('Failed to play next');
    }
  }

  /// Play previous song in queue
  Future<void> playPrevious() async {
    try {
      await _audioService.playPrevious();
    } catch (e) {
      logger.e('Error in playPrevious: $e');
      _showError('Failed to play previous');
    }
  }

  /// Play song at specific index in queue
  Future<void> playAtIndex(int index) async {
    try {
      if (index < 0 || index >= queue.length) {
        logger.w('Invalid queue index: $index');
        return;
      }
      await _audioService.playAtIndex(index);
    } catch (e) {
      logger.e('Error in playAtIndex: $e');
      _showError('Failed to play song');
    }
  }

  /// Add song to queue
  void addToQueue(SongEntity song) {
    try {
      _audioService.addToQueue(song);
      _showSuccess('Added to queue');
    } catch (e) {
      logger.e('Error in addToQueue: $e');
      _showError('Failed to add to queue');
    }
  }

  /// Add multiple songs to queue
  void addAllToQueue(List<SongEntity> songs) {
    try {
      _audioService.addAllToQueue(songs);
      _showSuccess('${songs.length} songs added to queue');
    } catch (e) {
      logger.e('Error in addAllToQueue: $e');
      _showError('Failed to add songs to queue');
    }
  }

  /// Remove song from queue
  void removeFromQueue(int index) {
    try {
      if (index < 0 || index >= queue.length) {
        logger.w('Invalid queue index: $index');
        return;
      }
      _audioService.removeFromQueue(index);
      _showSuccess('Removed from queue');
    } catch (e) {
      logger.e('Error in removeFromQueue: $e');
      _showError('Failed to remove from queue');
    }
  }

  /// Clear entire queue
  void clearQueue() {
    try {
      _audioService.clearQueue();
      _showSuccess('Queue cleared');
    } catch (e) {
      logger.e('Error in clearQueue: $e');
      _showError('Failed to clear queue');
    }
  }

  /// Set new queue and start playing
  void setQueueAndPlay(List<SongEntity> songs, {int startIndex = 0}) {
    try {
      if (songs.isEmpty) {
        logger.w('Cannot set empty queue');
        return;
      }

      final clampedIndex = startIndex.clamp(0, songs.length - 1);
      _audioService.setQueue(songs, startIndex: clampedIndex);
      playSong(songs[clampedIndex]);
    } catch (e) {
      logger.e('Error in setQueueAndPlay: $e');
      _showError('Failed to start playback');
    }
  }

  // ==================== PLAYBACK MODES ====================

  /// Toggle shuffle mode
  void toggleShuffle() {
    try {
      _audioService.toggleShuffle();
      _showInfo(
        isShuffleEnabled.value ? 'Shuffle on' : 'Shuffle off',
      );
    } catch (e) {
      logger.e('Error in toggleShuffle: $e');
      _showError('Failed to toggle shuffle');
    }
  }

  /// Toggle repeat mode (off -> all -> one -> off)
  void toggleRepeatMode() {
    try {
      _audioService.toggleRepeatMode();
      final mode = repeatMode.value;
      _showInfo(
        mode == RepeatMode.off
            ? 'Repeat off'
            : mode == RepeatMode.all
                ? 'Repeat all'
                : 'Repeat one',
      );
    } catch (e) {
      logger.e('Error in toggleRepeatMode: $e');
      _showError('Failed to toggle repeat');
    }
  }

  /// Set audio quality
  void setAudioQuality(AudioQuality quality) {
    try {
      _audioService.setAudioQuality(quality);
      _showSuccess('Quality set to ${_qualityToString(quality)}');
    } catch (e) {
      logger.e('Error in setAudioQuality: $e');
      _showError('Failed to change quality');
    }
  }

  // ==================== OFFLINE CACHING ====================

  /// Download song for offline playback
  Future<void> downloadSong(SongEntity song) async {
    try {
      final success = await _audioService.downloadSong(song);
      if (success) {
        _showSuccess('Song downloaded');
        await _checkCacheStatus(); // Update status
      } else {
        _showError('Failed to download song');
      }
    } catch (e) {
      logger.e('Error downloading song: $e');
      _showError('Failed to download song');
    }
  }

  /// Check if song is downloaded
  Future<bool> isSongCached(SongEntity song) async {
    return await _audioService.isSongCached(song);
  }

  // ==================== HELPER METHODS ====================

  /// Format duration to MM:SS
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Convert quality enum to string
  String _qualityToString(AudioQuality quality) {
    switch (quality) {
      case AudioQuality.low:
        return 'Low';
      case AudioQuality.medium:
        return 'Medium';
      case AudioQuality.high:
        return 'High';
    }
  }

  /// Show error message to user
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show success message to user
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          Get.theme.snackBarTheme.backgroundColor ?? Get.theme.primaryColor,
      colorText: Get.theme.snackBarTheme.contentTextStyle?.color,
      duration: const Duration(seconds: 2),
    );
  }

  /// Show info message to user
  void _showInfo(String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.snackBarTheme.backgroundColor,
      colorText: Get.theme.snackBarTheme.contentTextStyle?.color,
      duration: const Duration(seconds: 2),
      titleText: const SizedBox.shrink(), // Hide title
    );
  }
}
