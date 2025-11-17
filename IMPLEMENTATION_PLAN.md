# 🎵 FreeTune Frontend - Implementation Roadmap

## 📊 Current Status Analysis

### ✅ Already Implemented (Working)
- **Authentication**: Login & Register screens with AuthController
- **Core Architecture**: Clean Architecture structure with GetX
- **Basic Models**: SongModel, UserModel, PlaylistModel with Isar annotations
- **API Client**: Dio setup with interceptors and token management
- **Core Utilities**: Logger, validators, formatters, exceptions
- **Basic Routing**: Route structure with GetX navigation
- **Bindings**: InitialBinding, AuthBinding, PlayerBinding setup

### 🔄 Partially Implemented (Needs Completion)
- **Data Layer**: Models exist but repositories need full implementation
- **API Services**: Basic structure exists, needs all endpoints
- **Audio Services**: AudioPlayerService structure exists, needs integration
- **Controllers**: Basic controllers exist, need feature implementation
- **Screens**: Basic screens exist, need UI implementation

### ❌ Missing Components (To Be Built)
- **Local Database**: Isar database initialization and cache management
- **Use Cases**: Business logic layer
- **Complete API Integration**: All backend endpoints
- **Audio Streaming**: Full audio player integration
- **Offline Support**: Cache management and offline playback
- **Home Screen**: Song list, recommendations, trending
- **Search**: Search functionality with debounce
- **Playlists**: Full playlist management

---

## 🎯 Implementation Strategy

### Phase 1: Complete Data Layer (Priority 1)
**Goal**: Build solid foundation for data management

#### 1.1 Complete Models (2-3 hours)
**Files to Review/Update:**
- `/app/data/models/song/song_model.dart` ✓ (Exists)
- `/app/data/models/user/user_model.dart` ✓ (Exists)
- `/app/data/models/playlist/playlist_model.dart` ✓ (Exists)
- `/app/data/models/common/paginated_response.dart` - **VERIFY**
- `/app/data/models/common/api_response.dart` - **CREATE**

**Tasks:**
- [ ] Verify all models match backend API responses
- [ ] Add missing models: RecommendationModel, AnalyticsModel
- [ ] Ensure Isar annotations are complete
- [ ] Test JSON serialization/deserialization

#### 1.2 Complete API Services (3-4 hours)
**Current State:**
- `auth_api.dart` ✓ (Working)
- `songs_api.dart` (Partial)
- `playlists_api.dart` (Partial)
- `recommendations_api.dart` (Partial)
- `analytics_api.dart` (Partial)

**Tasks:**
```dart
// auth_api.dart - Already working ✓
// Endpoints: login, register, logout, refresh, forgot-password, reset-password

// songs_api.dart - EXPAND
✓ getSongs() - paginated list
✓ searchSongs() - search functionality
✓ getStreamUrl() - get streaming URL
✓ trackPlay() - track play count
+ getSongById() - get single song
+ getPopularSongs() - trending songs
+ getRecentlyPlayed() - user history
+ getFavorites() - favorite songs
+ toggleFavorite() - add/remove favorite
+ uploadSong() - upload new song
+ updateSongMetadata() - edit song info
+ deleteSong() - delete song

// playlists_api.dart - EXPAND
+ getUserPlaylists() - get all user playlists
+ getPlaylistById() - get single playlist
+ createPlaylist() - create new playlist
+ updatePlaylist() - update playlist details
+ deletePlaylist() - delete playlist
+ addSongToPlaylist() - add song
+ removeSongFromPlaylist() - remove song

// recommendations_api.dart - EXPAND
+ getRecommendations() - personalized recommendations
+ getSimilarSongs() - similar to song
+ getMoodPlaylist() - mood-based suggestions

// analytics_api.dart - EXPAND
+ trackListening() - track user behavior
+ getUserStats() - user listening stats
+ getTopSongs() - user top songs
```

#### 1.3 Local Database Setup (2-3 hours)
**Files to Create:**
- `/app/data/datasources/local/isar_database.dart` - **CREATE**
- `/app/data/datasources/local/cache_manager.dart` - **CREATE**

**Tasks:**
```dart
// isar_database.dart
- Initialize Isar instance
- Register collections (Song, Playlist, User, UserInteraction)
- Provide database instance to app
- Handle migrations

// cache_manager.dart  
- Cache songs for offline playback
- Cache playlists
- Cache user preferences
- Implement TTL and size limits
- Handle cache invalidation
```

#### 1.4 Mappers (1-2 hours)
**Files to Create:**
- `/app/data/mappers/song_mapper.dart` - **CREATE**
- `/app/data/mappers/playlist_mapper.dart` - **CREATE**
- `/app/data/mappers/user_mapper.dart` - **CREATE**

**Tasks:**
```dart
// Convert Model ↔ Entity
- SongModel ↔ SongEntity
- PlaylistModel ↔ PlaylistEntity  
- UserModel ↔ UserEntity
```

#### 1.5 Complete Repositories (3-4 hours)
**Current State:**
- `auth_repository.dart` ✓ (Working)
- `song_repository.dart` (Partial)
- `playlist_repository.dart` (Partial)
- `recommendation_repository.dart` (Partial)
- `analytics_repository.dart` (Partial)

**Tasks:**
```dart
// song_repository.dart - IMPLEMENT
class SongRepository {
  final SongsApi _songsApi;
  final CacheManager _cacheManager;
  
  // Remote + Cache strategy
  Future<List<Song>> getSongs({bool forceRefresh = false}) {
    // 1. Check cache first
    // 2. If cache miss or forceRefresh, fetch from API
    // 3. Save to cache
    // 4. Return data
  }
  
  Future<Song> getSongById(String id) {...}
  Future<List<Song>> searchSongs(String query) {...}
  Future<List<Song>> getPopularSongs() {...}
  Future<List<Song>> getRecentlyPlayed() {...}
  Future<List<Song>> getFavorites() {...}
  Future<void> toggleFavorite(String songId) {...}
  Future<String> getStreamUrl(String songId, String quality) {...}
  Future<void> trackPlay(String songId) {...}
}

// playlist_repository.dart - IMPLEMENT
class PlaylistRepository {
  Future<List<Playlist>> getUserPlaylists() {...}
  Future<Playlist> getPlaylistById(String id) {...}
  Future<Playlist> createPlaylist(String name, String description) {...}
  Future<void> updatePlaylist(String id, Map<String, dynamic> updates) {...}
  Future<void> deletePlaylist(String id) {...}
  Future<void> addSongToPlaylist(String playlistId, String songId) {...}
  Future<void> removeSongFromPlaylist(String playlistId, String songId) {...}
}

// recommendation_repository.dart - IMPLEMENT
// analytics_repository.dart - IMPLEMENT
```

---

### Phase 2: Services Layer (Priority 2)

#### 2.1 Complete Audio Services (4-5 hours)
**Files to Update/Create:**
- `/app/services/audio/audio_player_service.dart` (Expand)
- `/app/services/audio/audio_cache_service.dart` (Implement)
- `/app/services/audio/prefetch_service.dart` (Implement)

**Tasks:**
```dart
// audio_player_service.dart - EXPAND
class AudioPlayerService extends GetxService {
  final AudioPlayer _audioPlayer;
  final SongRepository _songRepository;
  
  // Player controls
  Future<void> playSong(Song song) {...}
  Future<void> pause() {...}
  Future<void> resume() {...}
  Future<void> stop() {...}
  Future<void> seek(Duration position) {...}
  Future<void> setVolume(double volume) {...}
  
  // Queue management
  Future<void> playNext() {...}
  Future<void> playPrevious() {...}
  Future<void> setQueue(List<Song> songs) {...}
  Future<void> addToQueue(Song song) {...}
  Future<void> removeFromQueue(int index) {...}
  Future<void> shuffle() {...}
  void setRepeatMode(RepeatMode mode) {...}
  
  // Stream quality
  Future<void> setQuality(String quality) {...}
  
  // Playback tracking
  void _trackPlayback() {...}
  
  // State management
  Rx<Song?> currentSong;
  Rx<Duration> position;
  Rx<Duration?> duration;
  Rx<bool> isPlaying;
  Rx<bool> isBuffering;
  Rx<List<Song>> queue;
}

// audio_cache_service.dart - IMPLEMENT
class AudioCacheService {
  Future<void> cacheSong(Song song, String quality) {...}
  Future<bool> isCached(String songId, String quality) {...}
  Future<String?> getCachedPath(String songId, String quality) {...}
  Future<void> removeCached(String songId) {...}
  Future<void> clearCache() {...}
  Future<int> getCacheSize() {...}
}

// prefetch_service.dart - IMPLEMENT  
class PrefetchService {
  Future<void> prefetchNext() {...}
  Future<void> prefetchQueue() {...}
}
```

#### 2.2 Network Service (1 hour)
**File:** `/app/services/network/network_service.dart` (Expand)

```dart
class NetworkService extends GetxService {
  Rx<bool> isConnected;
  Rx<NetworkSpeed> speed;
  
  Future<bool> checkConnection() {...}
  Future<NetworkSpeed> measureSpeed() {...}
  String getRecommendedQuality() {...}
}
```

#### 2.3 Analytics Service (1-2 hours)
**File:** `/app/services/analytics/analytics_service.dart` (Expand)

```dart
class AnalyticsService extends GetxService {
  Future<void> trackPlay(String songId) {...}
  Future<void> trackSkip(String songId) {...}
  Future<void> trackComplete(String songId) {...}
  Future<void> trackSearch(String query) {...}
  Future<void> trackShare(String songId) {...}
}
```

---

### Phase 3: Domain Layer (Priority 3)

#### 3.1 Complete Entities (1-2 hours)
**Current State:**
- `/app/domain/entities/song_entity.dart` ✓ (Exists)
- `/app/domain/entities/playlist_entity.dart` ✓ (Exists)
- `/app/domain/entities/user_entity.dart` ✓ (Exists)

**Tasks:**
- [ ] Review entities match business requirements
- [ ] Add missing: RecommendationEntity, AnalyticsEntity

#### 3.2 Use Cases (3-4 hours)
**Files to Create:**
```
/app/domain/usecases/
  auth_usecases.dart ✓ (Exists - verify)
  song_usecases.dart (Exists - expand)
  playlist_usecases.dart (Create)
  recommendation_usecases.dart (Create)
```

**Tasks:**
```dart
// song_usecases.dart
class GetSongsUseCase {
  final SongRepository repository;
  Future<Result<List<Song>>> call({bool forceRefresh = false}) {...}
}

class SearchSongsUseCase {...}
class GetPopularSongsUseCase {...}
class ToggleFavoriteUseCase {...}
class GetStreamUrlUseCase {...}

// playlist_usecases.dart
class GetPlaylistsUseCase {...}
class CreatePlaylistUseCase {...}
class AddSongToPlaylistUseCase {...}
class RemoveSongFromPlaylistUseCase {...}

// recommendation_usecases.dart
class GetRecommendationsUseCase {...}
class GetSimilarSongsUseCase {...}
```

---

### Phase 4: Presentation Layer - Controllers (Priority 4)

#### 4.1 Update Existing Controllers (3-4 hours)
**Files to Update:**
- `/app/presentation/controllers/auth_controller.dart` ✓ (Working)
- `/app/presentation/controllers/songs_controller.dart` (Expand)
- `/app/presentation/controllers/audio_player_controller.dart` (Expand)
- `/app/presentation/controllers/playlist_controller.dart` (Expand)

**Tasks:**
```dart
// songs_controller.dart - EXPAND
class SongsController extends GetxController with ErrorHandlerMixin, LoadingMixin {
  final GetSongsUseCase _getSongsUseCase;
  final SearchSongsUseCase _searchSongsUseCase;
  final GetPopularSongsUseCase _getPopularSongsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  
  // State
  final songs = <Song>[].obs;
  final popularSongs = <Song>[].obs;
  final searchResults = <Song>[].obs;
  final searchQuery = ''.obs;
  
  // Methods
  Future<void> loadSongs({bool forceRefresh = false}) async {...}
  Future<void> loadPopularSongs() async {...}
  Future<void> searchSongs(String query) async {...}
  Future<void> toggleFavorite(String songId) async {...}
  Future<void> refreshSongs() async {...}
}

// audio_player_controller.dart - EXPAND
class AudioPlayerController extends GetxController {
  final AudioPlayerService _audioPlayerService;
  
  // Delegate to service
  Future<void> playSong(Song song) => _audioPlayerService.playSong(song);
  Future<void> pause() => _audioPlayerService.pause();
  Future<void> resume() => _audioPlayerService.resume();
  Future<void> playNext() => _audioPlayerService.playNext();
  Future<void> playPrevious() => _audioPlayerService.playPrevious();
  Future<void> seek(Duration position) => _audioPlayerService.seek(position);
  
  // Computed properties
  Song? get currentSong => _audioPlayerService.currentSong.value;
  bool get isPlaying => _audioPlayerService.isPlaying.value;
  Duration get position => _audioPlayerService.position.value;
  Duration? get duration => _audioPlayerService.duration.value;
  List<Song> get queue => _audioPlayerService.queue.value;
}

// playlist_controller.dart - EXPAND
class PlaylistController extends GetxController {
  final GetPlaylistsUseCase _getPlaylistsUseCase;
  final CreatePlaylistUseCase _createPlaylistUseCase;
  final AddSongToPlaylistUseCase _addSongToPlaylistUseCase;
  
  final playlists = <Playlist>[].obs;
  final selectedPlaylist = Rxn<Playlist>();
  
  Future<void> loadPlaylists() async {...}
  Future<void> createPlaylist(String name, String description) async {...}
  Future<void> addSongToPlaylist(String playlistId, String songId) async {...}
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {...}
  Future<void> deletePlaylist(String playlistId) async {...}
}
```

#### 4.2 Create New Controllers (2-3 hours)
**Files to Create:**
- `/app/presentation/controllers/home_controller.dart` (Update)
- `/app/presentation/controllers/search_controller.dart` (Create)
- `/app/presentation/controllers/recommendations_controller.dart` (Create)

---

### Phase 5: Presentation Layer - UI Screens (Priority 5)

#### 5.1 Home Screen (4-5 hours)
**File:** `/app/presentation/screens/home/home_screen.dart`

**UI Components:**
```dart
HomeScreen
├── AppBar (with search icon, profile icon)
├── MiniPlayer (if song playing)
└── Body
    ├── RecentlyPlayedSection
    ├── PopularSongsSection  
    ├── RecommendedSection
    └── TrendingSection

// Each section has horizontal scrollable song cards
```

**Tasks:**
- [ ] Create SongCard widget
- [ ] Implement pull-to-refresh
- [ ] Add loading states
- [ ] Add empty states
- [ ] Connect to SongsController

#### 5.2 Songs List Screen (2-3 hours)
**File:** `/app/presentation/screens/songs/songs_list_screen.dart`

**Features:**
- Paginated list of all songs
- Pull to refresh
- Infinite scroll
- Search integration
- Sort/filter options

#### 5.3 Player Screen (3-4 hours)
**File:** `/app/presentation/screens/player/player_screen.dart` (Expand)

**UI Components:**
```dart
PlayerScreen
├── Album Art (with blur background)
├── Song Info (title, artist, album)
├── Progress Bar (with current/total time)
├── Player Controls (prev, play/pause, next)
├── Additional Controls (shuffle, repeat, queue, favorite)
└── Queue View (expandable)
```

**Features:**
- Now playing info
- Seek bar with gesture
- Play/pause/next/previous
- Shuffle and repeat
- Queue management
- Favorite toggle
- Share song

#### 5.4 Search Screen (3-4 hours)
**File:** `/app/presentation/screens/search/search_screen.dart` (Create)

**Features:**
- Search bar with debounce
- Recent searches
- Search suggestions
- Filtered results (songs, artists, albums, playlists)
- Clear history

#### 5.5 Playlists Screen (3-4 hours)
**File:** `/app/presentation/screens/playlists/playlists_screen.dart` (Expand)

**Features:**
- List of user playlists
- Create new playlist dialog
- Edit playlist
- Delete playlist
- Playlist detail view with songs

#### 5.6 Profile Screen (2-3 hours)
**File:** `/app/presentation/screens/profile/profile_screen.dart` (Expand)

**Features:**
- User info
- Preferences (quality, theme, etc.)
- Statistics
- Logout

---

### Phase 6: Widgets & UI Components (Priority 6)

#### 6.1 Reusable Widgets (4-5 hours)
**Files to Create:**
```
/app/presentation/widgets/
  common/
    loading_indicator.dart
    error_view.dart
    empty_state.dart
    custom_button.dart
    custom_text_field.dart
    
  song/
    song_card.dart (horizontal card)
    song_tile.dart (list tile)
    song_grid_item.dart (grid view)
    
  playlist/
    playlist_card.dart
    playlist_tile.dart
    add_to_playlist_sheet.dart
    
  player/
    mini_player.dart ✓ (Exists - verify)
    progress_bar.dart
    player_controls.dart
    queue_item.dart
```

---

### Phase 7: Advanced Features (Priority 7)

#### 7.1 Offline Support (3-4 hours)
- Implement cache management
- Download songs for offline
- Offline mode detection
- Sync when online

#### 7.2 Background Playback (2-3 hours)
- Notification controls
- Lock screen controls
- Background audio service

#### 7.3 Search with Filters (2-3 hours)
- Advanced search
- Filter by genre, mood, artist
- Sort options

#### 7.4 Recommendations (2-3 hours)
- Personalized recommendations
- Similar songs
- Mood-based playlists

---

## 📋 Step-by-Step Implementation Order

### Week 1: Data Foundation
**Day 1-2:**
1. ✅ Review and verify all models
2. ✅ Implement Isar database setup
3. ✅ Create cache manager
4. ✅ Implement mappers

**Day 3-4:**
5. ✅ Complete all API services
6. ✅ Implement song repository
7. ✅ Implement playlist repository
8. ✅ Test data layer end-to-end

**Day 5:**
9. ✅ Add error handling
10. ✅ Add logging
11. ✅ Write unit tests for data layer

### Week 2: Services & Domain
**Day 1-2:**
1. ✅ Complete AudioPlayerService
2. ✅ Implement AudioCacheService
3. ✅ Implement PrefetchService
4. ✅ Complete NetworkService

**Day 3-4:**
5. ✅ Implement all use cases
6. ✅ Add business logic validation
7. ✅ Write unit tests

**Day 5:**
8. ✅ Integration testing
9. ✅ Performance optimization

### Week 3: Controllers & State
**Day 1-2:**
1. ✅ Update SongsController
2. ✅ Update AudioPlayerController
3. ✅ Update PlaylistController
4. ✅ Create SearchController

**Day 3-4:**
5. ✅ Create RecommendationsController
6. ✅ Wire up all bindings
7. ✅ Test state management

**Day 5:**
8. ✅ Error handling in controllers
9. ✅ Loading states

### Week 4: UI Implementation
**Day 1:**
1. ✅ Build reusable widgets
2. ✅ Create SongCard, SongTile
3. ✅ Create PlaylistCard

**Day 2:**
4. ✅ Implement HomeScreen UI
5. ✅ Test HomeScreen with mock data

**Day 3:**
6. ✅ Implement PlayerScreen UI
7. ✅ Test player functionality

**Day 4:**
8. ✅ Implement SearchScreen
9. ✅ Implement PlaylistsScreen

**Day 5:**
10. ✅ Polish UI
11. ✅ Add animations
12. ✅ Test on devices

### Week 5: Integration & Testing
**Day 1-2:**
1. ✅ End-to-end testing
2. ✅ Fix bugs
3. ✅ Performance optimization

**Day 3-4:**
4. ✅ Implement offline support
5. ✅ Background playback
6. ✅ Notification controls

**Day 5:**
7. ✅ Final polish
8. ✅ Documentation
9. ✅ Deployment preparation

---

## 🎯 Next Immediate Steps (Start Here!)

### Step 1: Verify and Fix Models (TODAY)
```bash
# Check if models are properly generated
cd freeTuneFrontend/freetune
flutter pub run build_runner build --delete-conflicting-outputs

# Verify models work with backend
# Test serialization/deserialization
```

### Step 2: Implement Isar Database (TODAY)
Create `/app/data/datasources/local/isar_database.dart`

### Step 3: Complete SongsApi (TODAY)
Update `/app/data/datasources/remote/songs_api.dart` with all endpoints

### Step 4: Implement SongRepository (TOMORROW)
Complete `/app/data/repositories/song_repository.dart` with cache strategy

### Step 5: Test Data Flow (TOMORROW)
Test: API → Repository → Cache → Controller

---

## 📦 Required Packages (Verify in pubspec.yaml)

```yaml
dependencies:
  # State Management
  get: ^4.6.6
  
  # Networking
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1
  
  # Local Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2
  
  # Audio
  just_audio: ^0.9.36
  just_audio_background: ^0.0.1-beta.11
  audio_session: ^0.1.18
  
  # Cache
  flutter_cache_manager: ^3.3.1
  shared_preferences: ^2.2.2
  
  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.19.0
  equatable: ^2.0.5
  dartz: ^0.10.1

dev_dependencies:
  build_runner: ^2.4.8
  isar_generator: ^3.1.0+1
  json_serializable: ^6.7.1
```

---

## 🎉 Success Criteria

### Phase 1 Complete When:
- ✅ All models generated and working
- ✅ Isar database initialized
- ✅ All API services implemented
- ✅ Repositories with cache working
- ✅ Data flows from API → Cache → App

### Phase 2 Complete When:
- ✅ Audio player plays songs
- ✅ Queue management works
- ✅ Network service detects connectivity
- ✅ Services are singleton and accessible

### Phase 3 Complete When:
- ✅ Use cases handle business logic
- ✅ Error handling is consistent
- ✅ Domain layer is independent

### Phase 4 Complete When:
- ✅ Controllers manage state properly
- ✅ Loading and error states work
- ✅ GetX reactive system working

### Phase 5 Complete When:
- ✅ All screens functional
- ✅ Navigation works smoothly
- ✅ UI is responsive and polished

---

## 🚀 Let's Start Building!

**First Task**: Shall we start with completing the Data Layer (Phase 1)?

I recommend we begin with:
1. Verify/fix all models
2. Setup Isar database
3. Complete API services
4. Implement repositories with caching

This will give us a solid foundation to build upon. What do you think?
