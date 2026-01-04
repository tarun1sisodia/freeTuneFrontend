import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/playlist_controller.dart';
import '../../../domain/entities/playlist_entity.dart';
import '../../../routes/app_routes.dart';

class PlaylistsScreen extends GetView<PlaylistController> {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Local state for selection mode using GetX reactivity
    final selectedSongIds = <String>{}.obs;
    final isSelectionMode = false.obs;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Obx(() => isSelectionMode.value
              ? Text('${selectedSongIds.length} Selected')
              : const Text('Your Library')),
          backgroundColor: Colors.black,
          leading: Obx(() => isSelectionMode.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    isSelectionMode.value = false;
                    selectedSongIds.clear();
                  },
                )
              : const BackButton()), // Or logic to show Menu
          actions: [
            Obx(() {
              if (isSelectionMode.value) {
                return Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.playlist_add),
                        onPressed: selectedSongIds.isNotEmpty
                            ? () {
                                _showCreatePlaylistFromSelectionDialog(
                                    context, selectedSongIds.toList());
                                isSelectionMode.value = false;
                                selectedSongIds.clear();
                              }
                            : null),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: selectedSongIds.isNotEmpty
                            ? () async {
                                await _confirmDeleteSongs(
                                    selectedSongIds.toList());
                                isSelectionMode.value = false;
                                selectedSongIds.clear();
                              }
                            : null),
                  ],
                );
              }
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showCreatePlaylistDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // TODO: Search playlists/songs
                    },
                  ),
                ],
              );
            }),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Playlists"),
              Tab(text: "My Songs"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Playlists
            _buildPlaylistsTab(context),

            // Tab 2: My Songs
            _buildMySongsTab(context, selectedSongIds, isSelectionMode),
          ],
        ),
      ),
    );
  }

  // ... (Helper methods for Tabs)

  Widget _buildPlaylistsTab(BuildContext context) {
    return Obx(() {
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
    });
  }

  Widget _buildMySongsTab(BuildContext context, RxSet<String> selectedSongIds,
      RxBool isSelectionMode) {
    return Obx(() {
      if (controller.isLoadingSongs.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.uploadedSongs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No songs uploaded yet',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.UPLOAD),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Upload Songs'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.UPLOAD),
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload More"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.uploadedSongs.length,
              itemBuilder: (context, index) {
                final song = controller.uploadedSongs[index];
                return Obx(() {
                  final isSelected = selectedSongIds.contains(song.id);
                  return ListTile(
                    leading: isSelectionMode.value
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              if (val == true) {
                                selectedSongIds.add(song.id);
                              } else {
                                selectedSongIds.remove(song.id);
                              }
                            },
                          )
                        : (song.albumArtUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(song.albumArtUrl!,
                                    width: 50, height: 50, fit: BoxFit.cover))
                            : const Icon(Icons.music_note,
                                color: Colors.white)),
                    title: Text(song.title,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(song.artist,
                        style: const TextStyle(color: Colors.grey)),
                    trailing: isSelectionMode.value
                        ? null
                        : PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white),
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await _confirmDeleteSongs([song.id]);
                              } else if (value == 'add_to_playlist') {
                                _showCreatePlaylistFromSelectionDialog(
                                    context, [song.id]);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'add_to_playlist',
                                child: Text('Add to New Playlist'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                    onTap: () {
                      if (isSelectionMode.value) {
                        if (isSelected) {
                          selectedSongIds.remove(song.id);
                        } else {
                          selectedSongIds.add(song.id);
                        }
                      } else {
                        // Play song or navigate
                        // Get.toNamed(Routes.PLAYER, arguments: ...);
                      }
                    },
                    onLongPress: () {
                      isSelectionMode.value = true;
                      selectedSongIds.add(song.id);
                    },
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }

  // ... (Existing Playlists Helpers like _buildLikedSongsCard, _buildPlaylistCard, _showCreatePlaylistDialog)
  // Re-adding them here to ensure file completeness.

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

  void _showCreatePlaylistFromSelectionDialog(
      BuildContext context, List<String> songIds) {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Create Playlist (${songIds.length} songs)',
            style: const TextStyle(color: Colors.white)),
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
                controller.createPlaylistFromSelection(
                    textController.text, songIds);
                // dialog closed in controller
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

  Future<void> _confirmDeleteSongs(List<String> songIds) async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Delete Songs?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${songIds.length} songs? check',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog first
              for (var id in songIds) {
                await controller.deleteSong(id);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
