import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/popularCategory_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/popularCategory_repository.dart';

class PopularCategoryProvider extends ChangeNotifier {
  final GetPopularCategoryRepository _repository = GetPopularCategoryRepository();

  PopularCategoryModel? categoryData;
  bool loading = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 10;
  List<Categories> allCategories = [];

  /// 🔹 API should only hit once until app is killed
  bool isFetchedOnce = false;

  Future<void> fetchPopularCategories({bool loadMore = false}) async {
    if (loading) return;

    /// ❗ If already fetched once, prevent further normal calls  
    if (!loadMore && isFetchedOnce) return;

    loading = true;
    notifyListeners();

    try {
      final response = await _repository.getPopularCategory();

      if (response.success == true) {
        if (loadMore) {
          allCategories.addAll(response.categories ?? []);
        } else {
          allCategories = response.categories ?? [];
          isFetchedOnce = true; // 🔥 API will not hit again
        }

        categoryData = PopularCategoryModel(
          success: response.success,
          page: response.page,
          limit: response.limit,
          totalCategories: response.totalCategories,
          totalPages: response.totalPages,
          categories: allCategories,
        );

        // Pagination logic
        if (response.categories == null || response.categories!.length < limit) {
          hasMore = false;
        } else {
          currentPage++;
        }
      }
    } catch (e) {
      hasMore = false;
    }

    loading = false;
    notifyListeners();
  }
}
