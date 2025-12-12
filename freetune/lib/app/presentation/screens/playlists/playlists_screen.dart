import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playlist_controller.dart';
import '../../../domain/entities/playlist_entity.dart';

class PlaylistsScreen extends GetView<PlaylistController> {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Your Library'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search playlists
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.music_note, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Create your first playlist',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreatePlaylistDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Create Playlist'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: controller.playlists.length + 1, // +1 for "Liked Songs"
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildLikedSongsCard();
            }
            final playlist = controller.playlists[index - 1];
            return _buildPlaylistCard(playlist);
          },
        );
      }),
    );
  }

  Widget _buildLikedSongsCard() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Liked Songs
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade800, Colors.blue.shade900],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 40),
            SizedBox(height: 12),
            Text(
              'Liked Songs',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Auto-generated',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(PlaylistEntity playlist) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to playlist details
      },
      onLongPress: () => _showPlaylistOptions(playlist),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                image: playlist.coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(playlist.coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: playlist.coverUrl == null
                  ? const Center(
                      child:
                          Icon(Icons.music_note, color: Colors.grey, size: 40),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${playlist.songIds.length} songs',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Create Playlist',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller
                    .createPlaylist(name: textController.text, songIds: []);
                Get.back();
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(PlaylistEntity playlist) {
    Get.bottomSheet(
      Container(
        color: Colors.grey[900],
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                _confirmDelete(playlist);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(PlaylistEntity playlist) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Playlist?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${playlist.name}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              controller.deletePlaylist(playlist.id);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
