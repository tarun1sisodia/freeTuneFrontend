import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';
import '../album_art.dart';
import '../../../routes/app_routes.dart';

class MiniPlayer extends GetView<AudioPlayerController> {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.currentSong.value == null) {
        return const SizedBox.shrink();
      }
      final song = controller.currentSong.value!;

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.PLAYER),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              AlbumArt(
                imageUrl: song.albumArtUrl,
                size: 70,
                borderRadius: BorderRadius.zero,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(song.artist, style: context.textTheme.bodySmall?.copyWith(color: context.theme.colorScheme.onSurface.withOpacity(0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: context.theme.colorScheme.primary,
                ),
                onPressed: () {
                  if (controller.isPlaying.value) {
                    controller.pause();
                  } else {
                    controller.resume();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: context.theme.colorScheme.onSurface),
                onPressed: () => controller.playNext(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
