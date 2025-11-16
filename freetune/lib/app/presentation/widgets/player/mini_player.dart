import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../controllers/audio_player_controller.dart'; // Create this later

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to audio player controller
    return const SizedBox.shrink();

    // Uncomment when audio player controller is implemented:
    /*
    final audioController = Get.find<AudioPlayerController>();

    return Obx(() {
        if (audioController.currentSong.value == null) {
          return const SizedBox.shrink();
        }
        final song = audioController.currentSong.value!;

        return Container(
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
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  image: song.albumArt != null
                      ? DecorationImage(
                          image: NetworkImage(song.albumArt!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: song.albumArt == null
                    ? const Icon(Icons.music_note)
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(song.artist, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  audioController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                ),
                onPressed: () {
                  if (audioController.isPlaying.value) {
                    audioController.pause();
                  } else {
                    audioController.resume();
                  }
                },
              ),
            ],
          ),
        );
      }
    );
    */
  }
}
