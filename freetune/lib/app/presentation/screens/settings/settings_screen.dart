import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../widgets/common/basic_app_bar.dart';
import '../../widgets/common/basic_list_tile.dart';
import '../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SettingsScreen extends GetView<ProfileController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const BasicAppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSectionHeader('Account'),
            BasicListTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => Get.toNamed('${Routes.PROFILE}/edit'),
            ),
            BasicListTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
            ),
            _buildDivider(),
            _buildSectionHeader('Preferences'),
            BasicListTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              trailing: Obx(() => Switch(
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.toggleNotifications,
                    activeThumbColor: Colors.green,
                    activeTrackColor: Colors.green.withOpacity(0.5),
                  )),
            ),
            Obx(() => BasicListTile(
                  icon: Icons.graphic_eq,
                  title: 'Audio Quality',
                  subtitle: controller.audioQuality.value.toUpperCase(),
                  onTap: () => _showAudioQualityDialog(),
                )),
            Obx(() => BasicListTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: controller.selectedTheme.value.capitalize,
                  onTap: () => _showThemeDialog(),
                )),
            _buildDivider(),
            _buildSectionHeader('Storage'),
            BasicListTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              onTap: () => _confirmClearCache(),
            ),
            _buildDivider(),
            _buildSectionHeader('About'),
            BasicListTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => Get.snackbar('Info', 'Privacy Policy coming soon',
                  colorText: Colors.white, backgroundColor: Colors.grey[900]),
            ),
            BasicListTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => Get.snackbar('Info', 'Terms of Service coming soon',
                  colorText: Colors.white, backgroundColor: Colors.grey[900]),
            ),
            const BasicListTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
            ),
            _buildDivider(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextButton(
                onPressed: () => _confirmLogout(),
                child: const Text(
                  'Log out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey, thickness: 0.5),
    );
  }

  void _showAudioQualityDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Audio Quality', style: TextStyle(color: Colors.white)),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRadioOption('Low', 'low'),
                _buildRadioOption('Medium', 'medium'),
                _buildRadioOption('High', 'high'),
              ],
            )),
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: controller.audioQuality.value,
      onChanged: (val) {
        if (val != null) {
          controller.updateAudioQuality(val);
          Get.back();
        }
      },
      activeColor: Colors.green,
    );
  }

  void _showThemeDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Theme', style: TextStyle(color: Colors.white)),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption('Dark', 'dark'),
                _buildThemeOption('Light', 'light'),
              ],
            )),
      ),
    );
  }

  Widget _buildThemeOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: controller.selectedTheme.value,
      onChanged: (val) {
        if (val != null) {
          controller.updateTheme(val);
          Get.back();
        }
      },
      activeColor: Colors.green,
    );
  }

  void _confirmClearCache() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Clear Cache?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all cached songs and data. You may need to re-download content.',
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
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
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
              Get.find<AuthController>().logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
