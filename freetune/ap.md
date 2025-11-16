Of course! Migrating from Riverpod to GetX involves changing the state management, dependency injection, and routing approach. Here is the completely revised `freetune_getx_guide.md` file, incorporating GetX and ensuring all API integrations align with your backend documentation for a scalable, high-performance application.

---

# 🎵 FreeTune Flutter App (GetX Edition) - Complete Guide

**Based on:** MEMO.md + MEMO_IMPROVEMENTS.md + Backend API Documentation  
**Target:** Ultra-performance music streaming with <1s load times  
**Architecture:** Offline-first, reactive, aggressive caching, adaptive bitrate streaming with GetX

---

## 📋 Table of Contents

1. [Project Structure](#-project-structure)
2. [Dependencies & Setup](#-dependencies--setup)
3. [Core Architecture](#️-core-architecture)
4. [State Management & DI (GetX)](#-state-management--di-getx)
5. [API Integration](#-api-integration)
6. [Caching Strategy](#-caching-strategy)
7. [Audio Player Implementation](#-audio-player-implementation)
8. [UI/UX Components](#-uiux-components)
9. [Screens & Navigation (GetX Routes)](#-screens--navigation-getx-routes)
10. [Performance Optimizations](#-performance-optimizations)
11. [Testing Strategy](#-testing-strategy)
12. [Implementation Checklist](#-implementation-checklist)

---

## 📁 Project Structure

This structure is optimized for GetX, separating controllers (state), bindings (dependency injection), and routes.

```
lib/
├── main.dart                          # App entry point with initial bindings
│
├── app/
│   ├── config/
│   │   ├── app_config.dart            # App-wide configuration
│   │   ├── api_config.dart            # API endpoints & base URLs
│   │   ├── cache_config.dart          # Cache settings (500MB limit)
│   │   └── theme_config.dart          # Light/dark theme
│   │
│   ├── core/
│   │   ├── constants/                 # Constants (keys, endpoints)
│   │   ├── utils/                     # Utilities (logger, formatters)
│   │   ├── exceptions/                # Custom exceptions
│   │   └── mixins/                    # Reusable mixins for controllers
│   │
│   ├── data/
│   │   ├── models/                    # Data Transfer Objects (from API)
│   │   ├── repositories/              # Abstract contracts for data layers
│   │   ├── datasources/               # Remote (API) & Local (DB) sources
│   │   └── mappers/                   # DTO to Entity mappers
│   │
│   ├── domain/
│   │   ├── entities/                  # Core business objects
│   │   └── usecases/                  # Business logic units
│   │
│   ├── presentation/
│   │   ├── controllers/               # GetX controllers (state logic)
│   │   │   ├── auth_controller.dart
│   │   │   ├── audio_player_controller.dart
│   │   │   ├── home_controller.dart
│   │   │   └── search_controller.dart
│   │   │
│   │   ├── screens/                   # UI screens (the "View")
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── player/
│   │   │   └── ...
│   │   │
│   │   └── widgets/                   # Reusable UI widgets
│   │       ├── common/
│   │       ├── song/
│   │       └── player/
│   │
│   ├── bindings/                      # GetX dependency injection bindings
│   │   ├── initial_binding.dart       # Core services (API, DB)
│   │   ├── auth_binding.dart          # Bindings for Auth feature
│   │   ├── home_binding.dart          # Bindings for Home feature
│   │   └── player_binding.dart        # Bindings for Player feature
│   │
│   └── routes/
│       ├── app_pages.dart             # Defines all app routes and their bindings
│       └── app_routes.dart            # Route name constants
│
└── services/                        # Singleton services
    ├── audio/
    │   ├── audio_player_service.dart  # just_audio wrapper
    │   ├── audio_cache_service.dart
    │   └── prefetch_service.dart
    │
    ├── network/
    │   └── network_service.dart
    │
    └── analytics/
        └── analytics_service.dart     # Event tracking
```

---

## 📦 Dependencies & Setup

### `pubspec.yaml`

We replace Riverpod with `get` for state management, routing, and dependency injection.

```yaml
name: freetune
description: Ultra-performance music streaming app with GetX
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management, DI & Routing
  get: ^4.6.6

  # Local Database (Faster than Hive)
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1

  # Audio Player
  just_audio: ^0.9.36
  audio_service: ^0.18.11  # Background playback
  audio_session: ^0.1.18    # Audio session management

  # HTTP Client
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1  # Dev only

  # Caching
  flutter_cache_manager: ^3.3.1
  path_provider: ^2.1.1

  # Storage
  shared_preferences: ^2.2.2

  # Network Detection
  connectivity_plus: ^5.0.2
  network_info_plus: ^4.0.2

  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # Utils
  intl: ^0.18.1
  equatable: ^2.0.5

  # Code Generation
  build_runner: ^2.4.7
  isar_generator: ^3.1.0+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
```

### Setup Commands

```bash
# Install dependencies
flutter pub get

# Generate Isar database code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch
```

---

## 🏗️ Core Architecture

### 1. **API Client Setup** (`app/data/datasources/remote/api_client.dart`)

This remains largely the same, as `Dio` is independent of the state management library.

```dart
// (No changes from original ap.md - this is a solid setup)
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/api_config.dart';

class ApiClient {
  late Dio _dio;
  // ... (rest of the ApiClient implementation remains the same)
  Dio get dio => _dio;
}
```

### 2. **Isar Database Setup** (`app/data/datasources/local/isar_database.dart`)

Isar setup is also independent of state management.

```dart
// (No changes from original ap.md)
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/song/song_model.dart';

class IsarDatabase {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) return _isar!;
    // ... (rest of the IsarDatabase implementation remains the same)
    return _isar!;
  }
}
```

---

## 🔄 State Management & DI (GetX)

We use **GetX Controllers** for state and business logic, and **Bindings** for dependency injection.

### `main.dart` Entry Point

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InitialBinding().dependencies(); // Initialize core services before app runs
  
  runApp(const FreeTuneApp());
}

class FreeTuneApp extends StatelessWidget {
  const FreeTuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FreeTune',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
```

### Initial Binding (`app/bindings/initial_binding.dart`)

This class initializes and injects all singleton services and repositories when the app starts.

```dart
import 'package:get/get.dart';
import '../data/datasources/remote/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../services/audio/audio_player_service.dart';
// ... import other services and repositories

class InitialBinding implements Bindings {
  @override
  Future<void> dependencies() async {
    // Core
    Get.lazyPut(() => ApiClient(), fenix: true);
    final isar = await IsarDatabase.getInstance();
    Get.put(isar);

    // Services (Singleton)
    Get.lazyPut(() => AudioPlayerService(Get.find(), Get.find(), Get.find()), fenix: true);
    // ... other services

    // Repositories (Singleton)
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find(), Get.find()), fenix: true);
    // ... other repositories
  }
}
```

### Auth Controller (`app/presentation/controllers/auth_controller.dart`)

This controller manages authentication state and logic.

```dart
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find();

  final Rx<UserEntity?> user = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    user.value = await _authRepository.getCurrentUser();
    isAuthenticated.value = user.value != null;
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final loggedInUser = await _authRepository.login(email, password);
      user.value = loggedInUser;
      isAuthenticated.value = true;
      return true;
    } catch (e) {
      Get.snackbar('Login Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed('/login');
  }
}
```

### Audio Player Controller (`app/presentation/controllers/audio_player_controller.dart`)

This acts as a bridge between the `AudioPlayerService` and the UI.

```dart
import 'package:get/get.dart';
import '../../services/audio/audio_player_service.dart';
import '../../domain/entities/song_entity.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayerService _audioService = Get.find();

  // Reactive state variables
  Rx<SongEntity?> get currentSong => _audioService.currentSong;
  RxBool get isPlaying => _audioService.playing;
  Rx<Duration> get position => _audioService.position;
  Rx<Duration?> get duration => _audioService.duration;

  // Actions that delegate to the service
  Future<void> playSong(SongEntity song, List<SongEntity> queue) async {
    _audioService.setQueue(queue, startIndex: queue.indexOf(song));
    await _audioService.play(song);
  }

  void pause() => _audioService.pause();
  void resume() => _audioService.resume();
  void seek(Duration position) => _audioService.seek(position);
  void playNext() => _audioService.playNext();
  void playPrevious() => _audioService.playPrevious();
}
```

---

## 🌐 API Integration

The API classes are implemented to match the backend documentation exactly. Here are the full definitions for clarity and completeness.

#### **Authentication APIs** (`app/data/datasources/remote/auth_api.dart`)
```dart
class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // POST /api/v1/auth/register
  Future<AuthResponse> register(...) async { /* ... */ }
  // POST /api/v1/auth/login
  Future<AuthResponse> login(...) async { /* ... */ }
  // GET /api/v1/auth/me
  Future<UserModel> getCurrentUser() async { /* ... */ }
  // ... and all other 11 auth endpoints
}
```

#### **Songs APIs** (`app/data/datasources/remote/songs_api.dart`)
```dart
class SongsApi {
  final Dio _dio;
  SongsApi(this._dio);

  // GET /api/v1/songs
  Future<PaginatedResponse<SongModel>> getSongs(...) async { /* ... */ }
  // GET /api/v1/songs/search
  Future<PaginatedResponse<SongModel>> searchSongs(...) async { /* ... */ }
  // GET /api/v1/songs/:id/stream-url
  Future<StreamUrlResponse> getStreamUrl(...) async { /* ... */ }
  // POST /api/v1/songs/:id/play
  Future<void> trackPlay(...) async { /* ... */ }
  // POST /api/v1/songs/:id/playback
  Future<void> trackPlayback(...) async { /* ... */ }
  // ... and all other 15 song endpoints
}
```

#### **Playlists APIs** (`app/data/datasources/remote/playlists_api.dart`)
```dart
class PlaylistsApi {
  final Dio _dio;
  PlaylistsApi(this._dio);

  // GET /api/v1/playlists
  Future<List<PlaylistModel>> getPlaylists() async { /* ... */ }
  // POST /api/v1/playlists
  Future<PlaylistModel> createPlaylist(...) async { /* ... */ }
  // ... and all other 7 playlist endpoints
}
```

#### **Recommendations APIs** (`app/data/datasources/remote/recommendations_api.dart`)
```dart
class RecommendationsApi {
  final Dio _dio;
  RecommendationsApi(this._dio);

  // GET /api/v1/recommendations
  Future<List<SongModel>> getRecommendations(...) async { /* ... */ }
  // GET /api/v1/recommendations/similar/:songId
  Future<List<SongModel>> getSimilarSongs(...) async { /* ... */ }
  // ... and all other 6 recommendation endpoints
}
```

#### **Analytics APIs** (`app/data/datasources/remote/analytics_api.dart`)
```dart
class AnalyticsApi {
  final Dio _dio;
  AnalyticsApi(this._dio);

  // POST /api/v1/analytics/track
  Future<void> trackListening(...) async { /* ... */ }
  // GET /api/v1/analytics/stats
  Future<Map<String, dynamic>> getUserStats() async { /* ... */ }
  // ... and all other 7 analytics endpoints
}
```

---

## 💾 Caching Strategy

The caching strategy using Isar and an LRU policy remains an excellent choice and is independent of the state management framework.

### Cache Manager (`app/data/datasources/local/cache_manager.dart`)
```dart
import 'package:isar/isar.dart';
import '../../models/song/song_model.dart';
import '../isar_database.dart';

class CacheManager {
  // (No changes from original ap.md - this implementation is solid)
  // ...
}
```

---

## 🎵 Audio Player Implementation

The `AudioPlayerService` now acts as a pure service layer, holding the player logic. It's a singleton managed by GetX. We will add the analytics tracking call here.

### Audio Player Service (`services/audio/audio_player_service.dart`)
```dart
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../data/repositories/song_repository.dart';
import '../data/repositories/analytics_repository.dart'; // Import analytics

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final SongRepository _songRepository;
  final AnalyticsRepository _analyticsRepository; // Inject analytics repo

  // Reactive properties managed by the service, exposed to the controller
  final Rx<SongEntity?> currentSong = Rx<SongEntity?>(null);
  final RxBool playing = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration?> duration = Rx<Duration?>(null);

  // Private state
  List<SongEntity> _queue = [];
  int _currentIndex = 0;

  AudioPlayerService(this._songRepository, this._analyticsRepository) {
    _initListeners();
  }

  void _initListeners() {
    // Listen to player state
    _player.playerStateStream.listen((state) {
      playing.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        // Track completion event
        if (currentSong.value != null) {
          _analyticsRepository.trackListening(songId: currentSong.value!.id, action: 'complete');
        }
        playNext();
      }
    });

    // Listen to streams for UI updates
    _player.positionStream.listen((p) {
      position.value = p;
      _trackPlaybackProgress(p); // Track progress
    });
    _player.durationStream.listen((d) => duration.value = d);
  }
  
  Future<void> play(SongEntity song) async {
    currentSong.value = song;
    // ... (Get stream URL, set URL, etc.)
    await _player.setUrl(streamUrl);
    await _player.play();

    // Track play event via Analytics API
    await _analyticsRepository.trackListening(songId: song.id, action: 'play');
  }
  
  // Track playback and send to backend analytics every 30 seconds
  void _trackPlaybackProgress(Duration currentPosition) {
    if (currentSong.value == null || duration.value == null) return;
    
    // Batch send updates (e.g., every 30s) to avoid spamming the API
    if (currentPosition.inSeconds > 0 && currentPosition.inSeconds % 30 == 0) {
      _analyticsRepository.trackListening(
        songId: currentSong.value!.id,
        action: 'progress',
        positionMs: currentPosition.inMilliseconds,
        durationMs: duration.value!.inMilliseconds,
      );
    }
  }

  // ... pause, resume, seek, playNext, playPrevious, setQueue methods ...
}
```

---

## 🎨 UI/UX Components

UI components are rebuilt using `Obx` or `GetX` to react to state changes from GetX controllers.

### Song Tile Widget (`app/presentation/widgets/song/song_tile.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';
import '../../../domain/entities/song_entity.dart';

class SongTile extends StatelessWidget {
  final SongEntity song;
  final VoidCallback? onTap;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use Get.find only if the controller is already in memory.
    // For views, it's better to use Get.put in a Binding or Get.find in the build method.
    final audioController = Get.find<AudioPlayerController>();

    return Obx(() {
      final isCurrentSong = audioController.currentSong.value?.id == song.id;

      return ListTile(
        leading: /* ... Album Art ... */,
        title: Text(
          song.title,
          style: TextStyle(
            fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(song.artist),
        trailing: isCurrentSong && audioController.isPlaying.value
            ? const Icon(Icons.equalizer, color: Colors.blue)
            : null,
        onTap: onTap ?? () {
          // You need the full queue here to play
          // final songsController = Get.find<SongsController>();
          // audioController.playSong(song, songsController.songs);
        },
      );
    });
  }
}
```

### Mini Player Widget (`app/presentation/widgets/player/mini_player.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/audio_player_controller.dart';
import '../../routes/app_routes.dart';

class MiniPlayer extends GetView<AudioPlayerController> {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // `GetView` automatically finds the controller.
    return Obx(() {
      if (controller.currentSong.value == null) {
        return const SizedBox.shrink();
      }

      final song = controller.currentSong.value!;
      final isPlaying = controller.isPlaying.value;

      return GestureDetector(
        onTap: () => Get.toNamed(Routes.PLAYER),
        child: Container(
          height: 70,
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              // Album Art, Song Info ...
              Expanded(child: /* ... */),
              // Play/Pause Button
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () => isPlaying ? controller.pause() : controller.resume(),
              ),
              // Next Button
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () => controller.playNext(),
              ),
            ],
          ),
        ),
      );
    });
  }
}
```

---

## 📱 Screens & Navigation (GetX Routes)

GetX provides a powerful and simple routing system.

### App Routes (`app/routes/app_routes.dart`)
```dart
abstract class Routes {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const PLAYER = '/player';
  static const SEARCH = '/search';
  // ... other routes
}
```

### App Pages (`app/routes/app_pages.dart`)
This file connects routes to screens and their bindings.
```dart
import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/player/player_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/player_binding.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
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
    // ... other pages
  ];
}
```

### Splash Screen (`app/presentation/screens/splash/splash_screen.dart`)
A simple screen to decide the initial route based on auth state.
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use a delayed future to allow AuthController to initialize.
    Future.delayed(const Duration(milliseconds: 500), () {
      final authController = Get.find<AuthController>();
      if (authController.isAuthenticated.value) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

### Login Screen (`app/presentation/screens/auth/login_screen.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> handleLogin() async {
      final success = await controller.login(
        emailController.text.trim(),
        passwordController.text,
      );
      if (success) {
        Get.offAllNamed(Routes.HOME);
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            // ... Form fields for email and password
            children: [
              // ...
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : handleLogin,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ⚡ Performance Optimizations

These strategies are framework-agnostic and remain highly effective with GetX.

### 1. **Lazy Loading & Pagination** (with GetX)
```dart
class SongsController extends GetxController {
  final _songs = <SongEntity>[].obs;
  List<SongEntity> get songs => _songs;

  final _currentPage = 1.obs;
  final _hasMore = true.obs;
  bool get hasMore => _hasMore.value;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadMore(); // Initial load
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.8 && hasMore) {
        loadMore();
      }
    });
  }

  Future<void> loadMore() async {
    // Fetch data from repository for _currentPage.value
    // ...
    _songs.addAll(newSongs);
    _currentPage.value++;
    _hasMore.value = newSongs.isNotEmpty;
  }
}
```

### 2. **Image Caching**
Using `cached_network_image` is still the best practice.
```dart
CachedNetworkImage(
  imageUrl: song.albumArt ?? '',
  placeholder: (context, url) => const ShimmerEffect(),
  errorWidget: (context, url, error) => const Icon(Icons.music_note),
  fit: BoxFit.cover,
)
```

### 3. **Debounced Search**
This can be implemented easily within a `GetxController`.
```dart
class SearchController extends GetxController {
  final _searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Debounce the search query
    debounce(_searchQuery, (_) => performSearch(), time: const Duration(milliseconds: 500));
  }

  void onSearchChanged(String query) {
    _searchQuery.value = query;
  }

  void performSearch() {
    // API call with _searchQuery.value
  }
}
```

---

## 🧪 Testing Strategy

### Controller Unit Test Example
```dart
// test/presentation/controllers/auth_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:freetune/app/presentation/controllers/auth_controller.dart';
import 'package:freetune/app/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthController authController;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    // Inject the mock repository before putting the controller
    Get.put<AuthRepository>(mockRepository);
    authController = Get.put(AuthController());
  });

  tearDown(() {
    Get.reset();
  });

  test('login should set user and isAuthenticated on success', () async {
    // Arrange
    when(mockRepository.login(any, any))
        .thenAnswer((_) async => UserEntity(id: '1', email: 'test@test.com'));

    // Act
    final success = await authController.login('test@test.com', 'password');

    // Assert
    expect(success, isTrue);
    expect(authController.user.value, isNotNull);
    expect(authController.isAuthenticated.value, isTrue);
    expect(authController.isLoading.value, isFalse);
  });
}
```

---

## 📝 Implementation Checklist

### Phase 1: Core Setup (Week 1)
- [ ] Initialize Flutter project
- [ ] Setup dependencies (**GetX**, Isar, just_audio, Dio)
- [ ] Configure API client with interceptors
- [ ] Setup Isar database
- [ ] Implement **GetX named routes** and pages
- [ ] Create **InitialBinding** to inject core services
- [ ] Implement `AuthController` and `AuthBinding`
- [ ] Build Login and Splash screens

### Phase 2: Audio Player (Week 2)
- [ ] Implement `AudioPlayerService` with analytics tracking
- [ ] Implement `AudioPlayerController` to expose state to the UI
- [ ] Create `PlayerBinding`
- [ ] Create mini player and full player screens using `GetView` and `Obx`
- [ ] Test playback and analytics integration

### Phase 3: Core Features (Week 3)
- [ ] Implement `SongsController` and `HomeController` with their bindings
- [ ] Build Songs list screen with pagination/infinite scroll
- [ ] Implement `SearchController` with debouncing
- [ ] Playlists, Favorites, Recommendations features

### Phase 4: Caching & Optimization (Week 4)
- [ ] Implement `CacheManager` with LRU eviction
- [ ] Implement offline mode using Isar
- [ ] Add network detection service
- [ ] Optimize image loading with `CachedNetworkImage` and shimmer placeholders
- [ ] Performance profiling and tweaking

### Phase 5: Polish & Testing (Week 5)
- [ ] Refine UI/UX and animations
- [ ] Comprehensive error handling with `Get.snackbar`
- [ ] Add loading indicators for all async actions
- [ ] Write unit tests for controllers and services
- [ ] Write widget tests for key screens

---

**This updated guide provides a robust, scalable, and high-performance architecture for the FreeTune app using GetX, fully integrated with your powerful backend.** 🚀🎵