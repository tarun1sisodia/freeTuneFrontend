import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/song_search_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../routes/app_routes.dart'; // Used for PLAYER route
import '../../../core/constants/palette.dart';

class SearchScreen extends GetView<SongSearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is injected via binding
    final audioPlayerController = Get.find<AudioPlayerController>();

    return Scaffold(
      backgroundColor: Palette.secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Palette.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Search",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: "SpotifyCircularBold",
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: "SpotifyCircularMedium",
                      ),
                      decoration: const InputDecoration(
                        hintText: "What do you want to listen to?",
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: "SpotifyCircularMedium",
                          color: Palette.secondarySwatchColor,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Palette.secondaryColor, size: 28),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results or Categories
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                if (controller.searchController.text.isNotEmpty) {
                  // Show Search Results
                  if (controller.searchResults.isEmpty) {
                    return const Center(
                      child: Text(
                        "No songs found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final song = controller.searchResults[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            song.albumArtUrl ??
                                "https://via.placeholder.com/50",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                        title: Text(
                          song.title,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing:
                            const Icon(Icons.more_vert, color: Colors.grey),
                        onTap: () {
                          // Play song
                          audioPlayerController.playSong(song);
                          // Optional: Navigate to player
                          Get.toNamed(Routes.PLAYER);
                        },
                      );
                    },
                  );
                } else {
                  // Show "Browse all" (Static Categories matching Clone)
                  return CustomScrollView(
                    slivers: [
                      const SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "Browse all",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: "SpotifyCircularBold",
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1.6,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .accents[index % Colors.accents.length],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  "Genre ${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Note: In a real app, use images and real genres
                              );
                            },
                            childCount: 10,
                          ),
                        ),
                      ),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
