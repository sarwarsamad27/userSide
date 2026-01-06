import 'package:flutter/material.dart';
import 'package:user_side/resources/local_storage.dart';

class ReviewFormProvider extends ChangeNotifier {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();

  void setRating(int value) {
    selectedRating = value;
    notifyListeners();
  }

  String get trimmedText => reviewController.text.trim();
  bool get canSubmit => selectedRating > 0 && trimmedText.isNotEmpty;

  void reset() {
    selectedRating = 0;
    reviewController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
}




class ReviewProvider extends ChangeNotifier {
  final Set<String> _reviewedProductIds = <String>{};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  bool isReviewed(String productId) => _reviewedProductIds.contains(productId);

  Future<void> loadReviewedProducts() async {
    final ids = await LocalStorage.getReviewedProductIds();
    _reviewedProductIds
      ..clear()
      ..addAll(ids);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> markReviewed(String productId) async {
    await LocalStorage.markProductReviewed(productId);
    _reviewedProductIds.add(productId);
    notifyListeners();
  }
}
