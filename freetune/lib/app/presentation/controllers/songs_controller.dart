import 'package:get/get.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/song_entity.dart';
import '../../data/repositories/song_repository.dart';

/// Controller for managing songs data and state
class SongController extends GetxController {
  final SongRepository _songRepository;
  SongController(this._songRepository);

  // Observable lists for different song categories
  final songs = <SongEntity>[].obs;
  final popularSongs = <SongEntity>[].obs;
  final recentlyPlayed = <SongEntity>[].obs;
  final favorites = <SongEntity>[].obs;
  final searchResults = <SongEntity>[].obs;

  // Loading states for each section
  final isLoadingSongs = false.obs;
  final isLoadingPopular = false.obs;
  final isLoadingRecent = false.obs;
  final isLoadingFavorites = false.obs;
  final isSearching = false.obs;
  final isLoadingMore = false.obs;

  // Error states
  final error = Rxn<String>();
  final popularError = Rxn<String>();
  final recentError = Rxn<String>();
  final favoritesError = Rxn<String>();

  // Pagination state
  int _currentPage = 1;
  bool _isLastPage = false;
  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  /// Fetch all initial data for home screen
  void fetchInitialData() {
    logger.i('Fetching initial data for SongController');
    fetchSongs();
    fetchPopularSongs();
    fetchRecentlyPlayed();
    fetchFavorites();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    logger.i('Refreshing all songs data');
    await Future.wait([
      fetchSongs(refresh: true),
      fetchPopularSongs(forceRefresh: true),
      fetchRecentlyPlayed(forceRefresh: true),
      fetchFavorites(forceRefresh: true),
    ]);
  }

  /// Fetch paginated songs list
  Future<void> fetchSongs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _isLastPage = false;
      songs.clear();
      error.value = null;
    }
    
    isLoadingSongs.value = true;
    try {
      logger.d('Fetching songs - page: $_currentPage');
      final response = await _songRepository.getSongs(
        page: _currentPage,
        limit: _limit,
        forceRefresh: refresh,
      );
      
      if (response.isEmpty) {
        _isLastPage = true;
        logger.d('No more songs to load');
      } else {
        songs.addAll(response);
        logger.d('Loaded ${response.length} songs');
      }
      error.value = null;
    } catch (e) {
      logger.e('Error fetching songs: $e');
      error.value = 'Could not load songs. Please try again.';
      Get.snackbar(
        'Error',
        'Could not load songs.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingSongs.value = false;
    }
  }

  /// Load more songs for pagination
  Future<void> loadMoreSongs() async {
    if (isLoadingMore.value || _isLastPage) return;

    isLoadingMore.value = true;
    _currentPage++;
    try {
      logger.d('Loading more songs - page: $_currentPage');
      final response = await _songRepository.getSongs(
        page: _currentPage,
        limit: _limit,
      );
      
      if (response.isEmpty) {
        _isLastPage = true;
        logger.d('Reached last page');
      } else {
        songs.addAll(response);
        logger.d('Loaded ${response.length} more songs');
      }
    } catch (e) {
      logger.e('Error loading more songs: $e');
      _currentPage--;
      Get.snackbar(
        'Error',
        'Could not load more songs.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Fetch popular songs
  Future<void> fetchPopularSongs({bool forceRefresh = false}) async {
    isLoadingPopular.value = true;
    popularError.value = null;
    try {
      logger.d('Fetching popular songs');
      final response = await _songRepository.getPopularSongs(
        limit: 20,
        forceRefresh: forceRefresh,
      );
      popularSongs.value = response;
      logger.d('Loaded ${response.length} popular songs');
    } catch (e) {
      logger.e('Error fetching popular songs: $e');
      popularError.value = 'Could not load popular songs';
    } finally {
      isLoadingPopular.value = false;
    }
  }

  /// Fetch recently played songs
  Future<void> fetchRecentlyPlayed({bool forceRefresh = false}) async {
    isLoadingRecent.value = true;
    recentError.value = null;
    try {
      logger.d('Fetching recently played songs');
      final response = await _songRepository.getRecentlyPlayed(limit: 20);
      recentlyPlayed.value = response;
      logger.d('Loaded ${response.length} recently played songs');
    } catch (e) {
      logger.e('Error fetching recently played: $e');
      recentError.value = 'Could not load recently played';
    } finally {
      isLoadingRecent.value = false;
    }
  }

  /// Fetch favorite songs
  Future<void> fetchFavorites({bool forceRefresh = false}) async {
    isLoadingFavorites.value = true;
    favoritesError.value = null;
    try {
      logger.d('Fetching favorite songs');
      final response = await _songRepository.getFavorites(
        forceRefresh: forceRefresh,
      );
      favorites.value = response;
      logger.d('Loaded ${response.length} favorite songs');
    } catch (e) {
      logger.e('Error fetching favorites: $e');
      favoritesError.value = 'Could not load favorites';
    } finally {
      isLoadingFavorites.value = false;
    }
  }

  /// Toggle favorite status of a song
  Future<void> toggleFavorite(String songId) async {
    try {
      logger.d('Toggling favorite for song: $songId');
      await _songRepository.toggleFavorite(songId);
      
      // Update local state
      final songIndex = songs.indexWhere((s) => s.songId == songId);
      if (songIndex != -1) {
        songs[songIndex] = songs[songIndex].copyWith(
          isFavorite: !(songs[songIndex].isFavorite ?? false),
        );
        songs.refresh();
      }
      
      // Refresh favorites list
      await fetchFavorites(forceRefresh: true);
      
      Get.snackbar(
        'Success',
        'Favorite updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      logger.e('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Could not update favorite.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Search songs
  Future<void> search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    
    isSearching.value = true;
    try {
      logger.d('Searching songs with query: $query');
      final response = await _songRepository.searchSongs(query);
      searchResults.value = response;
      logger.d('Found ${response.length} songs');
    } catch (e) {
      logger.e('Error searching songs: $e');
      Get.snackbar(
        'Error',
        'Search failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSearching.value = false;
    }
  }

  /// Get song by ID
  Future<SongEntity?> getSongById(String id) async {
    try {
      logger.d('Fetching song by ID: $id');
      return await _songRepository.getSongById(id);
    } catch (e) {
      logger.e('Error fetching song by ID: $e');
      Get.snackbar(
        'Error',
        'Could not load song details.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Clear search results
  void clearSearch() {
    searchResults.clear();
  }

  /// Clear all errors
  void clearErrors() {
    error.value = null;
    popularError.value = null;
    recentError.value = null;
    favoritesError.value = null;
  }
}