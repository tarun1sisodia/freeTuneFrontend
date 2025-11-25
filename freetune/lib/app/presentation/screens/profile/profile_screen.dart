import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_stat_card.dart';
import '../../widgets/profile/profile_menu_item.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final user = controller.currentUser;
        if (user == null) {
          return const Center(
            child: Text('User not logged in.'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshStats();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                ProfileHeader(
                  profileImageUrl: user.profileImageUrl,
                  username: user.username ?? 'User',
                  email: user.email,
                  onEditPressed: () {
                    // TODO: Navigate to edit profile
                    Get.snackbar(
                      'Coming Soon',
                      'Profile editing will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Statistics Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Stats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              icon: Icons.music_note,
                              label: 'Songs Played',
                              value:
                                  controller.totalSongsPlayed.value.toString(),
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ProfileStatCard(
                              icon: Icons.favorite,
                              label: 'Favorites',
                              value: controller.totalFavorites.value.toString(),
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ProfileStatCard(
                              icon: Icons.playlist_play,
                              label: 'Playlists',
                              value: controller.totalPlaylists.value.toString(),
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Audio Quality
                ProfileMenuItem(
                  icon: Icons.high_quality,
                  title: 'Audio Quality',
                  subtitle: controller.audioQuality.value.toUpperCase(),
                  onTap: () => _showAudioQualityDialog(context),
                ),

                // Theme
                ProfileMenuItem(
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: controller.selectedTheme.value.capitalize,
                  onTap: () => _showThemeDialog(context),
                ),

                // Notifications
                ProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: controller.notificationsEnabled.value
                      ? 'Enabled'
                      : 'Disabled',
                  trailing: Switch(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                  ),
                ),

                const SizedBox(height: 24),

                // Account Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Change Password
                ProfileMenuItem(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Navigate to change password
                    Get.snackbar(
                      'Coming Soon',
                      'Password change will be available soon',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),

                // Privacy Policy
                ProfileMenuItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),

                // Terms of Service
                ProfileMenuItem(
                  icon: Icons.description,
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Navigate to terms
                  },
                ),

                const SizedBox(height: 24),

                // Storage Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Storage',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),

                // Clear Cache
                ProfileMenuItem(
                  icon: Icons.cleaning_services,
                  title: 'Clear Cache',
                  subtitle: 'Free up storage space',
                  iconColor: Colors.orange,
                  onTap: () => _showClearCacheDialog(context),
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('Low', '64 kbps'),
            _buildQualityOption('Medium', '128 kbps'),
            _buildQualityOption('High', '320 kbps'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityOption(String quality, String bitrate) {
    return Obx(() => RadioListTile<String>(
          title: Text(quality),
          subtitle: Text(bitrate),
          value: quality.toLowerCase(),
          groupValue: controller.audioQuality.value,
          onChanged: (value) {
            if (value != null) {
              controller.updateAudioQuality(value);
              Get.back();
            }
          },
        ));
  }

  void _showThemeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light'),
            _buildThemeOption('Dark'),
            _buildThemeOption('System'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme) {
    return Obx(() => RadioListTile<String>(
          title: Text(theme),
          value: theme.toLowerCase(),
          groupValue: controller.selectedTheme.value,
          onChanged: (value) {
            if (value != null) {
              controller.updateTheme(value);
              Get.back();
            }
          },
        ));
  }

  void _showClearCacheDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove all cached songs and data. You will need to re-download them. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
