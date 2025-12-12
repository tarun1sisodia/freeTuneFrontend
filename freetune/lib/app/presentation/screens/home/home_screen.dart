import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/songs_controller.dart';
import '../../controllers/audio_player_controller.dart';
import '../../widgets/home/recent_playlist_container.dart';
import '../../widgets/home/recently_played_card.dart';
import '../../widgets/player/mini_player.dart'; // Keep existing MiniPlayer for logic, maybe style it later?
// Or use the one from code. Let's use the layout from code but bound to controller.

class HomeScreen extends GetView<SongController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is loaded
    final authController = Get.find<AuthController>();
    final playerController = Get.find<AudioPlayerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            primary: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 35),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(_getGreeting(authController),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                                fontFamily: "SpotifyCircularBold")),
                      ),
                      Row(children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.notifications_none_sharp,
                                color: Colors.white)),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.access_time_sharp,
                                color: Colors.white)),
                        IconButton(
                            onPressed: () => Get.toNamed(Routes.PROFILE),
                            icon: const Icon(Icons.settings_outlined,
                                color: Colors.white))
                      ])
                    ],
                  ),
                ),

                // Grid View (Mapped to Popular Songs for now)
                Obx(() {
                  if (controller.isLoadingPopular.value) {
                    return const SizedBox(
                        height: 100,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.green)));
                  }
                  final items =
                      controller.popularSongs.take(6).toList(); // Show top 6
                  return GridView.builder(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 3.0), // Adjusted aspect ratio
                    primary: false,
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, index) {
                      final song = items[index];
                      return RecentPlaylistContainer(
                        name: song.title,
                        image: song.albumArtUrl ??
                            "https://via.placeholder.com/150",
                        onTap: () {
                          playerController.playSong(song, queue: items);
                          Get.toNamed(Routes.PLAYER);
                        },
                      );
                    },
                  );
                }),

                // Recently Played Section
                const Padding(
                    padding: EdgeInsets.fromLTRB(15, 30, 15, 15),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text("Recently played",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.white,
                              fontFamily: "SpotifyCircularBold"),
                          textAlign: TextAlign.left),
                    )),

                Obx(() {
                  if (controller.isLoadingRecent.value) {
                    return const SizedBox(
                        height: 100,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.green)));
                  }
                  final recents = controller.recentlyPlayed;
                  if (recents.isEmpty) return const SizedBox.shrink();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: recents
                          .map((song) => RecentlyPlayedCard(
                                name: song.title,
                                image: song.albumArtUrl ??
                                    "https://via.placeholder.com/150",
                                borderRadius:
                                    50, // Circular profile style or square? Code said border_radius param.
                                onTap: () {
                                  playerController.playSong(song);
                                  Get.toNamed(Routes.PLAYER);
                                },
                              ))
                          .toList(),
                    ),
                  );
                }),

                // "All Songs" Section (Mapped from Artists/Podcasters in clone)
                const Padding(
                    padding: EdgeInsets.fromLTRB(15, 30, 15, 15),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Made For You",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white,
                            fontFamily: "SpotifyCircularBold"),
                        textAlign: TextAlign.left,
                      ),
                    )),
                Obx(() {
                  if (controller.isLoadingSongs.value) {
                    return const SizedBox(
                        height: 100,
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.green)));
                  }
                  final songs = controller.songs;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: songs
                          .map((song) => RecentlyPlayedCard(
                                name: song.title,
                                image: song.albumArtUrl ??
                                    "https://via.placeholder.com/150",
                                borderRadius: 5, // Square for albums
                                onTap: () {
                                  playerController.playSong(song, queue: songs);
                                  Get.toNamed(Routes.PLAYER);
                                },
                              ))
                          .toList(),
                    ),
                  );
                }),

                const SizedBox(height: 140), // Spacing for MiniPlayer
              ],
            ),
          ),

          // Mini Player
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child:
                MiniPlayer(), // Using existing MiniPlayer which we should style to match Spotify-Clone if needed.
            // For now, reusing the structure ensures logic (play/pause binding) is correct.
          ),
        ],
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
