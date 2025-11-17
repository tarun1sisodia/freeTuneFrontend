# 🎯 Immediate Next Steps - Detailed Guide

## 📍 Where We Are Now
- ✅ Auth system working (login/register tested)
- ✅ Basic project structure in place
- ✅ Models, repositories, services created
- 🟡 Need to complete data flow and UI integration

---

## 🚀 START HERE: Phase 1 - Complete Data Layer

### Task 1: Complete Songs API (Priority 1) ⭐
**Time**: 2-3 hours  
**File**: `/lib/app/data/datasources/remote/songs_api.dart`

#### Current State Analysis
Check what endpoints already exist:
```bash
cd /home/gargi/Cursor/freeTune/freeTuneFrontend/freetune
cat lib/app/data/datasources/remote/songs_api.dart
```

#### Add These Missing Endpoints

```dart
// 1. Get single song by ID
Future<SongModel> getSongById(String id) async {
  try {
    final response = await _dio.get('${ApiEndpoints.songs}/$id');
    return SongModel.fromJson(response.data['data']);
  } catch (e) {
    throw ApiException(message: 'Failed to get song: $e');
  }
}

// 2. Get popular/trending songs
Future<List<SongModel>> getPopularSongs({int limit = 20}) async {
  try {
    final response = await _dio.get(
      ApiEndpoints.popularSongs, // or '${ApiEndpoints.songs}/popular'
      queryParameters: {'limit': limit},
    );
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  } catch (e) {
    throw ApiException(message: 'Failed to get popular songs: $e');
  }
}

// 3. Get recently played songs
Future<List<SongModel>> getRecentlyPlayed({int limit = 20}) async {
  try {
    final response = await _dio.get(
      ApiEndpoints.recentSongs, // Check your backend for correct endpoint
      queryParameters: {'limit': limit},
    );
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  } catch (e) {
    throw ApiException(message: 'Failed to get recent songs: $e');
  }
}

// 4. Get user's favorite songs
Future<List<SongModel>> getFavorites() async {
  try {
    final response = await _dio.get(ApiEndpoints.favoriteSongs);
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  } catch (e) {
    throw ApiException(message: 'Failed to get favorites: $e');
  }
}

// 5. Toggle favorite (add/remove)
Future<void> toggleFavorite(String songId) async {
  try {
    await _dio.post('${ApiEndpoints.songs}/$songId/favorite');
  } catch (e) {
    throw ApiException(message: 'Failed to toggle favorite: $e');
  }
}

// 6. Get recommendations based on song
Future<List<SongModel>> getSimilarSongs(String songId, {int limit = 10}) async {
  try {
    final response = await _dio.get(
      '${ApiEndpoints.songs}/$songId/similar',
      queryParameters: {'limit': limit},
    );
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  } catch (e) {
    throw ApiException(message: 'Failed to get similar songs: $e');
  }
}
```

#### Update API Endpoints
**File**: `/lib/app/core/constants/api_endpoints.dart`

Add missing endpoint constants:
```dart
class ApiEndpoints {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // Auth endpoints (already exist)
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  // ... other auth endpoints
  
  // Song endpoints
  static const String songs = '$baseUrl/songs';
  static const String popularSongs = '$songs/popular';
  static const String recentSongs = '$songs/recent';
  static const String favoriteSongs = '$songs/favorites';
  static const String searchSongs = '$songs/search';
  static const String streamSong = '$songs/stream';
  
  // Playlist endpoints
  static const String playlists = '$baseUrl/playlists';
  
  // Recommendation endpoints
  static const String recommendations = '$baseUrl/recommendations';
  
  // Analytics endpoints
  static const String analytics = '$baseUrl/analytics';
}
```

#### Test the API
Create a test or use the controller to verify:
```dart
// In a test file or temporary controller method
void testSongsApi() async {
  final songsApi = Get.find<SongsApi>();
  
  try {
    // Test get songs
    final songs = await songsApi.getSongs();
    print('✅ Got ${songs.data.length} songs');
    
    // Test get popular
    final popular = await songsApi.getPopularSongs(limit: 10);
    print('✅ Got ${popular.length} popular songs');
    
    // Test get by ID (use a real song ID from your backend)
    if (songs.data.isNotEmpty) {
      final songId = songs.data.first.id;
      final song = await songsApi.getSongById(songId);
      print('✅ Got song: ${song.title}');
    }
  } catch (e) {
    print('❌ API Error: $e');
  }
}
```

---

### Task 2: Complete Song Repository with Caching (Priority 1) ⭐
**Time**: 2-3 hours  
**File**: `/lib/app/data/repositories/song_repository.dart`

#### Implementation Strategy
The repository should:
1. Check cache first (fast, offline-friendly)
2. If cache miss or forceRefresh, fetch from API
3. Save API response to cache
4. Return data to caller

#### Complete Implementation

```dart
import 'package:get/get.dart';
import '../datasources/local/cache_manager.dart';
import '../datasources/remote/songs_api.dart';
import '../models/song/song_model.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/exceptions/cache_exception.dart';
import '../../services/network/network_service.dart';

class SongRepository {
  final SongsApi _songsApi;
  final CacheManager _cacheManager;
  final NetworkService _networkService;

  SongRepository(this._songsApi, this._cacheManager, this._networkService);

  // Get all songs with pagination and caching
  Future<List<SongModel>> getSongs({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh) {
        final cached = await _cacheManager.getCachedSongs();
        if (cached.isNotEmpty) {
          print('📦 Returning ${cached.length} cached songs');
          return cached;
        }
      }

      // Check network connectivity
      if (!await _networkService.isConnected) {
        // No network, try to return cached data
        final cached = await _cacheManager.getCachedSongs();
        if (cached.isNotEmpty) {
          return cached;
        }
        throw NetworkException(message: 'No internet connection');
      }

      // Fetch from API
      print('🌐 Fetching songs from API...');
      final response = await _songsApi.getSongs(page: page, limit: limit);
      
      // Cache the results
      if (response.data.isNotEmpty) {
        await _cacheManager.cacheSongs(response.data);
        print('💾 Cached ${response.data.length} songs');
      }
      
      return response.data;
    } catch (e) {
      throw ApiException(message: 'Failed to get songs: $e');
    }
  }

  // Get single song by ID (with cache)
  Future<SongModel> getSongById(String id, {bool forceRefresh = false}) async {
    try {
      // Check cache first
      if (!forceRefresh) {
        final cached = await _cacheManager.getCachedSong(id);
        if (cached != null) {
          print('📦 Returning cached song: ${cached.title}');
          return cached;
        }
      }

      // Fetch from API
      print('🌐 Fetching song $id from API...');
      final song = await _songsApi.getSongById(id);
      
      // Cache the song
      await _cacheManager.cacheSong(song);
      
      return song;
    } catch (e) {
      throw ApiException(message: 'Failed to get song: $e');
    }
  }

  // Search songs
  Future<List<SongModel>> searchSongs(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) return [];
      
      print('🔍 Searching for: $query');
      final response = await _songsApi.searchSongs(
        query,
        page: page,
        limit: limit,
      );
      
      return response.data;
    } catch (e) {
      throw ApiException(message: 'Failed to search songs: $e');
    }
  }

  // Get popular songs
  Future<List<SongModel>> getPopularSongs({int limit = 20}) async {
    try {
      print('🔥 Fetching popular songs...');
      final songs = await _songsApi.getPopularSongs(limit: limit);
      
      // Optionally cache popular songs
      if (songs.isNotEmpty) {
        await _cacheManager.cachePopularSongs(songs);
      }
      
      return songs;
    } catch (e) {
      // Fallback to cached popular songs
      final cached = await _cacheManager.getCachedPopularSongs();
      if (cached.isNotEmpty) return cached;
      
      throw ApiException(message: 'Failed to get popular songs: $e');
    }
  }

  // Get recently played
  Future<List<SongModel>> getRecentlyPlayed({int limit = 20}) async {
    try {
      final songs = await _songsApi.getRecentlyPlayed(limit: limit);
      return songs;
    } catch (e) {
      throw ApiException(message: 'Failed to get recent songs: $e');
    }
  }

  // Get favorites
  Future<List<SongModel>> getFavorites() async {
    try {
      final songs = await _songsApi.getFavorites();
      
      // Cache favorites
      await _cacheManager.cacheFavorites(songs);
      
      return songs;
    } catch (e) {
      // Fallback to cached favorites
      final cached = await _cacheManager.getCachedFavorites();
      if (cached.isNotEmpty) return cached;
      
      throw ApiException(message: 'Failed to get favorites: $e');
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String songId) async {
    try {
      await _songsApi.toggleFavorite(songId);
      
      // Update cache
      await _cacheManager.toggleFavoriteInCache(songId);
    } catch (e) {
      throw ApiException(message: 'Failed to toggle favorite: $e');
    }
  }

  // Get stream URL
  Future<String> getStreamUrl(String songId, {String quality = 'medium'}) async {
    try {
      final response = await _songsApi.getStreamUrl(songId, quality: quality);
      return response.streamUrl;
    } catch (e) {
      throw ApiException(message: 'Failed to get stream URL: $e');
    }
  }

  // Track play
  Future<void> trackPlay(String songId, {int position = 0}) async {
    try {
      await _songsApi.trackPlay(songId, position: position);
    } catch (e) {
      // Don't throw error for analytics tracking
      print('⚠️ Failed to track play: $e');
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _cacheManager.clearSongsCache();
      print('🗑️ Song cache cleared');
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  // Refresh cache in background
  Future<void> refreshCache() async {
    try {
      print('🔄 Refreshing cache...');
      final songs = await getSongs(forceRefresh: true);
      print('✅ Cache refreshed with ${songs.length} songs');
    } catch (e) {
      print('⚠️ Failed to refresh cache: $e');
    }
  }
}
```

#### Update Cache Manager
**File**: `/lib/app/data/datasources/local/cache_manager.dart`

Add these methods if missing:
```dart
// Cache single song
Future<void> cacheSong(SongModel song) async {
  await _isar.writeTxn(() async {
    await _isar.songModels.put(song);
  });
}

// Cache popular songs (with metadata)
Future<void> cachePopularSongs(List<SongModel> songs) async {
  await _isar.writeTxn(() async {
    await _isar.songModels.putAll(songs);
    // Optionally: Save metadata indicating these are popular
  });
}

// Get cached popular songs
Future<List<SongModel>> getCachedPopularSongs() async {
  // Implement based on your metadata strategy
  return await _isar.songModels.where().findAll();
}

// Cache favorites
Future<void> cacheFavorites(List<SongModel> songs) async {
  await _isar.writeTxn(() async {
    await _isar.songModels.putAll(songs);
  });
}

// Get cached favorites
Future<List<SongModel>> getCachedFavorites() async {
  return await _isar.songModels.filter().isFavoriteEqualTo(true).findAll();
}

// Toggle favorite in cache
Future<void> toggleFavoriteInCache(String songId) async {
  await _isar.writeTxn(() async {
    final song = await _isar.songModels.filter().idEqualTo(songId).findFirst();
    if (song != null) {
      song.isFavorite = !song.isFavorite;
      await _isar.songModels.put(song);
    }
  });
}
```

---

### Task 3: Update SongsController (Priority 1) ⭐
**Time**: 1-2 hours  
**File**: `/lib/app/presentation/controllers/songs_controller.dart`

#### Complete Implementation

```dart
import 'package:get/get.dart';
import '../../data/models/song/song_model.dart';
import '../../data/repositories/song_repository.dart';
import '../../core/mixins/error_handler_mixin.dart';
import '../../core/mixins/loading_mixin.dart';

class SongsController extends GetxController with ErrorHandlerMixin, LoadingMixin {
  final SongRepository _songRepository;

  SongsController(this._songRepository);

  // Observable lists
  final RxList<SongModel> allSongs = <SongModel>[].obs;
  final RxList<SongModel> popularSongs = <SongModel>[].obs;
  final RxList<SongModel> recentSongs = <SongModel>[].obs;
  final RxList<SongModel> favoriteSongs = <SongModel>[].obs;
  final RxList<SongModel> searchResults = <SongModel>[].obs;

  // Selected song
  final Rx<SongModel?> selectedSong = Rx<SongModel?>(null);

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Search query
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial data
    fetchAllSongs();
    fetchPopularSongs();
    fetchRecentSongs();
    fetchFavorites();
  }

  // Fetch all songs
  Future<void> fetchAllSongs({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
    }

    if (isLoading.value) return;

    try {
      setLoading(true);
      clearError();

      final songs = await _songRepository.getSongs(
        page: currentPage.value,
        limit: 20,
        forceRefresh: refresh,
      );

      if (refresh) {
        allSongs.value = songs;
      } else {
        allSongs.addAll(songs);
      }

      // Update pagination
      hasMore.value = songs.length >= 20;
      currentPage.value++;

      print('✅ Fetched ${songs.length} songs');
    } catch (e) {
      handleError(e);
      showErrorSnackbar('Failed to load songs');
    } finally {
      setLoading(false);
    }
  }

  // Load more songs (for pagination)
  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      await fetchAllSongs();
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Refresh songs (pull-to-refresh)
  Future<void> refreshSongs() async {
    await fetchAllSongs(refresh: true);
    await fetchPopularSongs();
    await fetchRecentSongs();
  }

  // Fetch popular songs
  Future<void> fetchPopularSongs() async {
    try {
      final songs = await _songRepository.getPopularSongs(limit: 20);
      popularSongs.value = songs;
      print('🔥 Fetched ${songs.length} popular songs');
    } catch (e) {
      print('⚠️ Failed to fetch popular songs: $e');
    }
  }

  // Fetch recently played
  Future<void> fetchRecentSongs() async {
    try {
      final songs = await _songRepository.getRecentlyPlayed(limit: 20);
      recentSongs.value = songs;
      print('🕐 Fetched ${songs.length} recent songs');
    } catch (e) {
      print('⚠️ Failed to fetch recent songs: $e');
    }
  }

  // Fetch favorites
  Future<void> fetchFavorites() async {
    try {
      final songs = await _songRepository.getFavorites();
      favoriteSongs.value = songs;
      print('❤️ Fetched ${songs.length} favorites');
    } catch (e) {
      print('⚠️ Failed to fetch favorites: $e');
    }
  }

  // Search songs
  Future<void> searchSongs(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      setLoading(true);
      final songs = await _songRepository.searchSongs(query);
      searchResults.value = songs;
      print('🔍 Found ${songs.length} results for "$query"');
    } catch (e) {
      handleError(e);
      showErrorSnackbar('Search failed');
    } finally {
      setLoading(false);
    }
  }

  // Get song by ID
  Future<void> fetchSongById(String id) async {
    try {
      setLoading(true);
      final song = await _songRepository.getSongById(id);
      selectedSong.value = song;
    } catch (e) {
      handleError(e);
      showErrorSnackbar('Failed to load song');
    } finally {
      setLoading(false);
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String songId) async {
    try {
      await _songRepository.toggleFavorite(songId);
      
      // Update local state
      _updateFavoriteStatus(songId);
      
      // Refresh favorites list
      await fetchFavorites();
      
      Get.snackbar(
        'Success',
        'Favorite updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      handleError(e);
      showErrorSnackbar('Failed to update favorite');
    }
  }

  // Helper: Update favorite status in all lists
  void _updateFavoriteStatus(String songId) {
    _toggleInList(allSongs, songId);
    _toggleInList(popularSongs, songId);
    _toggleInList(recentSongs, songId);
    _toggleInList(searchResults, songId);
  }

  void _toggleInList(RxList<SongModel> list, String songId) {
    final index = list.indexWhere((s) => s.id == songId);
    if (index != -1) {
      final song = list[index];
      song.isFavorite = !song.isFavorite;
      list[index] = song;
      list.refresh();
    }
  }

  // Play song
  Future<void> playSong(SongModel song) async {
    try {
      // Get stream URL
      final streamUrl = await _songRepository.getStreamUrl(song.id);
      
      // Track play
      await _songRepository.trackPlay(song.id);
      
      // Pass to audio player controller
      final audioController = Get.find<AudioPlayerController>();
      await audioController.playFromUrl(streamUrl, song);
      
      print('▶️ Playing: ${song.title}');
    } catch (e) {
      handleError(e);
      showErrorSnackbar('Failed to play song');
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _songRepository.clearCache();
      allSongs.clear();
      popularSongs.clear();
      recentSongs.clear();
      
      Get.snackbar(
        'Success',
        'Cache cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      showErrorSnackbar('Failed to clear cache');
    }
  }
}
```

---

### Task 4: Update Home Screen UI (Priority 2) ⭐
**Time**: 2-3 hours  
**File**: `/lib/app/presentation/screens/home/home_screen.dart`

#### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/songs_controller.dart';
import '../../widgets/song/song_card.dart'; // Create this widget
import '../../widgets/common/loading_indicator.dart'; // Create this
import '../../widgets/common/error_view.dart'; // Create this

class HomeScreen extends GetView<SongsController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreeTune'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allSongs.isEmpty) {
          return const LoadingIndicator();
        }

        if (controller.hasError.value && controller.allSongs.isEmpty) {
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: () => controller.refreshSongs(),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshSongs,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular Songs Section
                if (controller.popularSongs.isNotEmpty)
                  _buildSection(
                    'Popular Right Now',
                    controller.popularSongs,
                  ),

                // Recent Songs Section
                if (controller.recentSongs.isNotEmpty)
                  _buildSection(
                    'Recently Played',
                    controller.recentSongs,
                  ),

                // All Songs Section
                _buildSection(
                  'All Songs',
                  controller.allSongs,
                  showLoadMore: true,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSection(
    String title,
    List songs, {
    bool showLoadMore = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length + (showLoadMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (showLoadMore && index == songs.length) {
                return Center(
                  child: Obx(() => controller.isLoadingMore.value
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: controller.loadMore,
                        )),
                );
              }

              return SongCard(
                song: songs[index],
                onTap: () => controller.playSong(songs[index]),
                onFavorite: () => controller.toggleFavorite(songs[index].id),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

---

## ✅ Testing Checklist

After completing these tasks, test:

1. **API Connection**
   ```bash
   # Ensure backend is running
   curl http://localhost:3000/api/v1/songs
   ```

2. **Data Flow**
   - [ ] Songs fetch from API
   - [ ] Songs save to cache
   - [ ] Songs load from cache when offline
   - [ ] Favorites toggle works
   - [ ] Search works

3. **UI Updates**
   - [ ] Loading states show correctly
   - [ ] Error states show correctly
   - [ ] Songs display in UI
   - [ ] Pull-to-refresh works
   - [ ] Pagination works

---

## 🐛 Troubleshooting

### Issue: "SongsController not found"
**Solution**: Make sure HomeBinding is set up:
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SongsController(Get.find()));
  }
}
```

### Issue: "Cannot connect to backend"
**Solution**: 
1. Check backend is running: `curl http://localhost:3000/api/v1/healthcheck`
2. Check API base URL in `api_config.dart`
3. For Android emulator, use `10.0.2.2:3000` instead of `localhost:3000`

### Issue: "Build runner errors"
**Solution**:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 Progress Tracking

Mark tasks as you complete them:

- [ ] Task 1: Complete Songs API
- [ ] Task 2: Complete Song Repository
- [ ] Task 3: Update SongsController
- [ ] Task 4: Update Home Screen UI
- [ ] Test API connection
- [ ] Test data flow
- [ ] Test UI updates

---

**Once these 4 tasks are complete, you'll have:**
- ✅ Full data flow from backend → repository → controller → UI
- ✅ Caching working
- ✅ Songs displaying on home screen
- ✅ Pull-to-refresh working
- ✅ Pagination working

**This is 50% of Phase 1 complete! 🎉**

**Next Up**: Complete Playlists API and Repository (see CONTINUATION_PLAN.md)
