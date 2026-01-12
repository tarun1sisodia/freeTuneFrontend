import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/common/sized.dart';

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
          height: 60, // Fixed height close to 64
          margin: EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(TSizes.cardRadiusXs),
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
                  topLeft: Radius.circular(TSizes.cardRadiusXs),
                  bottomLeft: Radius.circular(TSizes.cardRadiusXs),
                ),
                child: song.albumArtUrl != null
                    ? Image.network(
                        song.albumArtUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              SizedBox(width: TSizes.spaceBtwItems),

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
                        fontSize: TSizes.fontSizeSm,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.artist,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: TSizes.fontSizeXs,
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
                    color: Colors.white, size: TSizes.iconMd),
                onPressed: controller.playPrevious,
              ),
              Obx(() => IconButton(
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: TSizes.iconMd,
                            height: TSizes.iconMd,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            controller.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: TSizes.iconMd,
                          ),
                    onPressed: controller.togglePlayPause,
                  )),
              IconButton(
                icon: Icon(Icons.skip_next,
                    color: Colors.white, size: TSizes.iconMd),
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
      width: 60,
      height: 60,
      color: Colors.grey[800],
      child: Icon(Icons.music_note, color: Colors.grey, size: TSizes.iconLg),
    );
  }
}
