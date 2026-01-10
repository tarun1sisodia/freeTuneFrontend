import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../services/audio/audio_player_service.dart';
import '../../../core/utils/app_sizes.dart';

class PlayerScreen extends GetView<AudioPlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                Colors.deepPurple.shade800.withOpacity(0.8),
                Colors.black87.withOpacity(0.8)
              ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.mirror)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(
                    top: AppSizes.h(30),
                    left: AppSizes.padding,
                    right: AppSizes.padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: AppSizes.iconSize,
                        )),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("PLAYING FROM ARTIST",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w600,
                                fontSize: AppSizes.sp(12))),
                        Obx(() => Text(
                            controller.currentSong.value?.artist ??
                                "Unknown Artist",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w600,
                                fontSize: AppSizes.sp(15)))),
                      ],
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert_sharp,
                          color: Colors.white,
                          size: AppSizes.iconSize,
                        )),
                  ],
                ),
              ),

              // Album Art (Responsive)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.w(20)),
                  child: Obx(() {
                    final song = controller.currentSong.value;
                    return AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius * 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius * 2),
                          child: song?.albumArtUrl != null
                              ? Image.network(
                                  song!.albumArtUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: Icon(Icons.music_note,
                                      size: AppSizes.w(80),
                                      color: Colors.white)),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Song Info
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.h(30)),
                child: Column(
                  children: [
                    SizedBox(
                      height: AppSizes.h(30),
                      child: Obx(() => Marquee(
                            text: controller.currentSong.value?.title ??
                                "Unknown Song",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBold",
                                fontSize: AppSizes.sp(22)),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 300,
                            velocity: 30.0,
                            startPadding: 0.0,
                            pauseAfterRound: const Duration(seconds: 2),
                            startAfter: const Duration(seconds: 2),
                          )),
                    ),
                    SizedBox(height: AppSizes.h(5)),
                    SizedBox(
                      height: AppSizes.h(25),
                      child: Obx(() => Marquee(
                            text: controller.currentSong.value?.artist ??
                                "Unknown Artist",
                            style: TextStyle(
                                color: Colors.white70,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w400,
                                fontSize: AppSizes.sp(16)),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 300,
                            velocity: 30.0,
                            startPadding: 0.0,
                            pauseAfterRound: const Duration(seconds: 2),
                            startAfter: const Duration(seconds: 2),
                          )),
                    ),
                  ],
                ),
              ),

              // Progress & Controls section
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Slider
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSizes.w(10)),
                        child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: Colors.white,
                              thumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey[800],
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                            ),
                            child: Obx(() {
                              final position = controller
                                  .position.value.inSeconds
                                  .toDouble();
                              final duration = controller
                                      .duration.value?.inSeconds
                                      .toDouble() ??
                                  1.0;
                              return Slider(
                                value: position.clamp(0.0, duration),
                                min: 0,
                                max: duration > 0 ? duration : 1,
                                onChanged: (value) {
                                  controller
                                      .seek(Duration(seconds: value.toInt()));
                                },
                              );
                            }))),

                    // Time Labels
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSizes.w(25)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(controller.positionString,
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: AppSizes.sp(12)))),
                          Obx(() => Text(controller.durationString,
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: AppSizes.sp(12)))),
                        ],
                      ),
                    ),

                    // Controls
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSizes.w(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: controller.toggleShuffle,
                                icon: Obx(() => Icon(Icons.shuffle,
                                    color: controller.isShuffleEnabled.value
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    size: AppSizes.w(28)))),
                            SizedBox(width: AppSizes.w(20)),
                            IconButton(
                                onPressed: controller.playPrevious,
                                icon: Icon(Icons.skip_previous,
                                    color: Colors.white, size: AppSizes.w(36))),
                            SizedBox(width: AppSizes.w(20)),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: controller.togglePlayPause,
                                  icon: Obx(() => Icon(
                                      controller.isPlaying.value
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.black,
                                      size: AppSizes.w(50)))),
                            ),
                            SizedBox(width: AppSizes.w(20)),
                            IconButton(
                                onPressed: controller.playNext,
                                icon: Icon(Icons.skip_next,
                                    color: Colors.white, size: AppSizes.w(36))),
                            SizedBox(width: AppSizes.w(20)),
                            IconButton(
                                onPressed: controller.toggleRepeatMode,
                                icon: Obx(() => Icon(
                                    _getRepeatIcon(controller.repeatMode.value),
                                    color: controller.repeatMode.value !=
                                            RepeatMode.off
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    size: AppSizes.w(28)))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Actions (Responsive Row)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.w(30), vertical: AppSizes.h(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.devices,
                            color: Colors.white, size: AppSizes.iconSize)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share,
                            color: Colors.white, size: AppSizes.iconSize)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.format_list_bulleted,
                            color: Colors.white, size: AppSizes.iconSize)),
                  ],
                ),
              )
            ],
          )),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.one:
        return Icons.repeat_one_sharp;
      case RepeatMode
            .all: // Using repeat_sharp for better "all" representation or repeat_on_sharp if desired
        return Icons.repeat_on_sharp;
      case RepeatMode.off:
        return Icons.repeat;
    }
  }
}
