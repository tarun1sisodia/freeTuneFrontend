import 'package:get/get.dart';
import '../data/datasources/remote/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../services/audio/audio_player_service.dart';
import '../data/datasources/local/isar_database.dart';
import '../data/datasources/local/cache_manager.dart';
import '../data/datasources/remote/auth_api.dart';
import '../data/datasources/remote/playlists_api.dart';
import '../data/datasources/remote/songs_api.dart';
import '../data/datasources/remote/recommendations_api.dart';
import '../data/datasources/remote/analytics_api.dart';
import '../data/repositories/playlist_repository.dart';
import '../data/repositories/song_repository.dart';
import '../data/repositories/recommendtion_repository.dart';
import '../data/repositories/analytics_repository.dart';

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    // Core
    Get.lazyPut(() => ApiClient(), fenix: true);
    final isar = await IsarDatabase.getInstance();
    Get.put(isar);
    Get.lazyPut(() => CacheManager(), fenix: true);

    // APIs
    Get.lazyPut(() => AuthApi(Get.find<ApiClient>().dio));
    Get.lazyPut(() => PlaylistsApi(Get.find<ApiClient>().dio));
    Get.lazyPut(() => SongsApi(Get.find<ApiClient>().dio));
    Get.lazyPut(() => RecommendationsApi(Get.find<ApiClient>().dio));
    Get.lazyPut(() => AnalyticsApi(Get.find<ApiClient>().dio));

    // Repositories (Singleton)
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthApi>(), Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<PlaylistRepository>(() => PlaylistRepository(Get.find<PlaylistsApi>()), fenix: true);
    Get.lazyPut<SongRepository>(() => SongRepository(Get.find<SongsApi>(), Get.find<CacheManager>()), fenix: true);
    Get.lazyPut<RecommendationRepository>(() => RecommendationRepository(Get.find<RecommendationsApi>()), fenix: true);
    Get.lazyPut<AnalyticsRepository>(() => AnalyticsRepository(Get.find<AnalyticsApi>()), fenix: true);

    // Services (Singleton)
    Get.lazyPut(() => AudioPlayerService(Get.find<SongRepository>(), Get.find<AnalyticsRepository>()), fenix: true);
  }
}
