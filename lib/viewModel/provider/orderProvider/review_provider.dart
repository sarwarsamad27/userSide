import 'package:flutter/material.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/profile/order/successDialog.dart';

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
  final Set<String> _reviewedOrderIds = <String>{};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  bool isReviewed(String orderId) => _reviewedOrderIds.contains(orderId);

  Future<void> loadReviewedOrders() async {
    final ids = await LocalStorage.getReviewedOrderIds();
    _reviewedOrderIds
      ..clear()
      ..addAll(ids);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => const SuccessDialog(),
    );
  }

  Future<void> markReviewed(String orderId) async {
    await LocalStorage.markOrderReviewed(orderId);
    _reviewedOrderIds.add(orderId);
    notifyListeners();
  }
}
