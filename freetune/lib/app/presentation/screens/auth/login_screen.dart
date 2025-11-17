import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Future<void> handleLogin() async {
      if (formKey.currentState?.validate() ?? false) {
        final success = await controller.login(
          emailController.text.trim(),
          passwordController.text,
        );
        if (success) {
          Get.offAllNamed(Routes.HOME);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')), // AppBar will use the theme defined in ThemeConfig
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open,
                  size: 100,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Welcome Back!',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Sign in to continue to FreeTune',
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
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16.0),
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white) // Use theme's onPrimary color
                      : const Text('Login', style: TextStyle(fontSize: 18)),
                )),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: context.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.REGISTER),
                      child: const Text('Register'),
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
