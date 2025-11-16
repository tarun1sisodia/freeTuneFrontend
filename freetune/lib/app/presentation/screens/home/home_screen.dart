import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('Welcome, ${controller.user.value?.username ?? controller.user.value?.email ?? 'Guest'}!')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.PLAYLISTS);
              },
              child: const Text('Go to Playlists'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.PROFILE);
              },
              child: const Text('Go to Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.PLAYER);
              },
              child: const Text('Go to Player (Placeholder)'),
            ),
          ],
        ),
      ),
    );
  }
}