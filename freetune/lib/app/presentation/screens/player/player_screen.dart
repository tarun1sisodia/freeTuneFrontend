import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../services/audio/audio_player_service.dart';

class PlayerScreen extends GetView<AudioPlayerController> {
  const PlayerScreen({Key? key}) : super(key: key);

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
                padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("PLAYING FROM ARTIST",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        Obx(() => Text(
                            controller.currentSong.value?.artist ??
                                "Unknown Artist",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w600,
                                fontSize: 15))),
                      ],
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert_sharp,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),

              // Album Art
              Obx(() {
                final song = controller.currentSong.value;
                return Padding(
                    padding: const EdgeInsets.only(
                        top: 30, left: 35, right: 35, bottom: 35),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: song?.albumArtUrl != null
                            ? Image.network(
                                song!.albumArtUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[800],
                                height: 300,
                                width: 300,
                                child: const Icon(Icons.music_note,
                                    size: 80, color: Colors.white))));
              }),

              // Song Title (Marquee)
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 70,
                  height: 25,
                  child: Obx(() => Marquee(
                        text: controller.currentSong.value?.title ??
                            "Unknown Song",
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "SpotifyCircularBold",
                            fontSize: 20),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 300,
                        velocity: 30.0,
                        startPadding: 5.0,
                        pauseAfterRound: const Duration(seconds: 2),
                        startAfter: const Duration(seconds: 2),
                      )),
                ),
              ),

              // Artist Name (Marquee)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 70,
                  height: 25,
                  child: Obx(() => Marquee(
                        text: controller.currentSong.value?.artist ??
                            "Unknown Artist",
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "SpotifyCircularBook",
                            fontWeight: FontWeight.w400,
                            fontSize: 17),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 300,
                        velocity: 30.0,
                        startPadding: 5.0,
                        pauseAfterRound: const Duration(seconds: 2),
                        startAfter: const Duration(seconds: 2),
                      )),
                ),
              ),

              // Progress Bar
              Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.white70,
                        thumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[850],
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 20,
                        child: Obx(() {
                          final position =
                              controller.position.value.inSeconds.toDouble();
                          final duration =
                              controller.duration.value?.inSeconds.toDouble() ??
                                  1.0;
                          return Slider(
                            value: position.clamp(0.0, duration),
                            min: 0,
                            max: duration,
                            divisions: duration > 0 ? duration.toInt() : 1,
                            onChanged: (value) {
                              controller.seek(Duration(seconds: value.toInt()));
                            },
                          );
                        }),
                      ))),

              // Time Labels
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => Text(controller.positionString,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "SpotifyCircularBook",
                            fontWeight: FontWeight.w600,
                            fontSize: 15))),
                    Obx(() => Text(controller.durationString,
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "SpotifyCircularBook",
                            fontWeight: FontWeight.w600,
                            fontSize: 15)))
                  ],
                ),
              ),

              // Playback Controls
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 0, top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    IconButton(
                        onPressed: controller.toggleShuffle,
                        icon: Obx(() => Icon(Icons.shuffle_sharp,
                            color: controller.isShuffleEnabled.value
                                ? Colors.greenAccent.shade400
                                : Colors.white,
                            size: 40))),

                    // Previous
                    IconButton(
                        onPressed: controller.playPrevious,
                        icon: const Icon(
                          Icons.skip_previous_sharp,
                          color: Colors.white,
                          size: 40,
                        )),

                    // Play/Pause
                    Padding(
                      padding: const EdgeInsets.only(right: 50, bottom: 50),
                      child: IconButton(
                          onPressed: controller.togglePlayPause,
                          icon: Obx(() {
                            if (controller.isLoading.value) {
                              return const SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              );
                            }
                            return Icon(
                              controller.isPlaying.value
                                  ? Icons.pause_circle_filled_sharp
                                  : Icons.play_circle_fill_sharp,
                              color: Colors.white,
                              size: 90,
                            );
                          })),
                    ),

                    // Next
                    IconButton(
                        onPressed: controller.playNext,
                        icon: const Icon(
                          Icons.skip_next_sharp,
                          color: Colors.white,
                          size: 40,
                        )),

                    // Repeat
                    IconButton(
                        onPressed: controller.toggleRepeatMode,
                        icon: Obx(() => Icon(
                            _getRepeatIcon(controller.repeatMode.value),
                            color: controller.repeatMode.value != RepeatMode.off
                                ? Colors.greenAccent.shade400
                                : Colors.white,
                            size: 40)))
                  ],
                ),
              ),

              // Bottom Actions
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned(
                          left: 20,
                          child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.devices,
                                color: Colors.white,
                                size: 30,
                              ))),
                      Positioned(
                          right: 10,
                          child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.horizontal_split_sharp,
                                color: Colors.white,
                                size: 30,
                              ))),
                      Positioned(
                          right: 75,
                          child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share_sharp,
                                color: Colors.white,
                                size: 30,
                              ))),
                    ],
                  ),
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
