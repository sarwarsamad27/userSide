// provider/recommendation_provider.dart

import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/recommendedProduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/recommendedProduct_repository.dart';

class RecommendationProvider with ChangeNotifier {
  bool loading = false;
  List<RecommendedProduct> products = [];

  final RecommendationRepository _repo = RecommendationRepository();

  Future<void> fetchRecommendations(String deviceId) async {
    loading = true;
    notifyListeners();

    final result = await _repo.getRecommendedProducts(deviceId);

    if (result.success) {
      products = result.products;
    }

    loading = false;
    notifyListeners();
  }
}
