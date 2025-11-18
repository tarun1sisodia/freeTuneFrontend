import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/config/theme_config.dart';
import 'app/presentation/controllers/auth_controller.dart';
import 'app/presentation/screens/auth/login_screen.dart';
import 'app/presentation/screens/home/home_screen.dart';

class FreeTuneApp extends StatelessWidget {
  const FreeTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FreeTune',
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: AppBindings(), // Set up all dependencies
      home: const AuthWrapper(), // A new widget to handle auth state
      getPages: [
        // Define named routes here
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.find with fallback to handle initialization
    try {
      final AuthController controller = Get.find<AuthController>();
      // Obx will automatically rebuild when controller.user or controller.isLoading changes
      return Obx(() {
        if (controller.isLoading.value) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (controller.user.value != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      });
    } catch (e) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
