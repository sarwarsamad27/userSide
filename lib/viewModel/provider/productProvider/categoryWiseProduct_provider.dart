import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/categoryWiseProduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/categoryWiseProduct_repository.dart';

class GetCategoryWiseProductProvider with ChangeNotifier {
  final GetCategoryWiseProductRepository _repo =
      GetCategoryWiseProductRepository();

  /// STATIC CACHE FOR EACH CATEGORY
  static Map<String, List<Data>> cachedCategoryProducts = {};

  bool loading = false;
  int page = 1;
  int limit = 10;
  bool hasMore = true;

  List<Data> products = [];

  Future<void> fetchCategoryProducts(
    String category, {
    bool refresh = false,
  }) async {
    /// ------- 1. Static cache se load karo (only if not refresh) -------
    if (!refresh && cachedCategoryProducts.containsKey(category)) {
      products = List.from(cachedCategoryProducts[category]!);
      notifyListeners();
      return;
    }

    /// ------- 2. Already loading ho to return -------
    if (loading) return;

    if (refresh) {
      page = 1;
      hasMore = true;
      products.clear();
      cachedCategoryProducts.remove(category); // clear only that category
      notifyListeners();
    }

    loading = true;
    notifyListeners();

    final response = await _repo.getCategoryWiseProduct(category, limit, page);

    if (response.data != null && response.data!.isNotEmpty) {
      products.addAll(response.data!);

      /// STATIC CACHE UPDATE karein (per category)
      cachedCategoryProducts[category] = List.from(products);

      page++;
    } else {
      hasMore = false;
    }

    loading = false;
    notifyListeners();
  }

  void clearCategoryCache(String category) {
    cachedCategoryProducts.remove(category);
    notifyListeners();
  }
}
