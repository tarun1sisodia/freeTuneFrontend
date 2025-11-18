import 'package:get/get.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/change_password_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/player/player_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/playlists/playlists_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';

import '../bindings/auth_binding.dart';
import '../bindings/initial_binding.dart';
import '../bindings/player_binding.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: AppBindings(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordScreen(),
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
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
    ),
  ];
}
