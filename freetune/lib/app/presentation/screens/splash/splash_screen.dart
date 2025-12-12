import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/configs/assets/app_images.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(AppImages.logo, width: 150),
      ),
    );
  }

  Future<void> _initializeApp() async {
    // Check auth status concurrently with splash delay
    final authController = Get.find<AuthController>();

    // Minimum Splash Duration
    await Future.delayed(const Duration(seconds: 2));

    // Check current user session
    await authController.checkCurrentUser();

    if (mounted) {
      if (authController.isAuthenticated.value) {
        Get.offAllNamed(Routes.MAIN);
      } else {
        Get.offNamed(Routes.SIGNUP_OR_SIGNIN);
      }
    }
  }
}
