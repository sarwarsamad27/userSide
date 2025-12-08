import 'package:flutter/material.dart';
import 'package:user_side/models/ProductAndCategoryModel/deleteReview_model.dart';
import 'package:user_side/models/ProductAndCategoryModel/editReview_model.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/editReview_repository.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/deleteReview_repository.dart';

class ReviewActionProvider extends ChangeNotifier {
  final EditReviewRepository editRepo = EditReviewRepository();
  final DeleteReviewRepository deleteRepo = DeleteReviewRepository();

  EditReviewModel? editResponse;
  DeleteReviewModel? deleteResponse;

  bool isLoading = false;

  /// Edit Review
  Future<void> editReview({
    required String reviewId,
    required String userId,
    required String text,
    required String stars,
  }) async {
    isLoading = true;
    notifyListeners();

    editResponse = await editRepo.editReview(reviewId, userId, text, stars);

    isLoading = false;
    notifyListeners();
  }

  /// Delete Review
  Future<void> deleteReview({
    required String reviewId,
    required String userId,
  }) async {
    isLoading = true;
    notifyListeners();

    deleteResponse = await deleteRepo.editReview(reviewId, userId);

    isLoading = false;
    notifyListeners();
  }
}
