import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/songs_controller.dart';
import '../../widgets/song/song_tile.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/empty_state.dart';

/// Spotify-inspired HomeScreen with modern, clean UI
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final songController = Get.find<SongController>();

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.UPLOAD),
        backgroundColor: Colors.green,
        child: const Icon(Icons.upload, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => songController.refreshAll(),
          color: Colors.green,
          backgroundColor: Colors.grey[900],
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(authController),

              // Popular Songs Section
              _buildPopularSection(songController),

              // Recently Played Section
              _buildRecentlyPlayedSection(songController),

              // All Songs Section
              _buildAllSongsSection(songController),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom app bar
  SliverAppBar _buildAppBar(AuthController authController) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade800.withOpacity(0.6),
                Colors.black,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    'Welcome back, ${_getDisplayName(authController)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(height: 4),
              Text(
                'What do you want to listen to today?',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => Get.toNamed(Routes.SEARCH),
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () => Get.toNamed(Routes.PROFILE),
        ),
      ],
    );
  }

  /// Build popular songs horizontal section
  Widget _buildPopularSection(SongController controller) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Right Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to see all popular
                  },
                  child: Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.isLoadingPopular.value) {
              return const SizedBox(
                height: 200,
                child: Center(child: SmallLoadingIndicator()),
              );
            }

            if (controller.popularError.value != null) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    controller.popularError.value!,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              );
            }

            if (controller.popularSongs.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No popular songs available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: controller.popularSongs.length,
                itemBuilder: (context, index) {
                  final song = controller.popularSongs[index];
                  return _buildPopularSongCard(song, controller);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build recently played section
  Widget _buildRecentlyPlayedSection(SongController controller) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoadingRecent.value ||
            controller.recentlyPlayed.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Played',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to see all recent
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: controller.recentlyPlayed.take(10).length,
                itemBuilder: (context, index) {
                  final song = controller.recentlyPlayed[index];
                  return _buildRecentSongCard(song, controller);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Build all songs list section
  Widget _buildAllSongsSection(SongController controller) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'All Songs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() {
            if (controller.isLoadingSongs.value && controller.songs.isEmpty) {
              return const SizedBox(
                height: 400,
                child: LoadingIndicator(message: 'Loading songs...'),
              );
            }

            if (controller.error.value != null && controller.songs.isEmpty) {
              return SizedBox(
                height: 400,
                child: ErrorView(
                  message: controller.error.value!,
                  onRetry: () => controller.fetchSongs(refresh: true),
                ),
              );
            }

            if (controller.songs.isEmpty) {
              return const SizedBox(
                height: 400,
                child: EmptyState(
                  message: 'No songs available',
                  icon: Icons.music_note,
                ),
              );
            }

            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.songs.length,
                  itemBuilder: (context, index) {
                    final song = controller.songs[index];
                    return Container(
                      color: Colors.black,
                      child: SongTile(
                        song: song,
                        onTap: () {
                          // TODO: Play song
                          Get.snackbar(
                            'Playing',
                            song.title,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.grey[900],
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        onFavorite: () =>
                            controller.toggleFavorite(song.songId),
                        onMore: () => _showSongOptions(song),
                      ),
                    );
                  },
                ),
                if (controller.isLoadingMore.value)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SmallLoadingIndicator(),
                  ),
                if (!controller.isLoadingMore.value &&
                    controller.songs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => controller.loadMoreSongs(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Load More'),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Build popular song card (large horizontal card)
  Widget _buildPopularSongCard(dynamic song, SongController controller) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Play song
            Get.snackbar(
              'Playing',
              song.title,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.grey[900],
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album art
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.albumArtUrl != null
                    ? Image.network(
                        song.albumArtUrl!,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(160),
                      )
                    : _buildPlaceholder(160),
              ),
              const SizedBox(height: 8),
              // Song title
              Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Artist name
              Text(
                song.artist,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build recent song card (smaller horizontal card)
  Widget _buildRecentSongCard(dynamic song, SongController controller) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Play song
          },
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: song.albumArtUrl != null
                    ? Image.network(
                        song.albumArtUrl!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(140),
                      )
                    : _buildPlaceholder(140),
              ),
              const SizedBox(height: 6),
              Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                song.artist,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build placeholder for missing album art
  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.grey[700],
        size: size * 0.4,
      ),
    );
  }

  /// Show song options bottom sheet
  void _showSongOptions(dynamic song) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to playlist',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.PLAYLISTS);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                // TODO: Share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('Song details',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                // TODO: Show song details
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Get display name from auth controller
  String _getDisplayName(AuthController controller) {
    final user = controller.user.value;
    if (user?.username != null && user!.username!.isNotEmpty) {
      return user.username!;
    }
    if (user?.email != null) {
      return user!.email.split('@')[0];
    }
    return 'Guest';
  }
}
