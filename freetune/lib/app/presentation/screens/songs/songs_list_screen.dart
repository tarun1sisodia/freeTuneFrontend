import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/songs_controller.dart';
import '../../controllers/audio_player_controller.dart';

class SongsListScreen extends GetView<SongController> {
  const SongsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: Obx(() {
        if (controller.isLoadingSongs.value && controller.songs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.songs.isEmpty) {
          return const Center(child: Text('No songs found.'));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!controller.isLoadingMore.value &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              controller.loadMoreSongs();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: controller.songs.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.songs.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final song = controller.songs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: song.albumArtUrl != null
                      ? NetworkImage(song.albumArtUrl!)
                      : null,
                  child: song.albumArtUrl == null
                      ? const Icon(Icons.music_note)
                      : null,
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () {
                  Get.find<AudioPlayerController>()
                      .playSong(song, queue: controller.songs);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
