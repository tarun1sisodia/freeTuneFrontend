/*       initialBinding: AppBindings(), // Set up all dependencies
      home: AuthWrapper(), // A new widget to handle auth state
      getPages: AppPages.routes, // Use the routes defined in AppPages
    );
  }
}

class AuthWrapper extends GetView<AuthController> {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx will automatically rebuild when controller.user or controller.isLoading changes
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      } else if (controller.user.value != null) {
        return const MainScreen(); // Navigate to MainScreen
      } else {
        return const LoginScreen();
      }
    });
  }
}
 */