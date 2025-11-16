import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/player/player_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/playlists/playlists_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

import '../bindings/auth_binding.dart';
import '../bindings/initial_binding.dart'; // Assuming initial binding for splash

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: AppBindings(), // Initial binding for core services
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PLAYER,
      page: () => const PlayerScreen(),
      binding: PlayerBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.PLAYLISTS,
      page: () => const PlaylistsScreen(),
      // binding: PlaylistsBinding(), // Will create later
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      // binding: ProfileBinding(), // Will create later
    ),
    // Add other pages and their bindings here
  ];
}