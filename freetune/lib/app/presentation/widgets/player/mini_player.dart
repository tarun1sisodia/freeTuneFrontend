import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../core/utils/app_sizes.dart';

class MiniPlayer extends GetView<AudioPlayerController> {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final song = controller.currentSong.value;
      if (song == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.PLAYER),
        child: Container(
          height: AppSizes.h(64),
          margin: EdgeInsets.all(AppSizes.w(8)),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(AppSizes.radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radius),
                  bottomLeft: Radius.circular(AppSizes.radius),
                ),
                child: song.albumArtUrl != null
                    ? Image.network(
                        song.albumArtUrl!,
                        width: AppSizes.h(64), // Square based on height
                        height: AppSizes.h(64),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              SizedBox(width: AppSizes.w(12)),

              // Title & Artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.sp(14),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: AppSizes.sp(12),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Controls
              IconButton(
                icon: Icon(Icons.skip_previous,
                    color: Colors.white, size: AppSizes.iconSize),
                onPressed: controller.playPrevious,
              ),
              Obx(() => IconButton(
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: AppSizes.w(24),
                            height: AppSizes.w(24),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            controller.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: AppSizes.iconSize,
                          ),
                    onPressed: controller.togglePlayPause,
                  )),
              IconButton(
                icon: Icon(Icons.skip_next,
                    color: Colors.white, size: AppSizes.iconSize),
                onPressed: controller.playNext,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      width: AppSizes.h(64),
      height: AppSizes.h(64),
      color: Colors.grey[800],
      child: Icon(Icons.music_note, color: Colors.grey, size: AppSizes.w(32)),
    );
  }
}
