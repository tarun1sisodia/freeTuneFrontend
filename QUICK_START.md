# 🚀 FreeTune Frontend - Quick Start Guide

## 📍 Current Status
- ✅ Authentication (Login/Register) - **WORKING**
- ⚠️ Home Screen - Exists but needs integration
- ⚠️ Player Screen - Exists but controller not bound (FIXED)
- ❌ Data layer - Incomplete
- ❌ Audio player - Not integrated

---

## 🎯 TODAY'S TASKS - Start Here!

### Task 1: Run Build Runner (5 min)
```bash
cd /home/gargi/Cursor/freeTune/freeTuneFrontend/freetune

# Generate Isar and JSON code
flutter pub run build_runner build --delete-conflicting-outputs

# If errors, check models have proper annotations
```

### Task 2: Setup Isar Database (30 min)
**Create:** `/lib/app/data/datasources/local/isar_database.dart`

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/song/song_model.dart';
import '../../models/playlist/playlist_model.dart';
import '../../models/user/user_model.dart';

class IsarDatabase {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null) return _isar!;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        SongModelSchema,
        PlaylistModelSchema,
        UserModelSchema,
        // Add other schemas
      ],
      directory: dir.path,
      inspector: true, // Enable for debugging
    );
    
    return _isar!;
  }

  static Isar get instance {
    if (_isar == null) throw Exception('Isar not initialized');
    return _isar!;
  }
}
```

### Task 3: Create Cache Manager (30 min)
**Create:** `/lib/app/data/datasources/local/cache_manager.dart`

```dart
import 'package:isar/isar.dart';
import '../../models/song/song_model.dart';
import 'isar_database.dart';

class CacheManager {
  final Isar _isar;

  CacheManager(this._isar);

  // Songs cache
  Future<void> cacheSongs(List<SongModel> songs) async {
    await _isar.writeTxn(() async {
      await _isar.songModels.putAll(songs);
    });
  }

  Future<List<SongModel>> getCachedSongs() async {
    return await _isar.songModels.where().findAll();
  }

  Future<SongModel?> getCachedSong(String id) async {
    return await _isar.songModels
        .filter()
        .idEqualTo(id)
        .findFirst();
  }

  Future<void> clearSongsCache() async {
    await _isar.writeTxn(() async {
      await _isar.songModels.clear();
    });
  }

  // Similar methods for playlists, etc.
}
```

### Task 4: Complete SongsApi (45 min)
**Update:** `/lib/app/data/datasources/remote/songs_api.dart`

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/common/paginated_response.dart';
import '../../models/song/song_model.dart';
import '../../models/song/stream_url_response.dart';

class SongsApi {
  final Dio _dio;

  SongsApi(this._dio);

  // Get all songs (paginated)
  Future<PaginatedResponse<SongModel>> getSongs({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.songs,
      queryParameters: {'page': page, 'limit': limit},
    );
    return PaginatedResponse.fromJson(response.data, SongModel.fromJson);
  }

  // Get single song by ID
  Future<SongModel> getSongById(String id) async {
    final response = await _dio.get(
      ApiEndpoints.getSong.replaceFirst('{id}', id),
    );
    return SongModel.fromJson(response.data['data']);
  }

  // Search songs
  Future<PaginatedResponse<SongModel>> searchSongs(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.searchSongs,
      queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      },
    );
    return PaginatedResponse.fromJson(response.data, SongModel.fromJson);
  }

  // Get popular songs
  Future<List<SongModel>> getPopularSongs({int limit = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.popularSongs,
      queryParameters: {'limit': limit},
    );
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // Get recently played songs
  Future<List<SongModel>> getRecentlyPlayed({int limit = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.recentSongs,
      queryParameters: {'limit': limit},
    );
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // Get favorite songs
  Future<List<SongModel>> getFavorites() async {
    final response = await _dio.get(ApiEndpoints.favoriteSongs);
    return (response.data['data'] as List)
        .map((json) => SongModel.fromJson(json))
        .toList();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String songId) async {
    await _dio.post(
      ApiEndpoints.addFavorite.replaceFirst('{id}', songId),
    );
  }

  // Get streaming URL
  Future<StreamUrlResponse> getStreamUrl(
    String songId,
    String quality,
  ) async {
    final response = await _dio.get(
      ApiEndpoints.streamUrl.replaceFirst('{id}', songId),
      queryParameters: {'quality': quality},
    );
    return StreamUrlResponse.fromJson(response.data);
  }

  // Track play
  Future<void> trackPlay(String songId) async {
    await _dio.post(
      ApiEndpoints.trackPlay.replaceFirst('{id}', songId),
    );
  }

  // Track playback progress
  Future<void> trackPlayback(
    String songId,
    int positionMs,
    int durationMs,
  ) async {
    await _dio.post(
      ApiEndpoints.trackPlayback.replaceFirst('{id}', songId),
      data: {
        'positionMs': positionMs,
        'durationMs': durationMs,
      },
    );
  }

  // Upload song
  Future<SongModel> uploadSong(FormData formData) async {
    final response = await _dio.post(
      ApiEndpoints.uploadSong,
      data: formData,
    );
    return SongModel.fromJson(response.data['data']);
  }

  // Update song metadata
  Future<SongModel> updateSongMetadata(
    String songId,
    Map<String, dynamic> metadata,
  ) async {
    final response = await _dio.patch(
      ApiEndpoints.updateSong.replaceFirst('{id}', songId),
      data: metadata,
    );
    return SongModel.fromJson(response.data['data']);
  }

  // Delete song
  Future<void> deleteSong(String songId) async {
    await _dio.delete(
      ApiEndpoints.deleteSong.replaceFirst('{id}', songId),
    );
  }
}
```

### Task 5: Complete PlaylistsApi (30 min)
**Update:** `/lib/app/data/datasources/remote/playlists_api.dart`

```dart
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/playlist/playlist_model.dart';

class PlaylistsApi {
  final Dio _dio;

  PlaylistsApi(this._dio);

  // Get user playlists
  Future<List<PlaylistModel>> getUserPlaylists() async {
    final response = await _dio.get(ApiEndpoints.playlists);
    return (response.data['data'] as List)
        .map((json) => PlaylistModel.fromJson(json))
        .toList();
  }

  // Get single playlist
  Future<PlaylistModel> getPlaylistById(String id) async {
    final response = await _dio.get(
      ApiEndpoints.getPlaylist.replaceFirst('{id}', id),
    );
    return PlaylistModel.fromJson(response.data['data']);
  }

  // Create playlist
  Future<PlaylistModel> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.createPlaylist,
      data: {
        'name': name,
        'description': description,
        'is_public': isPublic,
      },
    );
    return PlaylistModel.fromJson(response.data['data']);
  }

  // Update playlist
  Future<PlaylistModel> updatePlaylist(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _dio.patch(
      ApiEndpoints.updatePlaylist.replaceFirst('{id}', id),
      data: updates,
    );
    return PlaylistModel.fromJson(response.data['data']);
  }

  // Delete playlist
  Future<void> deletePlaylist(String id) async {
    await _dio.delete(
      ApiEndpoints.deletePlaylist.replaceFirst('{id}', id),
    );
  }

  // Add song to playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _dio.post(
      ApiEndpoints.addSongToPlaylist.replaceFirst('{id}', playlistId),
      data: {'song_id': songId},
    );
  }

  // Remove song from playlist
  Future<void> removeSongFromPlaylist(
    String playlistId,
    String songId,
  ) async {
    await _dio.delete(
      ApiEndpoints.removeSongFromPlaylist
          .replaceFirst('{playlistId}', playlistId)
          .replaceFirst('{songId}', songId),
    );
  }
}
```

### Task 6: Initialize in InitialBinding (15 min)
**Update:** `/lib/app/bindings/initial_binding.dart`

```dart
import 'package:get/get.dart';
import '../data/datasources/local/isar_database.dart';
import '../data/datasources/local/cache_manager.dart';
import '../data/datasources/remote/api_client.dart';
import '../data/datasources/remote/songs_api.dart';
import '../data/datasources/remote/playlists_api.dart';
import '../data/repositories/song_repository.dart';
import '../data/repositories/playlist_repository.dart';
import '../services/audio/audio_player_service.dart';
import '../services/network/network_service.dart';

class AppBindings implements Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize Isar database
    final isar = await IsarDatabase.getInstance();
    
    // Register core services
    Get.put(CacheManager(isar), permanent: true);
    
    // API client
    final apiClient = ApiClient();
    Get.put(apiClient, permanent: true);
    
    // APIs
    Get.put(SongsApi(apiClient.dio), permanent: true);
    Get.put(PlaylistsApi(apiClient.dio), permanent: true);
    
    // Repositories
    Get.put(
      SongRepository(
        Get.find<SongsApi>(),
        Get.find<CacheManager>(),
      ),
      permanent: true,
    );
    
    Get.put(
      PlaylistRepository(
        Get.find<PlaylistsApi>(),
        Get.find<CacheManager>(),
      ),
      permanent: true,
    );
    
    // Services
    Get.put(NetworkService(), permanent: true);
    Get.put(
      AudioPlayerService(Get.find<SongRepository>()),
      permanent: true,
    );
  }
}
```

---

## 🧪 Test Your Progress

### Test 1: Database Initialization
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test database
  final isar = await IsarDatabase.getInstance();
  print('✅ Isar initialized: ${isar.isOpen}');
  
  await AppBindings().dependencies();
  
  runApp(const FreeTuneApp());
}
```

### Test 2: API Connection
```dart
// In HomeScreen or test file
final songsApi = Get.find<SongsApi>();
try {
  final songs = await songsApi.getSongs();
  print('✅ API working: Got ${songs.data.length} songs');
} catch (e) {
  print('❌ API error: $e');
}
```

### Test 3: Cache
```dart
final cacheManager = Get.find<CacheManager>();
final songs = await songsApi.getSongs();
await cacheManager.cacheSongs(songs.data);
final cached = await cacheManager.getCachedSongs();
print('✅ Cached ${cached.length} songs');
```

---

## 📁 File Structure Summary

```
lib/
├── app/
│   ├── bindings/
│   │   ├── initial_binding.dart ✅ UPDATE
│   │   ├── auth_binding.dart ✅
│   │   ├── player_binding.dart ✅
│   │   └── home_binding.dart
│   │
│   ├── config/
│   │   ├── api_config.dart ✅
│   │   └── cache_config.dart
│   │
│   ├── core/
│   │   ├── constants/ ✅
│   │   ├── exceptions/ ✅
│   │   ├── mixins/ ✅
│   │   └── utils/ ✅
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── isar_database.dart ⚠️ CREATE
│   │   │   │   └── cache_manager.dart ⚠️ CREATE
│   │   │   └── remote/
│   │   │       ├── api_client.dart ✅
│   │   │       ├── songs_api.dart ⚠️ UPDATE
│   │   │       ├── playlists_api.dart ⚠️ UPDATE
│   │   │       └── auth_api.dart ✅
│   │   │
│   │   ├── mappers/ (Later)
│   │   ├── models/ ✅
│   │   └── repositories/ ⚠️ UPDATE
│   │
│   ├── domain/ (Later)
│   ├── presentation/ ✅
│   ├── routes/ ✅
│   └── services/ ⚠️ UPDATE
│
└── main.dart ✅
```

---

## ⏭️ Tomorrow's Tasks

1. **Complete Song Repository** with cache strategy
2. **Complete Playlist Repository**
3. **Update SongsController** to use repository
4. **Build Home Screen UI** with song list
5. **Test end-to-end flow**: API → Cache → UI

---

## 🔧 Troubleshooting

### Build Runner Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Isar Not Found
```bash
# Check pubspec.yaml has:
dependencies:
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  
dev_dependencies:
  isar_generator: ^3.1.0+1
```

### API Connection Issues
- Check backend is running: `http://localhost:3000/api/v1/healthcheck`
- Check API_BASE_URL in api_config.dart
- Check CORS settings in backend

---

## 📞 Need Help?

**Common Issues:**
1. **"Isar not initialized"** → Call `await IsarDatabase.getInstance()` in main
2. **"Controller not found"** → Add binding to route in app_pages.dart
3. **"API error 401"** → Check token in SharedPreferences
4. **"Build runner fails"** → Check model annotations

---

## ✨ Quick Wins

After completing today's tasks, you'll have:
- ✅ Database working with Isar
- ✅ Cache system functional
- ✅ Complete API integration
- ✅ Data flowing from backend to app

This is **80% of the data layer** complete! 🎉

---

**Let's build something amazing! 🚀**
