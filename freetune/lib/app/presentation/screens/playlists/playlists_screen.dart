import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playlist_controller.dart';

class PlaylistsScreen extends GetView<PlaylistController> {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Show a dialog to create playlist using controller.createPlaylist(...)
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.playlists.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.playlists.isEmpty) {
          return const Center(child: Text('No playlists yet'));
        }
        return ListView.builder(
          itemCount: controller.playlists.length,
          itemBuilder: (context, index) {
            final playlist = controller.playlists[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: playlist.coverArt != null
                    ? NetworkImage(playlist.coverArt!)
                    : null,
                child: playlist.coverArt == null
                    ? const Icon(Icons.playlist_play)
                    : null,
              ),
              title: Text(playlist.name),
              subtitle: Text('${playlist.songIds.length} songs'),
              onTap: () {
                // TODO: Get.toNamed('/playlist/${playlist.id}');
              },
            );
          },
        );
      }),
    );
  }
}
