import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';

class PlayerScreen extends GetView<AudioPlayerController> {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Center(
        child: Obx(() {
          final song = controller.currentSong.value;
          if (song == null) {
            return const Text('No song is playing.');
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(song.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(song.artist, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 48),
                    onPressed: () => controller.playPrevious(),
                  ),
                  Obx(() => IconButton(
                    icon: Icon(controller.isPlaying.value ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 64),
                    onPressed: () {
                      if (controller.isPlaying.value) {
                        controller.pause();
                      } else {
                        controller.resume();
                      }
                    },
                  )),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 48),
                    onPressed: () => controller.playNext(),
                  ),
                ],
              ),
              Obx(() => Slider(
                min: 0.0,
                max: controller.duration.value?.inMilliseconds.toDouble() ?? 0.0,
                value: controller.position.value.inMilliseconds.toDouble(),
                onChanged: (value) {
                  controller.seek(Duration(milliseconds: value.toInt()));
                },
              )),
              Obx(() => Text('${controller.position.value.inMinutes}:${(controller.position.value.inSeconds % 60).toString().padLeft(2, '0')} / ${controller.duration.value?.inMinutes ?? '0'}:${(controller.duration.value?.inSeconds ?? 0 % 60).toString().padLeft(2, '0')}')),
            ],
          );
        }),
      ),
    );
  }
}