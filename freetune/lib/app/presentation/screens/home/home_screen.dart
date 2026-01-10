import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/songs_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/home/recent_playlist_container.dart';
import '../../widgets/home/recently_played_card.dart';
import '../../../core/utils/app_sizes.dart';

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
            SizedBox(height: AppSizes.h(35)),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
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
                              fontSize: AppSizes.sp(25),
                              color: Colors.white,
                              fontFamily: "SpotifyCircularBold")),
                    ),
                  ),
                  Row(children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications_none_sharp,
                            color: Colors.white, size: AppSizes.iconSize)),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.access_time_sharp,
                            color: Colors.white, size: AppSizes.iconSize)),
                    IconButton(
                        onPressed: () => Get.toNamed(Routes.PROFILE),
                        icon: Icon(Icons.settings_outlined,
                            color: Colors.white, size: AppSizes.iconSize))
                  ])
                ],
              ),
            ),

            // Grid View (Mapped to Popular Songs for now)
            Obx(() {
              if (controller.isLoadingPopular.value) {
                return SizedBox(
                    height: AppSizes.h(100),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.green)));
              }

              final items = controller.popularSongs.take(6).toList();

              return LayoutBuilder(builder: (context, constraints) {
                // Responsive Grid Calculation
                // Mobile: 2 columns, Tablet: 3-4 columns
                final screenWidth = AppSizes.width;
                final crossAxisCount = screenWidth > 600 ? 4 : 2;
                // Calculate item width based on available space and padding
                final availableWidth = screenWidth -
                    (AppSizes.padding * 2) -
                    AppSizes.w(10); // horizontal padding + spacing
                final itemWidth = availableWidth / crossAxisCount;
                final itemHeight = AppSizes.h(60);
                final aspectRatio = itemWidth / itemHeight;

                return GridView.builder(
                  padding: EdgeInsets.only(
                      left: AppSizes.padding,
                      right: AppSizes.padding,
                      top: AppSizes.h(10)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSizes.h(10),
                      crossAxisSpacing: AppSizes.w(10),
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
                padding: EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.h(30),
                    AppSizes.padding, AppSizes.h(15)),
                child: SizedBox(
                  width: double.infinity,
                  child: Text("Recently played",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.sp(25),
                          color: Colors.white,
                          fontFamily: "SpotifyCircularBold"),
                      textAlign: TextAlign.left),
                )),

            Obx(() {
              if (controller.isLoadingRecent.value) {
                return SizedBox(
                    height: AppSizes.h(100),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.green)));
              }
              final recents = controller.recentlyPlayed;
              if (recents.isEmpty) return const SizedBox.shrink();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w(10)),
                child: Row(
                  children: recents
                      .map((song) => Padding(
                            padding: EdgeInsets.only(right: AppSizes.w(10)),
                            child: RecentlyPlayedCard(
                              name: song.title,
                              image: song.albumArtUrl ??
                                  "https://via.placeholder.com/150",
                              borderRadius: 50, // Circular profile style
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

            // "All Songs" Section (Mapped from Artists/Podcasters in clone)
            Padding(
                padding: EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.h(30),
                    AppSizes.padding, AppSizes.h(15)),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Made For You",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.sp(25),
                        color: Colors.white,
                        fontFamily: "SpotifyCircularBold"),
                    textAlign: TextAlign.left,
                  ),
                )),
            Obx(() {
              if (controller.isLoadingSongs.value) {
                return SizedBox(
                    height: AppSizes.h(100),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.green)));
              }
              final songs = controller.songs;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.w(10)),
                child: Row(
                  children: songs
                      .map((song) => Padding(
                            padding: EdgeInsets.only(right: AppSizes.w(10)),
                            child: RecentlyPlayedCard(
                              name: song.title,
                              image: song.albumArtUrl ??
                                  "https://via.placeholder.com/150",
                              borderRadius: 5, // Square for albums
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

            SizedBox(height: AppSizes.h(140)), // Spacing for MiniPlayer
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
