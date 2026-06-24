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

  // Decrement stock locally after a successful order (no refetch needed)
  void decrementStock(int orderedQty) {
    final product = productData?.product;
    if (product == null) return;
    final current = product.quantity ?? 0;
    product.quantity = (current - orderedQty).clamp(0, current);
    notifyListeners();
  }

  Future<void> fetchSingleProduct(String productId) async {
    loading = true;
    notifyListeners();

    productData = await _repo.getSingleProduct(productId);

    loading = false;
    notifyListeners();
  }
}
