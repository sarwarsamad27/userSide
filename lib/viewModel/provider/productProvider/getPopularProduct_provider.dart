import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/popularProduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/popularProduct_repository.dart';

class PopularProductProvider extends ChangeNotifier {
  PopularProductModel? popularProducts;
  bool loading = false;
  int currentPage = 1;
  int limit = 10;
  bool hasMore = true;
  final GetPopularProductRepository repository = GetPopularProductRepository();

  /// 🔹 New flag to ensure API hits only once
  bool isFetchedOnce = false;

  Future<void> fetchPopularProducts({bool loadMore = false}) async {
    if (loading) return;
    if (!hasMore && loadMore) return;
    if (isFetchedOnce && !loadMore) return; // Already fetched, skip

    loading = true;
    notifyListeners();

    if (!loadMore) {
      currentPage = 1;
      popularProducts = null;
      hasMore = true;
    }

    try {
      final response = await repository.getPopularProduct();
      if (response.success == true) {
        if (loadMore && popularProducts != null) {
          popularProducts!.products!.addAll(response.products ?? []);
        } else {
          popularProducts = response;
          isFetchedOnce = true; // Mark as fetched
        }

        // Pagination check
        final totalPages = response.totalPages ?? 1;
        hasMore = currentPage < totalPages;
        currentPage++;
      } else {
        hasMore = false;
      }
    } catch (e) {
      hasMore = false;
    }

    loading = false;
    notifyListeners();
  }

  /// 🔹 Refresh method for login refresh
  Future<void> refresh() async {
    isFetchedOnce = false;
    await fetchPopularProducts();
  }

  int get totalCount => popularProducts?.totalProducts ?? 0;
  int get fetchedCount => popularProducts?.products?.length ?? 0;
}
