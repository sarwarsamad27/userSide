import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/relatedPrduct_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/relatedProduct_repository.dart';

class RelatedProductProvider extends ChangeNotifier {
  final RelatedProductRepository repo = RelatedProductRepository();

  bool loading = false;
  RelatedProductModel? relatedModel;

  int page = 1;
  int limit = 10;

  Future<void> fetchRelatedProducts(String productId, String categoryId) async {
    loading = true;
    notifyListeners();

    final response = await repo.relatedProduct(page, productId, categoryId, limit);

    relatedModel = response;
    loading = false;
    notifyListeners();
  }
}
