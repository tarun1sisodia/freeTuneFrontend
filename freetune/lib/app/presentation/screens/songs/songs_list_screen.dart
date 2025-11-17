import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/songs_controller.dart';
import '../../widgets/song_tile.dart';

class SongsListScreen extends GetView<SongController> {
  const SongsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SongController if not already done
    if (!Get.isRegistered<SongController>()) {
      Get.put(SongController(Get.find()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All Songs')),
      body: Obx(() {
        if (controller.isLoadingSongs.value && controller.songs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.songs.isEmpty) {
          return const Center(child: Text('No songs found.'));
        }
        
        return RefreshIndicator(
          onRefresh: () => controller.fetchSongs(refresh: true),
          child: ListView.builder(
            itemCount: controller.songs.length + (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.songs.length) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ));
              }
              final song = controller.songs[index];
              return SongTile(
                song: song,
                onTap: () { /* TODO: Get.find<AudioPlayerController>().play(song); */ },
              );
            },
          ),
        );
      }),
    );
  }
}