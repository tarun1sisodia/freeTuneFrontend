import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../services/audio/audio_player_service.dart';
import '../../../domain/entities/song_entity.dart';

class PlayerScreen extends GetView<AudioPlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        final song = controller.currentSong.value;
        if (song == null) {
          return const Center(
              child: Text('No song playing',
                  style: TextStyle(color: Colors.white)));
        }

        return Stack(
          children: [
            // 1. Blurred Background
            _buildBlurredBackground(song.albumArtUrl),

            // 2. Main Content
            SafeArea(
              child: Column(
                children: [
                  // Header (Down Arrow & Playlist Name)
                  _buildHeader(),

                  const Spacer(),

                  // Album Art
                  _buildAlbumArt(song.albumArtUrl),

                  const Spacer(),

                  // Song Info & Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Artist + Like Button
                        _buildSongInfo(song),

                        const SizedBox(height: 30),

                        // Progress Bar
                        _buildProgressBar(),

                        const SizedBox(height: 20),

                        // Playback Controls
                        _buildPlaybackControls(),

                        const SizedBox(height: 30),

                        // Bottom Actions (Devices, Share)
                        _buildBottomActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBlurredBackground(String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageUrl != null
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/placeholder.png')
                  as ImageProvider, // Fallback
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 30),
            onPressed: () => Get.back(),
          ),
          Column(
            children: [
              Text(
                'PLAYING FROM PLAYLIST',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                'Liked Songs', // TODO: Dynamic playlist name
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Show options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String? imageUrl) {
    return Container(
      width: Get.width * 0.85,
      height: Get.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        image: DecorationImage(
          image: imageUrl != null
              ? NetworkImage(imageUrl)
              : const AssetImage('assets/images/placeholder.png')
                  as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSongInfo(SongEntity song) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            song.isFavorite == true ? Icons.favorite : Icons.favorite_border,
            color: song.isFavorite == true ? Colors.green : Colors.white,
            size: 28,
          ),
          onPressed: () {
            // TODO: Toggle favorite
          },
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final position = controller.position.value;
      final duration = controller.duration.value ?? Duration.zero;
      final max = duration.inMilliseconds.toDouble();
      final value = position.inMilliseconds.toDouble().clamp(0.0, max);

      return Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: max > 0 ? max : 1.0,
              onChanged: (val) {
                controller.seek(Duration(milliseconds: val.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.positionString,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
                Text(
                  controller.durationString,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Obx(() => Icon(
                Icons.shuffle,
                color: controller.isShuffleEnabled.value
                    ? Colors.green
                    : Colors.white,
                size: 28,
              )),
          onPressed: controller.toggleShuffle,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
          onPressed: controller.playPrevious,
        ),
        Obx(() => Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                icon: controller.isLoading.value
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 3),
                      )
                    : Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.black,
                        size: 36,
                      ),
                onPressed: controller.togglePlayPause,
              ),
            )),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
          onPressed: controller.playNext,
        ),
        IconButton(
          icon: Obx(() => Icon(
                _getRepeatIcon(controller.repeatMode.value),
                color: controller.repeatMode.value != RepeatMode.off
                    ? Colors.green
                    : Colors.white,
                size: 28,
              )),
          onPressed: controller.toggleRepeatMode,
        ),
      ],
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.off:
        return Icons.repeat;
    }
  }

  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.devices, color: Colors.white, size: 24),
          onPressed: () {
            // TODO: Device picker
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white, size: 24),
          onPressed: () {
            // TODO: Share
          },
        ),
      ],
    );
  }
}
