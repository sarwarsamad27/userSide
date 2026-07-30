import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/categoryWiseProduct_model.dart';
import 'package:user_side/viewModel/provider/productProvider/categoryWiseProduct_provider.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/categoryWiseProduct_repository.dart';

/// Fetches a small preview list of products per category, used to render
/// horizontal category carousels interleaved inside the main product grid.
/// Keeps its own cache (separate instance per category) so multiple
/// categories' previews can be held in memory at once — unlike
/// [GetCategoryWiseProductProvider], which only tracks one active category.
class CategoryPreviewProvider with ChangeNotifier {
  final GetCategoryWiseProductRepository _repo =
      GetCategoryWiseProductRepository();

  final Map<String, List<Data>> _previews = {};
  final Set<String> _loading = {};

  List<Data>? previewFor(String category) => _previews[category];
  bool isLoading(String category) => _loading.contains(category);

  Future<void> fetchPreview(String category, {int limit = 10}) async {
    if (_previews.containsKey(category) || _loading.contains(category)) {
      return;
    }

    // Reuse the full-category-view cache if it's already been fetched there.
    final cached = GetCategoryWiseProductProvider.cachedCategoryProducts[category];
    if (cached != null && cached.isNotEmpty) {
      _previews[category] = cached;
      notifyListeners();
      return;
    }

    _loading.add(category);
    notifyListeners();

    try {
      final response = await _repo.getCategoryWiseProduct(category, limit, 1);
      _previews[category] = response.data ?? [];
    } catch (_) {
      _previews[category] = [];
    }

    _loading.remove(category);
    notifyListeners();
  }
}
