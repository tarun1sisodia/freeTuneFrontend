import 'package:get/get.dart';
import '../../domain/entities/song_entity.dart';
import '../../data/repositories/song_repository.dart';

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
  final isSearching = false.obs;
  final isLoadingMore = false.obs;

  // Pagination state
  int _currentPage = 1;
  bool _isLastPage = false;
  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  void fetchInitialData() {
    fetchSongs();
    // fetchPopularSongs(); // Uncomment when ready
    // fetchRecentlyPlayed(); // Uncomment when ready
    // fetchFavorites(); // Uncomment when ready
  }

  Future<void> fetchSongs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _isLastPage = false;
      songs.clear();
    }
    isLoadingSongs.value = true;
    try {
      final response = await _songRepository.getSongs(page: _currentPage, limit: _limit);
      if (response.isEmpty) {
        _isLastPage = true;
      } else {
        songs.addAll(response);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load songs.');
    } finally {
      isLoadingSongs.value = false;
    }
  }

  Future<void> loadMoreSongs() async {
    if (isLoadingMore.value || _isLastPage) return;

    isLoadingMore.value = true;
    _currentPage++;
    try {
      final response = await _songRepository.getSongs(page: _currentPage, limit: _limit);
      if (response.isEmpty) {
        _isLastPage = true;
      } else {
        songs.addAll(response);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load more songs.');
      _currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /*
  Future<void> fetchPopularSongs() async {
    isLoadingPopular.value = true;
    try {
      // popularSongs.value = await _songRepository.getPopularSongs();
    } catch (e) {
      Get.snackbar('Error', 'Could not load popular songs.');
    } finally {
      isLoadingPopular.value = false;
    }
  }
  */

  Future<void> search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      final response = await _songRepository.searchSongs(query);
      searchResults.value = response;
    } catch (e) {
      Get.snackbar('Error', 'Search failed.');
    } finally {
      isSearching.value = false;
    }
  }
}