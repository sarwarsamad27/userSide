import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllProductCategoryWise_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllProductCategoryWise_repository.dart';

class GetAllProductCategoryWiseProvider with ChangeNotifier {
  final GetAllProductCategoryWiseRepository repo =
      GetAllProductCategoryWiseRepository();

  bool isLoading = false;
  GetAllProductCategoryWiseModel? data;

  Future<void> fetchProducts(String profileId, String categoryId) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await repo.getAllCategoryProfileWise(
        categoryId,
        profileId,
      );
      data = response;
    } catch (e) {
      data = GetAllProductCategoryWiseModel(
        message: e.toString(),
        products: [],
      );
    }

    isLoading = false;
    notifyListeners();
  }
}
