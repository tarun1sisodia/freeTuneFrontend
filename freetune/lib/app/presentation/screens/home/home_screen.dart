import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/songs_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/song_tile.dart';

class HomeScreen extends GetView<SongController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SongController if not already done (e.g., if Home is the initial route)
    if (!Get.isRegistered<SongController>()) {
      Get.put(SongController(Get.find()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Welcome, ${Get.find<AuthController>().user.value?.username ?? Get.find<AuthController>().user.value?.email ?? 'Guest'}!')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              Get.snackbar('Search', 'Search functionality coming soon!');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchSongs(refresh: true);
          // await controller.fetchPopularSongs(refresh: true);
          // await controller.fetchRecentlyPlayed(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recently Played',
                  style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoadingSongs.value && controller.songs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.songs.isEmpty) {
                    return const Center(child: Text('No recently played songs.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.songs.length > 5 ? 5 : controller.songs.length, // Show top 5 for example
                    itemBuilder: (context, index) {
                      final song = controller.songs[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          // TODO: Play song
                          Get.snackbar('Playing', 'Now playing: ${song.title}');
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 32),
                Text(
                  'Popular Songs',
                  style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoadingPopular.value && controller.popularSongs.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.popularSongs.isEmpty) {
                    return const Center(child: Text('No popular songs available.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.popularSongs.length > 5 ? 5 : controller.popularSongs.length,
                    itemBuilder: (context, index) {
                      final song = controller.popularSongs[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          // TODO: Play song
                          Get.snackbar('Playing', 'Now playing: ${song.title}');
                        },
                      );
                    },
                  );
                }),
                // Add more sections like 'Recommendations', 'New Releases' etc.
              ],
            ),
          ),
        ),
      ),
    );
  }
}