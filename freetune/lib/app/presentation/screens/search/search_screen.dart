import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/song_search_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../routes/app_routes.dart'; // Used for PLAYER route
import '../../../core/constants/palette.dart';
import '../../widgets/common/sized.dart';

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
                  horizontal: TSizes.defaultSpace,
                  vertical: TSizes.spaceBtwItems),
              color: Palette.secondaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Search",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: TSizes.fontSizeXxl,
                      color: Colors.white,
                      fontFamily: "SpotifyCircularBold",
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwItems),
                  // Search Bar
                  Container(
                    height: TSizes.inputFieldHeight,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(TSizes.inputFieldRadius),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      style: TextStyle(
                        fontSize: TSizes.fontSizeMd,
                        color: Colors.black,
                        fontFamily: "SpotifyCircularMedium",
                      ),
                      decoration: InputDecoration(
                        hintText: "What do you want to listen to?",
                        hintStyle: TextStyle(
                          fontSize: TSizes.fontSizeMd,
                          fontFamily: "SpotifyCircularMedium",
                          color: Palette.secondarySwatchColor,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Palette.secondaryColor, size: TSizes.iconMd),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: TSizes
                                .sm), // Adjust to center vertically in standard height
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
                                color: Colors.white,
                                fontSize: TSizes.fontSizeMd),
                          ),
                          SizedBox(height: TSizes.md),
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
                                        horizontal: TSizes.xl,
                                        vertical: TSizes.sm),
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          SizedBox(height: TSizes.sm),
                          Text(
                            "We'll download it for you!",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: TSizes.fontSizeSm),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(bottom: TSizes.md),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final song = controller.searchResults[index];
                      // Calculate duration string
                      final duration = Duration(milliseconds: song.durationMs);
                      final durationStr =
                          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(TSizes.borderRadiusXs),
                          child: Image.network(
                            song.albumArtUrl ??
                                "https://via.placeholder.com/50",
                            width: TSizes.imageThumbSize * 0.6, // Approx 48
                            height: TSizes.imageThumbSize * 0.6,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: TSizes.imageThumbSize * 0.6,
                              height: TSizes.imageThumbSize * 0.6,
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
                              fontSize: TSizes.fontSizeSm),
                        ),
                        subtitle: Text(
                          "${song.artist} • $durationStr",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey, fontSize: TSizes.fontSizeSm),
                        ),
                        trailing: Icon(Icons.play_circle_fill,
                            color: Palette.primaryColor, size: TSizes.iconLg),
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
                        padding: EdgeInsets.all(TSizes.defaultSpace),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "Browse all",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.fontSizeLg,
                              color: Colors.white,
                              fontFamily: "SpotifyCircularBold",
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: TSizes.defaultSpace),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 1.6,
                            mainAxisSpacing: TSizes.md,
                            crossAxisSpacing: TSizes.md,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors
                                      .accents[index % Colors.accents.length],
                                  borderRadius: BorderRadius.circular(
                                      TSizes.borderRadiusXs),
                                ),
                                padding: EdgeInsets.all(TSizes.sm),
                                child: Text(
                                  "Genre ${index + 1}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: TSizes.fontSizeMd,
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
                          padding: EdgeInsets.only(bottom: TSizes.md)),
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
