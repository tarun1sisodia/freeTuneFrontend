import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Future<void> handleRegister() async {
      if (formKey.currentState?.validate() ?? false) {
        if (passwordController.text != confirmPasswordController.text) {
          Get.snackbar(
            'Error',
            'Passwords do not match',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.7),
            colorText: Colors.white,
          );
          return;
        }
        
        final success = await controller.register(
          emailController.text.trim(),
          passwordController.text,
          username: usernameController.text.trim().isEmpty ? null : usernameController.text.trim(),
        );
        
        if (success) {
          Get.offAllNamed(Routes.HOME);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add,
                  size: 100,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Create Your Account',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Join FreeTune and start listening!',
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
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username (Optional)',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 18)),
                )),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: context.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
