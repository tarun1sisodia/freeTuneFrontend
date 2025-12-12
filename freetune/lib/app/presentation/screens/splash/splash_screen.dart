import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait a bit for the UI to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final authController = Get.find<AuthController>();

      // Now check current user
      await authController.checkCurrentUser();

      // Wait a bit more to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Navigate based on auth state
      if (mounted) {
        if (authController.isAuthenticated.value) {
          Get.offAllNamed(Routes.MAIN);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      }
    } catch (e) {
      print('Error during splash initialization: $e');
      // On error, just go to login
      if (mounted) {
        Get.offAllNamed(Routes.LOGIN);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading FreeTune... Keep on Loop'),
          ],
        ),
      ),
    );
  }
}
