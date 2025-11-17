import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class ForgotPasswordScreen extends GetView<AuthController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Future<void> handleForgotPassword() async {
      if (formKey.currentState?.validate() ?? false) {
        final success = await controller.forgotPassword(emailController.text.trim());
        if (success) {
          Get.snackbar(
            'Success',
            'Password reset email sent. Please check your inbox.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.7),
            colorText: Colors.white,
          );
          Get.back();
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(height: 24.0),
                Text(
                  'Reset Your Password',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(color: context.theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 24.0),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : handleForgotPassword,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Reset Link', style: TextStyle(fontSize: 18)),
                )),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
