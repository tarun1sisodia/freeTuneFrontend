import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/profile/profile_header.dart';

import '../../widgets/common/basic_list_tile.dart';
import '../../widgets/common/basic_app_bar.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const BasicAppBar(
        title: Text('Profile'),
        hideBack: true,
      ),
      body: Obx(() {
        final user = controller.currentUser;
        if (user == null) {
          return const Center(
            child: Text('User not logged in.',
                style: TextStyle(color: Colors.white)),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshStats();
          },
          color: Colors.green,
          backgroundColor: Colors.grey[900],
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                ProfileHeader(
                  profileImageUrl: user.profileImageUrl,
                  username: user.username ?? 'User',
                  email: user.email,
                  onEditPressed: () {
                    Get.toNamed(Routes.EDIT_PROFILE);
                  },
                ),
                const SizedBox(height: 32),

                // Statistics Section (Simplified for sharp look)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Played',
                          controller.totalSongsPlayed.value.toString()),
                      _buildVerticalDivider(),
                      _buildStatItem('Favorites',
                          controller.totalFavorites.value.toString()),
                      _buildVerticalDivider(),
                      _buildStatItem('Playlists',
                          controller.totalPlaylists.value.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Settings Section
                _buildSectionHeader(context, 'Settings'),
                BasicListTile(
                  icon: Icons.high_quality,
                  title: 'Audio Quality',
                  subtitle: controller.audioQuality.value.toUpperCase(),
                  onTap: () => _showAudioQualityDialog(context),
                ),
                BasicListTile(
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: controller.selectedTheme.value.capitalize,
                  onTap: () => _showThemeDialog(context),
                ),
                BasicListTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: controller.notificationsEnabled.value
                      ? 'Enabled'
                      : 'Disabled',
                  trailing: Switch(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                    activeColor: Colors.green,
                  ),
                ),

                const SizedBox(height: 24),

                // Creator Section
                _buildSectionHeader(context, 'Creator'),
                BasicListTile(
                  icon: Icons.upload_file,
                  title: 'Upload Song',
                  iconColor: Colors.green,
                  onTap: () {
                    Get.toNamed(Routes.UPLOAD);
                  },
                ),

                const SizedBox(height: 24),

                // Account Section
                _buildSectionHeader(context, 'Account'),
                BasicListTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
                ),
                BasicListTile(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Clear Cache',
                  subtitle: 'Free up space',
                  onTap: () => _showClearCacheDialog(context),
                ),

                const SizedBox(height: 32),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Center(
                      child: Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[800],
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Audio Quality', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('Low', '64 kbps'),
            _buildQualityOption('Medium', '128 kbps'),
            _buildQualityOption('High', '320 kbps'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String quality, String bitrate) {
    return Obx(() => RadioListTile<String>(
          title: Text(quality, style: const TextStyle(color: Colors.white)),
          subtitle: Text(bitrate, style: TextStyle(color: Colors.grey[400])),
          value: quality.toLowerCase(),
          groupValue: controller.audioQuality.value,
          onChanged: (value) {
            if (value != null) {
              controller.updateAudioQuality(value);
              Get.back();
            }
          },
          activeColor: Colors.green,
        ));
  }

  void _showThemeDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Select Theme', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light'),
            _buildThemeOption('Dark'),
            _buildThemeOption('System'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme) {
    return Obx(() => RadioListTile<String>(
          title: Text(theme, style: const TextStyle(color: Colors.white)),
          value: theme.toLowerCase(),
          groupValue: controller.selectedTheme.value,
          onChanged: (value) {
            if (value != null) {
              controller.updateTheme(value);
              Get.back();
            }
          },
          activeColor: Colors.green,
        ));
  }

  void _showClearCacheDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all cached songs and data. You will need to re-download them. Continue?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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
