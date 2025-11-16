import 'package:get/get.dart';

import '../data/datasources/remote/api_client.dart';
import '../data/datasources/local/isar_database.dart';
import '../data/datasources/local/cache_manager.dart';

// APIs
import '../data/datasources/remote/auth_api.dart';
import '../data/datasources/remote/playlists_api.dart';
import '../data/datasources/remote/songs_api.dart';
import '../data/datasources/remote/recommendations_api.dart';
import '../data/datasources/remote/analytics_api.dart';

// Repositories
import '../data/repositories/auth_repository.dart';
import '../data/repositories/playlist_repository.dart';
import '../data/repositories/song_repository.dart';
import '../data/repositories/recommendation_repository.dart';
import '../data/repositories/analytics_repository.dart';

// Services
import '../services/audio/audio_player_service.dart';

// Controllers (assuming paths for example purpose)
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/audio_player_controller.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/songs_controller.dart';

// Bindings for feature screens
import 'auth_binding.dart';
import 'home_binding.dart';
import 'player_binding.dart';
// (If you have additional bindings for search, playlist, analytics, recommendation, etc import them here.)

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    // Core (Local storage, cache, etc.)
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    final isar = await IsarDatabase.getInstance();
    Get.put(isar, permanent: true);
    Get.lazyPut<CacheManager>(() => CacheManager(), fenix: true);

    //== APIs ==
    Get.lazyPut<AuthApi>(() => AuthApi(Get.find<ApiClient>().dio), fenix: true);
    Get.lazyPut<PlaylistsApi>(() => PlaylistsApi(Get.find<ApiClient>().dio),
        fenix: true);
    Get.lazyPut<SongsApi>(() => SongsApi(Get.find<ApiClient>().dio),
        fenix: true);
    Get.lazyPut<RecommendationsApi>(
        () => RecommendationsApi(Get.find<ApiClient>().dio),
        fenix: true);
    Get.lazyPut<AnalyticsApi>(() => AnalyticsApi(Get.find<ApiClient>().dio),
        fenix: true);

    //== Repositories ==
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(Get.find<AuthApi>(), Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<PlaylistRepository>(
      () => PlaylistRepository(Get.find<PlaylistsApi>()),
      fenix: true,
    );
    Get.lazyPut<SongRepository>(
      () => SongRepository(Get.find<SongsApi>(), Get.find<CacheManager>()),
      fenix: true,
    );
    Get.lazyPut<RecommendationRepository>(
      () => RecommendationRepository(Get.find<RecommendationsApi>()),
      fenix: true,
    );
    Get.lazyPut<AnalyticsRepository>(
      () => AnalyticsRepository(Get.find<AnalyticsApi>()),
      fenix: true,
    );

    //== Services ==
    Get.lazyPut<AudioPlayerService>(
      () => AudioPlayerService(
          Get.find<SongRepository>(), Get.find<AnalyticsRepository>()),
      fenix: true,
    );
    // If you have other core services (e.g., analytics, preferences, etc.), bind similarly.

    //== Controllers ==
    // Bind AuthController and others as singleton if used across the app
    Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthRepository>()),
        fenix: true);

    Get.lazyPut<AudioPlayerController>(
      () => AudioPlayerController(Get.find<AudioPlayerService>()),
      fenix: true,
    );

    // Home and Songs Controllers (adapt arguments as needed)
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<SongRepository>(),
        Get.find<PlaylistRepository>(),
        Get.find<RecommendationRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<SongsController>(
      () => SongsController(Get.find<SongRepository>()),
      fenix: true,
    );

    // You could also auto-bind other controllers, analytics, recommendation controllers, etc as your app grows.

    //== Bindings for features (only import and call on page routes) ==
    // (These would be used via GetPage bindings, not here, just imports above for centralized organization.)
    // AuthBinding(), HomeBinding(), PlayerBinding(), etc.
  }
}
