import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getSingleProduct_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getSingleProduct_repository.dart';

class GetSingleProductProvider with ChangeNotifier {
  final GetSingleProductRepository _repo = GetSingleProductRepository();

  bool loading = false;
  GetSingleProductModel? productData;
  void addNewReview(Reviews newReview) {
    productData?.reviews?.insert(0, newReview);
    notifyListeners();
  }

  Future<void> fetchSingleProduct(
    String profileId,
    String categoryId,
    String productId,
  ) async {
    loading = true;
    notifyListeners();

    productData = await _repo.getSingleProduct(
      categoryId,
      profileId,
      productId,
    );

    loading = false;
    notifyListeners();
  }
}
