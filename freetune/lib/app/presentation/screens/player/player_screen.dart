import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/common/sized.dart';

class PlayerScreen extends GetView<AudioPlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient/Image
          Obx(() => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[900]!,
                      Colors.black,
                    ],
                  ),
                  image: controller.currentSong.value?.albumArtUrl != null
                      ? DecorationImage(
                          image: NetworkImage(
                              controller.currentSong.value!.albumArtUrl!),
                          fit: BoxFit.cover,
                          opacity: 0.3,
                        )
                      : null,
                ),
              )),

          // Content
          Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(
                    top: TSizes.appBarHeight,
                    left: TSizes.spaceBtwItems,
                    right: TSizes.spaceBtwItems),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        )),
                    Text(
                      "Now Playing",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: TSizes.fontSizeLg,
                          fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert_sharp,
                            color: Colors.white, size: TSizes.iconMd)),
                  ],
                ),
              ),

              SizedBox(height: TSizes.spaceBtwSections),

              // Album Art
              Expanded(
                child: Center(
                  child: Obx(() {
                    final song = controller.currentSong.value;
                    return Container(
                      height: TSizes.imageCarouselHeight * 1.5,
                      width: TSizes.imageCarouselHeight * 1.5,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Let's stick to rounded rect but use TSizes
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusLg),
                          image: song?.albumArtUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(song!.albumArtUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[800],
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ]),
                      child: song?.albumArtUrl == null
                          ? Icon(Icons.music_note,
                              size: TSizes.iconXl * 2, color: Colors.white54)
                          : null,
                    );
                  }),
                ),
              ),

              SizedBox(height: TSizes.spaceBtwSections),

              // Song Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                child: Column(
                  children: [
                    Obx(() => Text(
                          controller.currentSong.value?.title ??
                              "Unknown Title",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: TSizes.fontSizeXxl,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(height: TSizes.xs),
                    Obx(() => Text(
                          controller.currentSong.value?.artist ??
                              "Unknown Artist",
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: TSizes.fontSizeMd),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),

              SizedBox(height: TSizes.spaceBtwSections),

              // Progress Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                child: Obx(() {
                  final position =
                      controller.position.value.inMilliseconds.toDouble();
                  final duration =
                      controller.duration.value?.inMilliseconds.toDouble() ??
                          1.0;
                  final sliderMax = duration > 0 ? duration : 1.0;
                  final sliderValue = position.clamp(0.0, sliderMax);

                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: Colors.greenAccent,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.greenAccent,
                      overlayColor: Colors.greenAccent.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: sliderMax,
                      onChanged: (value) {
                        controller.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  );
                }),
              ),

              // Time Labels
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: TSizes.defaultSpace + 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(controller.positionString,
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: TSizes.fontSizeSm))),
                    Obx(() => Text(controller.durationString,
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: TSizes.fontSizeSm))),
                  ],
                ),
              ),

              SizedBox(height: TSizes.spaceBtwItems),

              // Controls
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: TSizes.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: controller.toggleShuffle,
                          icon: Obx(() => Icon(Icons.shuffle,
                              color: controller.isShuffleEnabled.value
                                  ? Colors.greenAccent
                                  : Colors.white,
                              size: TSizes.iconMd + 4))),
                      SizedBox(width: TSizes.spaceBtwItems),
                      IconButton(
                          onPressed: controller.playPrevious,
                          icon: Icon(Icons.skip_previous,
                              color: Colors.white, size: TSizes.iconLg)),
                      SizedBox(width: TSizes.spaceBtwItems),
                      Container(
                        height: TSizes.iconXl * 1.5,
                        width: TSizes.iconXl * 1.5,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.greenAccent),
                        child: IconButton(
                            onPressed: controller.togglePlayPause,
                            icon: Obx(() => Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.black,
                                  size: TSizes.iconLg,
                                ))),
                      ),
                      SizedBox(width: TSizes.spaceBtwItems),
                      IconButton(
                          onPressed: controller.playNext,
                          icon: Icon(Icons.skip_next,
                              color: Colors.white, size: TSizes.iconLg)),
                      SizedBox(width: TSizes.spaceBtwItems),
                      IconButton(
                          onPressed: controller.toggleRepeatMode,
                          icon: Obx(() => Icon(
                              controller.repeatMode.value == RepeatMode.off
                                  ? Icons.repeat
                                  : controller.repeatMode.value ==
                                          RepeatMode.one
                                      ? Icons.repeat_one
                                      : Icons.repeat,
                              color:
                                  controller.repeatMode.value == RepeatMode.off
                                      ? Colors.white
                                      : Colors.greenAccent,
                              size: TSizes.iconMd + 4))),
                    ],
                  ),
                ),
              ),

              SizedBox(height: TSizes.spaceBtwItems),

              // Bottom Actions
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: TSizes.defaultSpace,
                    vertical: TSizes.spaceBtwItems),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          // Download logic
                          final song = controller.currentSong.value;
                          if (song != null) {
                            controller.downloadSong(song);
                          }
                        },
                        icon: Obx(() => Icon(
                            controller.isCurrentSongCached.value
                                ? Icons.download_done
                                : Icons.download,
                            color: controller.isCurrentSongCached.value
                                ? Colors.greenAccent
                                : Colors.white,
                            size: TSizes.iconMd))),
                    IconButton(
                        onPressed: () {
                          // Like/Favorite
                          if (controller.currentSong.value != null) {
                            // Logic to like
                          }
                        },
                        icon: Icon(Icons.favorite_border,
                            color: Colors.white, size: TSizes.iconMd)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share,
                            color: Colors.white, size: TSizes.iconMd)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.format_list_bulleted,
                            color: Colors.white, size: TSizes.iconMd)),
                  ],
                ),
              ),

              SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ],
      ),
    );
  }
}

enum RepeatMode { off, all, one }
