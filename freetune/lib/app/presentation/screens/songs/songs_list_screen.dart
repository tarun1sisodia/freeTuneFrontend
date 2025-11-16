import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/songs_controller.dart';

class SongsListScreen extends GetView<SongController> {
  const SongsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: Obx(() {
        if (controller.isLoadingSongs.value && controller.songs.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final response = controller.songs.value;
        if (response == null || response.data.isEmpty) {
          return const Center(child: Text('No songs found.'));
        }
        
        return ListView.builder(
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final song = response.data[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: song.albumArt != null ? NetworkImage(song.albumArt!) : null,
                child: song.albumArt == null ? const Icon(Icons.music_note) : null,
              ),
              title: Text(song.title),
              subtitle: Text(song.artist),
              trailing: IconButton(
                icon: Icon(
                  song.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: song.isFavorite ? Colors.red : null,
                ),
                onPressed: () { /* TODO: controller.toggleFavorite(song.id); */ },
              ),
              onTap: () { /* TODO: Get.find<AudioPlayerController>().play(song); */ },
            );
          },
        );
      }),
    );
  }
}