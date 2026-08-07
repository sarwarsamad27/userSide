import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllProfile_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllProfile_repository.dart';

class GetAllProfileProvider with ChangeNotifier {
  final GetAllProfileRepository repo = GetAllProfileRepository();

  bool isLoading = false;
  bool isLoadingMore = false;
  bool isFetchedOnce = false;
  bool hasMore = true;
  int currentPage = 1;
  int limit = 10;
  GetAllProfileModel? productData;
  List<Profiles> allProfiles = [];
  List<Profiles> filteredProfiles = [];
  String _searchQuery = '';

  Future<void> fetchProfiles({bool loadMore = false}) async {
    if (loadMore) {
      // ✅ don't load more if already loading or no more pages
      if (isLoadingMore || isLoading || !hasMore) return;
      isLoadingMore = true;
      currentPage++;
    } else {
      if (isFetchedOnce) return; // ✅ pehli baar sirf
      isFetchedOnce = true;
      isLoading = true;
      currentPage = 1;
    }
    notifyListeners();

    try {
      final response = await repo.getAllProfile(page: currentPage, limit: limit);
      final newProfiles = response.profiles ?? [];

      if (loadMore) {
        allProfiles.addAll(newProfiles);
      } else {
        newProfiles.shuffle();
        allProfiles = newProfiles;
      }

      productData = response;
      final totalPages = response.totalPages ?? 1;
      hasMore = currentPage < totalPages;
      _applySearchInternal();
    } catch (e) {
      if (loadMore) {
        currentPage--; // ✅ rollback failed page bump
        hasMore = false;
      } else {
        productData = GetAllProfileModel(message: e.toString(), profiles: []);
        allProfiles = [];
        filteredProfiles = [];
      }
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  void applySearch(String query) {
    _searchQuery = query;
    _applySearchInternal();
    notifyListeners();
  }

  void _applySearchInternal() {
    if (_searchQuery.isEmpty) {
      filteredProfiles = List.from(allProfiles);
    } else {
      final q = _searchQuery.toLowerCase();
      filteredProfiles = allProfiles
          .where((p) => (p.name ?? '').toLowerCase().contains(q))
          .toList();
    }
  }

  // ✅ Refresh — isFetchedOnce reset karo + filteredProfiles update karo
  Future<void> refreshProfiles() async {
    isFetchedOnce = false; // ✅ yeh missing tha
    currentPage = 1;
    hasMore = true;
    isLoading = true;
    notifyListeners();

    try {
      final response = await repo.getAllProfile(page: currentPage, limit: limit);
      final newProfiles = response.profiles ?? [];
      newProfiles.shuffle();
      allProfiles = newProfiles;
      productData = response;
      final totalPages = response.totalPages ?? 1;
      hasMore = currentPage < totalPages;
      _applySearchInternal();
    } catch (e) {
      productData = GetAllProfileModel(message: e.toString(), profiles: []);
      allProfiles = [];
      filteredProfiles = [];
    }

    isLoading = false;
    isFetchedOnce = true; // ✅ refresh ke baad wapas lock
    notifyListeners();
  }
}
