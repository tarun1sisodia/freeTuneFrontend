import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/song_search_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../routes/app_routes.dart'; // Used for PLAYER route
import '../../../core/constants/palette.dart';
import '../../../core/utils/app_sizes.dart';

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
              padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.padding, vertical: AppSizes.h(12)),
              color: Palette.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.sp(25),
                      color: Colors.white,
                      fontFamily: "SpotifyCircularBold",
                    ),
                  ),
                  SizedBox(height: AppSizes.h(12)),
                  // Search Bar
                  Container(
                    height: AppSizes.h(50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      style: TextStyle(
                        fontSize: AppSizes.sp(16),
                        color: Colors.black,
                        fontFamily: "SpotifyCircularMedium",
                      ),
                      decoration: InputDecoration(
                        hintText: "What do you want to listen to?",
                        hintStyle: TextStyle(
                          fontSize: AppSizes.sp(16),
                          fontFamily: "SpotifyCircularMedium",
                          color: Palette.secondarySwatchColor,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Palette.secondaryColor,
                            size: AppSizes.w(28)),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: AppSizes.h(12)),
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No songs found",
                            style: TextStyle(
                                color: Colors.white, fontSize: AppSizes.sp(16)),
                          ),
                          SizedBox(height: AppSizes.h(16)),
                          Obx(() => controller.isImporting.value
                              ? const CircularProgressIndicator(
                                  color: Palette.primaryColor)
                              : ElevatedButton.icon(
                                  onPressed: () {
                                    controller.requestDownload(
                                        controller.searchController.text);
                                  },
                                  icon: const Icon(Icons.cloud_download),
                                  label: Text(
                                      "Request '${controller.searchController.text}'"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Palette.primaryColor,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.w(24),
                                        vertical: AppSizes.h(12)),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          SizedBox(height: AppSizes.h(8)),
                          Text(
                            "We'll download it for you!",
                            style: TextStyle(
                                color: Colors.grey, fontSize: AppSizes.sp(12)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: AppSizes.h(20)),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final song = controller.searchResults[index];
                      // Calculate duration string
                      final duration = Duration(milliseconds: song.durationMs);
                      final durationStr =
                          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            song.albumArtUrl ??
                                "https://via.placeholder.com/50",
                            width: AppSizes.w(50),
                            height: AppSizes.w(50), // Square
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: AppSizes.w(50),
                              height: AppSizes.w(50),
                              color: Colors.grey[800],
                              child: const Icon(Icons.music_note,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                        title: Text(
                          song.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.sp(14)),
                        ),
                        subtitle: Text(
                          "${song.artist} • $durationStr",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey, fontSize: AppSizes.sp(12)),
                        ),
                        trailing: Icon(Icons.play_circle_fill,
                            color: Palette.primaryColor,
                            size: AppSizes.w(
                                28)), // Changed to Play icon for clear intent
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
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                            AppSizes.padding,
                            AppSizes.padding,
                            AppSizes.padding,
                            AppSizes.padding),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "Browse all",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.sp(18),
                              color: Colors.white,
                              fontFamily: "SpotifyCircularBold",
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSizes.padding),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: AppSizes.w(200),
                            childAspectRatio: 1.6,
                            mainAxisSpacing: AppSizes.h(16),
                            crossAxisSpacing: AppSizes.w(16),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .accents[index % Colors.accents.length],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: EdgeInsets.all(AppSizes.w(12)),
                                child: Text(
                                  "Genre ${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSizes.sp(16),
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
                      SliverPadding(
                          padding: EdgeInsets.only(bottom: AppSizes.h(20))),
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
