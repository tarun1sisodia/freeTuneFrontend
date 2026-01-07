import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/song_entity.dart';
import '../../data/repositories/song_repository.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/local/cache_manager.dart';
import '../../data/mappers/song_mapper.dart';
import '../../core/utils/logger.dart';

class SongSearchController extends GetxController {
  final SongRepository _songRepository;
  SongSearchController(this._songRepository);

  final searchController = TextEditingController();
  final searchResults = <SongEntity>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();
  final isImporting = false.obs;
  Timer? _debounce;
  CancelToken? _cancelToken;

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    _cancelToken?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        search(query);
      } else {
        clearSearch();
      }
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    // Cancel previous request
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    isLoading.value = true;
    error.value = null;

    try {
      logger.d('Searching for: $query');

      // 1. Try API search
      final results = await _songRepository.searchSongs(
        query,
        cancelToken: _cancelToken,
      );
      searchResults.value = results;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;

      logger.w('Network error during search: $e');
      _handleSearchError(query, 'Network error. Checking offline results...');
    } on TimeoutException catch (e) {
      logger.e('Search timeout: $e');
      _handleSearchError(
          query, 'Search timed out. Checking offline results...');
    } catch (e) {
      logger.e('Search error: $e');
      // If it's an ApiException from repository (likely wrapping the error)
      _handleSearchError(
          query, 'Failed to search online. Checking offline results...');
    } finally {
      // Only set loading false if not cancelled (or token matches)
      if (!(_cancelToken?.isCancelled ?? false)) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _handleSearchError(String query, String errorMessage) async {
    try {
      // Fallback: Search local cache
      logger.i('Attempting local fallback search for: $query');

      // Access CacheManager via Get.find as it acts as our local data source
      // We rely on the fact that CacheManager is injected in InitialBinding
      final cacheManager = Get.find<CacheManager>();
      final localModels = await cacheManager.searchCachedSongs(query);

      if (localModels.isNotEmpty) {
        // Convert models to entities
        final localEntities =
            localModels.map((m) => SongMapper.fromModel(m)).toList();
        searchResults.value = localEntities;
        error.value = '$errorMessage Showing cached results.';
      } else {
        error.value = '$errorMessage No local results found.';
        searchResults.clear();
      }
    } catch (e) {
      logger.e('Local fallback failed: $e');
      error.value = errorMessage;
      searchResults.clear();
    }
  }

  Future<void> requestDownload(String query) async {
    if (query.trim().isEmpty) return;

    isImporting.value = true;
    try {
      await _songRepository.requestSongImport(query);
      Get.snackbar(
        'Request Sent',
        'We are searching and downloading "$query". This may take a few minutes.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Request Failed',
        'Could not request download. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isImporting.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    error.value = null;
    _cancelToken?.cancel();
  }
}
