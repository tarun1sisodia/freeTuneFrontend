import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/song_entity.dart';
import '../../data/repositories/song_repository.dart';
import '../../core/utils/logger.dart';

class SongSearchController extends GetxController {
  final SongRepository _songRepository;
  SongSearchController(this._songRepository);

  final searchController = TextEditingController();
  final searchResults = <SongEntity>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();
  Timer? _debounce;

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
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

    isLoading.value = true;
    error.value = null;
    try {
      logger.d('Searching for: $query');
      final results = await _songRepository.searchSongs(query);
      searchResults.value = results;
    } catch (e) {
      logger.e('Search error: $e');
      error.value = 'Failed to search songs';
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    error.value = null;
  }
}
