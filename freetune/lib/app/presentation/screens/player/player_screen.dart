import 'package:flutter/material.dart';
import 'package:freetune/app/presentation/screens/home/home_screen.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../services/audio/audio_player_service.dart';

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
                padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.put(const HomeScreen());
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

              // Album Art (Responsive)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Obx(() {
                    final song = controller.currentSong.value;
                    return AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: song?.albumArtUrl != null
                              ? Image.network(
                                  song!.albumArtUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.music_note,
                                      size: 80, color: Colors.white)),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Song Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                      child: Obx(() => Marquee(
                            text: controller.currentSong.value?.title ??
                                "Unknown Song",
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBold",
                                fontSize: 22),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 300,
                            velocity: 30.0,
                            startPadding: 0.0,
                            pauseAfterRound: const Duration(seconds: 2),
                            startAfter: const Duration(seconds: 2),
                          )),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 25,
                      child: Obx(() => Marquee(
                            text: controller.currentSong.value?.artist ??
                                "Unknown Artist",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontFamily: "SpotifyCircularBook",
                                fontWeight: FontWeight.w400,
                                fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(controller.positionString,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12))),
                          Obx(() => Text(controller.durationString,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12))),
                        ],
                      ),
                    ),

                    // Controls
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: controller.toggleShuffle,
                                icon: Obx(() => Icon(Icons.shuffle,
                                    color: controller.isShuffleEnabled.value
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    size: 28))),
                            const SizedBox(width: 20),
                            IconButton(
                                onPressed: controller.playPrevious,
                                icon: const Icon(Icons.skip_previous,
                                    color: Colors.white, size: 36)),
                            const SizedBox(width: 20),
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
                                      size: 50))),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                                onPressed: controller.playNext,
                                icon: const Icon(Icons.skip_next,
                                    color: Colors.white, size: 36)),
                            const SizedBox(width: 20),
                            IconButton(
                                onPressed: controller.toggleRepeatMode,
                                icon: Obx(() => Icon(
                                    _getRepeatIcon(controller.repeatMode.value),
                                    color: controller.repeatMode.value !=
                                            RepeatMode.off
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    size: 28))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Actions (Responsive Row)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.devices,
                            color: Colors.white, size: 24)),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share,
                            color: Colors.white, size: 24)),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.format_list_bulleted,
                            color: Colors.white, size: 24)),
                  ],
                ),
              )
            ],
          )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black87,
              Colors.deepPurple.shade900.withOpacity(0.8)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // Player screen is at index 1
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white60,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Get.back(); // Go to home
                break;
              case 1:
                // Already on player screen
                break;
              case 2:
                // Navigate to search (implement when ready)
                Get.snackbar('Search', 'Search feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM);
                break;
              case 3:
                // Navigate to library (implement when ready)
                Get.snackbar('Library', 'Library feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_filled),
              label: 'Player',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Library',
            ),
          ],
        ),
      ),
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
