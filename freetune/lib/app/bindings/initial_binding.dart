import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/remote/api_client.dart';
import '../data/datasources/local/isar_database.dart';
import '../data/datasources/local/preferences_storage.dart';

import '../data/datasources/remote/auth_api.dart';
import '../data/datasources/remote/songs_api.dart';
import '../data/datasources/remote/playlists_api.dart';
import '../data/datasources/remote/recommendations_api.dart';
import '../data/datasources/remote/analytics_api.dart';

import '../data/datasources/local/cache_manager.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/song_repository.dart';
import '../data/repositories/playlist_repository.dart';
import '../data/repositories/recommendation_repository.dart';
import '../data/repositories/analytics_repository.dart';

import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/song_usecases.dart';
import '../presentation/controllers/auth_controller.dart';
import '../services/analytics/analytics_service.dart';
import '../services/audio/audio_player_service.dart';
import '../services/network/network_service.dart';


class AppBindings implements Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize SharedPreferences first as it's used by other dependencies
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put<PreferencesStorage>(PreferencesStorage(Get.find()), permanent: true);

    // Core API Client
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);

    // Isar Database
    final isar = await IsarDatabase.getInstance();
    Get.put<Isar>(isar, permanent: true);
    Get.put<CacheManager>(CacheManager(Get.find()), permanent: true);

    // Remote Data Sources (APIs)
    Get.lazyPut<AuthApi>(() => AuthApi(Get.find<ApiClient>().dio), fenix: true);
    Get.lazyPut<SongsApi>(() => SongsApi(Get.find<ApiClient>().dio), fenix: true);
    Get.lazyPut<PlaylistsApi>(() => PlaylistsApi(Get.find<ApiClient>().dio), fenix: true);
    Get.lazyPut<RecommendationsApi>(() => RecommendationsApi(Get.find<ApiClient>().dio), fenix: true);
    Get.lazyPut<AnalyticsApi>(() => AnalyticsApi(Get.find<ApiClient>().dio), fenix: true);

    // Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find(), Get.find()), fenix: true);
    Get.lazyPut<SongRepository>(() => SongRepositoryImpl(Get.find(), Get.find()), fenix: true);
    Get.lazyPut<PlaylistRepository>(() => PlaylistRepositoryImpl(Get.find(), Get.find()), fenix: true);
    Get.lazyPut<RecommendationRepository>(() => RecommendationRepositoryImpl(Get.find()), fenix: true);
    Get.lazyPut<AnalyticsRepository>(() => AnalyticsRepositoryImpl(Get.find()), fenix: true);

    // Use Cases
    Get.lazyPut(() => LoginUserUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => RegisterUserUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => GetCurrentUserUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => LogoutUserUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => ForgotPasswordUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => ChangePasswordUseCase(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => GetSongsUseCase(Get.find<SongRepository>()), fenix: true);
    Get.lazyPut(() => SearchSongsUseCase(Get.find<SongRepository>()), fenix: true);
    Get.lazyPut(() => GetStreamUrlUseCase(Get.find<SongRepository>()), fenix: true);
    Get.lazyPut(() => TrackPlayUseCase(Get.find<SongRepository>()), fenix: true);
    Get.lazyPut(() => TrackPlaybackUseCase(Get.find<SongRepository>()), fenix: true);
    Get.lazyPut(() => GetSongDetailsUseCase(Get.find<SongRepository>()), fenix: true);

    // Services
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<AnalyticsService>(AnalyticsService(Get.find()), permanent: true);
    Get.put<AudioPlayerService>(AudioPlayerService(Get.find(), Get.find()), permanent: true);

    // Initialize AuthController on app start for splash screen
    Get.put<AuthController>(
      AuthController(
        loginUserUseCase: Get.find<LoginUserUseCase>(),
        registerUserUseCase: Get.find<RegisterUserUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
        logoutUserUseCase: Get.find<LogoutUserUseCase>(),
        forgotPasswordUseCase: Get.find<ForgotPasswordUseCase>(),
        changePasswordUseCase: Get.find<ChangePasswordUseCase>(),
      ),
      permanent: true,
    );
  }
}
