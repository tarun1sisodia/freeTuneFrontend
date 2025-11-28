import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/song_search_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/song/song_tile.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_state.dart';

class SearchScreen extends GetView<SongSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: controller.searchController,
          onChanged: controller.onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search songs, artists...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: controller.clearSearch,
            ),
          ),
          autofocus: true,
          cursorColor: Colors.green,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoadingIndicator(message: 'Searching...'));
        }

        if (controller.error.value != null) {
          return ErrorView(
            message: controller.error.value!,
            onRetry: () => controller.search(controller.searchController.text),
          );
        }

        if (controller.searchResults.isEmpty) {
          if (controller.searchController.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text(
                    'Play what you love',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for songs, artists, and more',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else {
            return const EmptyState(
              message: 'No results found',
              icon: Icons.search_off,
            );
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // For mini player
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final song = controller.searchResults[index];
            return SongTile(
              song: song,
              onTap: () {
                Get.find<AudioPlayerController>()
                    .playSong(song, queue: controller.searchResults);
                Get.toNamed(Routes.PLAYER);
              },
              onFavorite: () {
                // TODO: Implement favorite toggle
              },
              onMore: () {
                // TODO: Show options
              },
            );
          },
        );
      }),
    );
  }
}
