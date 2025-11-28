import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SettingsScreen extends GetView<ProfileController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Account'),
          _buildListTile(
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () => Get.toNamed(Routes.PROFILE + '/edit'),
          ),
          _buildListTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notifications',
            value: controller.notificationsEnabled.value,
            onChanged: controller.toggleNotifications,
          ),
          _buildListTile(
            icon: Icons.music_note,
            title: 'Audio Quality',
            subtitle: controller.audioQuality.value.toUpperCase(),
            onTap: () => _showAudioQualityDialog(),
          ),
          _buildListTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: controller.selectedTheme.value.capitalize,
            onTap: () => _showThemeDialog(),
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildSectionHeader('Storage'),
          _buildListTile(
            icon: Icons.delete_sweep,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _confirmClearCache(),
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildSectionHeader('About'),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Navigate to privacy policy
              Get.snackbar('Info', 'Privacy Policy coming soon');
            },
          ),
          _buildListTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              // TODO: Navigate to terms
              Get.snackbar('Info', 'Terms of Service coming soon');
            },
          ),
          _buildListTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildSectionHeader('Danger Zone'),
          _buildListTile(
            icon: Icons.logout,
            title: 'Logout',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _confirmLogout(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.green),
      title: Text(title, style: TextStyle(color: titleColor ?? Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[600]))
          : null,
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: Colors.grey[600])
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => SwitchListTile(
          secondary: Icon(icon, color: Colors.green),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          value: controller.notificationsEnabled.value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ));
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
