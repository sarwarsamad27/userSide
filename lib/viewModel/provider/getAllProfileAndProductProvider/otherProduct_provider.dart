import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/otherProduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/otherProduct_repository.dart';

class OtherProductProvider extends ChangeNotifier {
  final OtherProductRepository repository = OtherProductRepository();

  OtherProductModel? otherModel;
  bool loading = false;
  int currentPage = 1;
  int limit = 10;

  Future<void> fetchOtherProducts(String productId, {int page = 1}) async {
    loading = true;
    notifyListeners();

    currentPage = page;
    try {
      otherModel = await repository.otherProduct(currentPage, productId, limit);
    } catch (e) {
      otherModel = OtherProductModel(otherProducts: [], message: "Error: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> loadMore(String productId) async {
    if (otherModel == null) return;
    if (currentPage >= (otherModel!.totalPages ?? 1)) return;

    currentPage += 1;
    try {
      final newData = await repository.otherProduct(currentPage, productId, limit);
      otherModel!.otherProducts?.addAll(newData.otherProducts ?? []);
      otherModel!.totalPages = newData.totalPages;
    } catch (e) {
      // ignore
    }
    notifyListeners();
  }
}
