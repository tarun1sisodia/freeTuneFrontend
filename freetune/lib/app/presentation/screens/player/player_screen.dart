import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/album_art.dart';
import '../../../core/utils/formatters.dart';

class PlayerScreen extends GetView<AudioPlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final song = controller.currentSong.value;
        if (song == null) {
          return const Center(child: Text('No song is playing.'));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlbumArt(
                imageUrl: song.albumArtUrl,
                size: Get.width * 0.7,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 32),
              Text(
                song.title,
                style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                song.artist,
                style: context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 32),
              Obx(() => Slider(
                min: 0.0,
                max: controller.duration.value?.inMilliseconds.toDouble() ?? 0.0,
                value: controller.position.value.inMilliseconds.toDouble().clamp(0.0, controller.duration.value?.inMilliseconds.toDouble() ?? 0.0),
                onChanged: (value) {
                  controller.seek(Duration(milliseconds: value.toInt()));
                },
                activeColor: context.theme.colorScheme.primary,
                inactiveColor: context.theme.colorScheme.primary.withOpacity(0.3),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                      Formatters.formatDuration(controller.position.value),
                      style: context.textTheme.bodySmall,
                    )),
                    Obx(() => Text(
                      Formatters.formatDuration(controller.duration.value ?? Duration.zero),
                      style: context.textTheme.bodySmall,
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 48),
                    onPressed: () => controller.playPrevious(),
                    color: context.theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 24),
                  Obx(() => IconButton(
                    icon: Icon(controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80),
                    onPressed: () {
                      if (controller.isPlaying.value) {
                        controller.pause();
                      } else {
                        controller.resume();
                      }
                    },
                    color: context.theme.colorScheme.primary,
                  )),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 48),
                    onPressed: () => controller.playNext(),
                    color: context.theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}