import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class ChangePasswordScreen extends GetView<AuthController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Future<void> handleChangePassword() async {
      if (formKey.currentState?.validate() ?? false) {
        if (newPasswordController.text != confirmPasswordController.text) {
          Get.snackbar(
            'Error',
            'New passwords do not match',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.7),
            colorText: Colors.white,
          );
          return;
        }
        
        final success = await controller.changePassword(
          currentPasswordController.text,
          newPasswordController.text,
        );
        
        if (success) {
          Get.snackbar(
            'Success',
            'Password changed successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.7),
            colorText: Colors.white,
          );
          Get.back();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.vpn_key,
                  size: 100,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Update Your Password',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Change Password', style: TextStyle(fontSize: 18)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
