import 'package:get/get.dart';
import '../../data/models/common/paginated_response.dart';
import '../../data/models/song/song_model.dart';
import '../../data/repositories/song_repository.dart';

class SongController extends GetxController {
  final SongRepository _songRepository;
  SongController(this._songRepository);

  // Observable lists for different song categories
  final songs = Rx<PaginatedResponse<SongModel>?>(null);
  final popularSongs = <SongModel>[].obs;
  final recentlyPlayed = <SongModel>[].obs;
  final favorites = <SongModel>[].obs;
  final searchResults = <SongModel>[].obs;

  // Loading states for each section
  final isLoadingSongs = false.obs;
  final isLoadingPopular = false.obs;
  final isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  void fetchInitialData() {
    fetchSongs();
    fetchPopularSongs();
    // fetchRecentlyPlayed(); // Uncomment when ready
    // fetchFavorites(); // Uncomment when ready
  }

  Future<void> fetchSongs({bool refresh = false}) async {
    isLoadingSongs.value = true;
    try {
      final response = await _songRepository.getSongs();
      songs.value = response;
    } catch (e) {
      Get.snackbar('Error', 'Could not load songs.');
    } finally {
      isLoadingSongs.value = false;
    }
  }

  Future<void> loadMoreSongs() async {
    final current = songs.value;
    if (current == null || !current.hasMore) return;

    // A specific loading state for 'load more' can be added if needed
    try {
      final nextPage = current.page + 1;
      final response = await _songRepository.getSongs(page: nextPage);
      current.data.addAll(response.data);
      // current.hasMore = response.hasMore;
      songs.refresh(); // Tell listeners the list object has changed internally
    } catch (e) {
      Get.snackbar('Error', 'Could not load more songs.');
    }
  }

  Future<void> fetchPopularSongs() async {
    isLoadingPopular.value = true;
    try {
      popularSongs.value = await _songRepository.getPopularSongs();
    } catch (e) {
      Get.snackbar('Error', 'Could not load popular songs.');
    } finally {
      isLoadingPopular.value = false;
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      final response = await _songRepository.searchSongs(query: query);
      searchResults.value = response.data;
    } catch (e) {
      Get.snackbar('Error', 'Search failed.');
    } finally {
      isSearching.value = false;
    }
  }
}