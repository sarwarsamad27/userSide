import 'package:flutter/material.dart';
import 'package:user_side/viewModel/repository/ProductAndCategoryRepository/createReview_repository.dart';
import 'package:user_side/models/ProductAndCategoryModel/createReview_model.dart';

class CreateReviewProvider extends ChangeNotifier {
  final CreateReviewRepository _repo = CreateReviewRepository();

  bool loading = false;
  CreateReviewModel? reviewResponse;

  Future<void> createReview({
    required String productId,
    required String userId,
    required String stars,
    required String text,
  }) async {
    loading = true;
    notifyListeners();
    reviewResponse = await _repo.createReview(productId, userId, stars, text);

    loading = false;
    notifyListeners();
  }
}
