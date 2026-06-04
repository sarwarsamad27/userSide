import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllProductCategoryWise_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllProductCategoryWise_repository.dart';

class GetAllProductCategoryWiseProvider with ChangeNotifier {
  final GetAllProductCategoryWiseRepository repo =
      GetAllProductCategoryWiseRepository();

  bool isLoading = false;
  GetAllProductCategoryWiseModel? data;
  String? _cachedKey; // ✅ "{profileId}_{categoryId}"

  Future<void> fetchProducts(String profileId, String categoryId) async {
    final key = '${profileId}_$categoryId';

    // ✅ Skip if same combination already loaded
    if (_cachedKey == key && data != null) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await repo.getAllCategoryProfileWise(
        categoryId,
        profileId,
      );
      data = response;
      _cachedKey = key; // ✅ Cache on success
    } catch (e) {
      data = GetAllProductCategoryWiseModel(
        message: e.toString(),
        products: [],
      );
      _cachedKey = null; // ❌ Don't cache errors
    }

    isLoading = false;
    notifyListeners();
  }
}
