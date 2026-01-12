import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/songs_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/home/recent_playlist_container.dart';
import '../../widgets/home/recently_played_card.dart';
import '../../widgets/common/sized.dart';
import '../../widgets/common/screen_size_calculator.dart';

class HomeScreen extends GetView<SongController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded
    final authController = Get.find<AuthController>();
    final playerController = Get.find<AudioPlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: TSizes.spaceBtwSections),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(_getGreeting(authController),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.fontSizeXxl,
                              color: Colors.white,
                              fontFamily: "SpotifyCircularBold")),
                    ),
                  ),
                  Row(children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications_none_sharp,
                            color: Colors.white, size: TSizes.iconMd)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.access_time_sharp,
                            color: Colors.white, size: TSizes.iconMd)),
                    IconButton(
                        onPressed: () => Get.toNamed(Routes.PROFILE),
                        icon: Icon(Icons.settings_outlined,
                            color: Colors.white, size: TSizes.iconMd))
                  ])
                ],
              ),
            ),

            // Grid View (Mapped to Popular Songs for now)
            Obx(() {
              if (controller.isLoadingPopular.value) {
                return SizedBox(
                    height: 100,
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.green)));
              }

              final items = controller.popularSongs.take(6).toList();

              return LayoutBuilder(builder: (context, constraints) {
                // Responsive Grid Calculation
                // Mobile: 2 columns, Tablet: 3-4 columns
                final screenWidth = TDeviceUtils.screenWidth(context);
                final crossAxisCount = screenWidth > 600 ? 4 : 2;
                // Calculate item width based on available space and padding
                final availableWidth = screenWidth -
                    (TSizes.defaultSpace * 2) -
                    TSizes.spaceBtwItems; // horizontal padding + spacing
                final itemWidth = availableWidth / crossAxisCount;
                final itemHeight = 60.0;
                final aspectRatio = itemWidth / itemHeight;

                return GridView.builder(
                  padding: EdgeInsets.only(
                      left: TSizes.defaultSpace,
                      right: TSizes.defaultSpace,
                      top: TSizes.sm),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: TSizes.sm,
                      crossAxisSpacing: TSizes.sm,
                      childAspectRatio: aspectRatio),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, index) {
                    final song = items[index];
                    return RecentPlaylistContainer(
                      name: song.title,
                      image:
                          song.albumArtUrl ?? "https://via.placeholder.com/150",
                      onTap: () {
                        playerController.playSong(song, queue: items);
                        Get.toNamed(Routes.PLAYER);
                      },
                    );
                  },
                );
              });
            }),

            // Recently Played Section
            Padding(
                padding: EdgeInsets.fromLTRB(TSizes.defaultSpace,
                    TSizes.spaceBtwSections, TSizes.defaultSpace, TSizes.md),
                child: SizedBox(
                  width: double.infinity,
                  child: Text("Recently played",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.fontSizeXxl,
                          color: Colors.white,
                          fontFamily: "SpotifyCircularBold"),
                      textAlign: TextAlign.left),
                )),

            Obx(() {
              if (controller.isLoadingRecent.value) {
                return SizedBox(
                    height: 100,
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.green)));
              }
              final recents = controller.recentlyPlayed;
              if (recents.isEmpty) return const SizedBox.shrink();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: TSizes.sm),
                child: Row(
                  children: recents
                      .map((song) => Padding(
                            padding: EdgeInsets.only(right: TSizes.sm),
                            child: RecentlyPlayedCard(
                              name: song.title,
                              image: song.albumArtUrl ??
                                  "https://via.placeholder.com/150",
                              borderRadius: TSizes
                                  .cardRadiusLg, // Circular profile style approx
                              onTap: () {
                                playerController.playSong(song);
                                Get.toNamed(Routes.PLAYER);
                              },
                            ),
                          ))
                      .toList(),
                ),
              );
            }),

            // "Made For You" Section
            Padding(
                padding: EdgeInsets.fromLTRB(TSizes.defaultSpace,
                    TSizes.spaceBtwSections, TSizes.defaultSpace, TSizes.md),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Made For You",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.fontSizeXxl,
                        color: Colors.white,
                        fontFamily: "SpotifyCircularBold"),
                    textAlign: TextAlign.left,
                  ),
                )),
            Obx(() {
              if (controller.isLoadingSongs.value) {
                return SizedBox(
                    height: 100,
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.green)));
              }
              final songs = controller.songs;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: TSizes.sm),
                child: Row(
                  children: songs
                      .map((song) => Padding(
                            padding: EdgeInsets.only(right: TSizes.sm),
                            child: RecentlyPlayedCard(
                              name: song.title,
                              image: song.albumArtUrl ??
                                  "https://via.placeholder.com/150",
                              borderRadius:
                                  TSizes.cardRadiusLg, // Square for albums
                              onTap: () {
                                playerController.playSong(song, queue: songs);
                                Get.toNamed(Routes.PLAYER);
                              },
                            ),
                          ))
                      .toList(),
                ),
              );
            }),

            SizedBox(
                height:
                    TSizes.bottomNavBarHeight * 2), // Spacing for MiniPlayer
          ],
        ),
      ),
    );
  }

  String _getGreeting(AuthController controller) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
