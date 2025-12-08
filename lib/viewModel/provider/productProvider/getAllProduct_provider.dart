import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/getAllProduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/getAllproduct_repository.dart';

class GetAllProductProvider extends ChangeNotifier {
  final GetAllProductRepository repository = GetAllProductRepository();

  List<Products> allProducts = [];
  List<Products> filteredProducts = [];   // <-- ADDED
  Pagination? pagination;

  bool loading = false;
  bool loadMore = false;
  int page = 1;

  bool isFetchedOnce = false;
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
    if (loading || loadMore) return;
    if (isFetchedOnce && !loadMoreRequest) return;

    if (loadMoreRequest) {
      if (pagination != null && pagination!.hasMore == false) return;
      loadMore = true;
      page++;
    } else {
      loading = true;
      page = 1;
      allProducts.clear();
      filteredProducts.clear();   // <-- ADDED
    }

    try {
      final response = await repository.getAllProduct(page: page);

      if (response.success == true) {
        final newProducts = response.data?.products ?? [];

        if (loadMoreRequest) {
          allProducts.addAll(newProducts);
          filteredProducts.addAll(newProducts);  // <-- ADDED
        } else {
          allProducts = newProducts;
          filteredProducts = newProducts;        // <-- ADDED
          isFetchedOnce = true;
        }

        pagination = response.data?.pagination;
      }
    } finally {
      loading = false;
      loadMore = false;
      notifyListeners();
    }
  }

  // -------- FILTERING METHODS (ADDED) --------

  void clearFilter() {
    filteredProducts = List.from(allProducts);
    notifyListeners();
  }

  void filterByCategory(String categoryName) {
    filteredProducts = allProducts
        .where((p) =>
            p.name?.toLowerCase() ==
            categoryName.toLowerCase())
        .toList();

    notifyListeners();
  }
}
