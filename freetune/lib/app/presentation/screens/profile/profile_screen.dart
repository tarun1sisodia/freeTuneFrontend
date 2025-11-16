import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = controller.user.value;
        if (user == null) {
          return const Center(child: Text('User not logged in.'));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Username: ${user.username ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.logout(),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      }),
    );
  }
}