import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/getAllProduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/getAllproduct_repository.dart';

class GetAllProductProvider extends ChangeNotifier {
  final GetAllProductRepository repository = GetAllProductRepository();

  List<Products> allProducts = [];
  List<Products> filteredProducts = [];
  Pagination? pagination;

  bool loading = false;
  bool loadMore = false;

  int page = 1;
  int limit = 20; // ✅ ADD: page size

  bool isFetchedOnce = false;

  // ✅ derived flag (safe)
  bool get hasMore {
    if (pagination == null) return true; // first time assume true
    if (pagination!.hasMore != null) return pagination!.hasMore!;
    // fallback: if model has totalPages/currentPage
    final totalPages = pagination!.totalPages;
    final currentPage = pagination!.limit;
    if (totalPages != null && currentPage != null)
      return currentPage < totalPages;
    return true;
  }

  void setLimit(int newLimit) {
    // ✅ avoid invalid limit
    limit = newLimit.clamp(1, 100);
    // reset & refetch
    isFetchedOnce = false;
    fetchProducts(loadMoreRequest: false);
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = List.from(allProducts);
    } else {
      final q = query.toLowerCase();
      filteredProducts = allProducts.where((p) {
        return (p.name?.toLowerCase().contains(q) ?? false) ||
            (p.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchProducts({bool loadMoreRequest = false}) async {
    // ✅ avoid double calls
    if (loading || loadMore) return;

    // ✅ if already fetched and not loadMore, skip
    if (isFetchedOnce && !loadMoreRequest) return;

    if (loadMoreRequest) {
      // ✅ don't load more if no more pages
      if (!hasMore) return;

      loadMore = true;
      page = page + 1; // ✅ increment only when allowed
    } else {
      loading = true;
      page = 1;
      allProducts.clear();
      filteredProducts.clear();
      pagination = null;
    }

    try {
      final response = await repository.getAllProduct(page: page);

      if (response.success == true) {
        final newProducts = response.data?.products ?? [];

        if (loadMoreRequest) {
          allProducts.addAll(newProducts);

          // ✅ if search/filter active, don't blindly append into filtered
          // safest: keep filtered in sync with allProducts if no filter/search applied
          // For now: keep same behavior (append)
          filteredProducts.addAll(newProducts);
        } else {
          allProducts = newProducts;
          filteredProducts = List.from(newProducts);
          isFetchedOnce = true;
        }

        pagination = response.data?.pagination;

        // ✅ if API returns empty list, stop further loadMore
        // (defensive if backend doesn't send hasMore)
        if (newProducts.isEmpty &&
            pagination != null &&
            pagination!.hasMore == null) {
          pagination!.hasMore = false;
        }
      } else {
        // ✅ if failed on loadMore, rollback page increment
        if (loadMoreRequest) page = (page > 1) ? page - 1 : 1;
      }
    } catch (_) {
      if (loadMoreRequest) page = (page > 1) ? page - 1 : 1;
    } finally {
      loading = false;
      loadMore = false;
      notifyListeners();
    }
  }

  void clearFilter() {
    filteredProducts = List.from(allProducts);
    notifyListeners();
  }

  void filterByCategory(String categoryName) {
    final q = categoryName.toLowerCase();
    filteredProducts = allProducts.where((p) {
      // NOTE: yahan aap product.categoryName field use karein agar model me hai
      // currently aap name compare kar rahe hain jo wrong ho sakta hai
      return (p.name?.toLowerCase() ?? "") == q;
    }).toList();

    notifyListeners();
  }
}
