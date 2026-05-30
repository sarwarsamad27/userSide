import 'dart:io';
import 'package:flutter/material.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/view/dashboard/profile/order/successDialog.dart';

class ReviewFormProvider extends ChangeNotifier {
  int selectedRating = 0;
  final TextEditingController reviewController = TextEditingController();
  final List<File> images = [];
  File? video;
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  ReviewFormProvider() {
    reviewController.addListener(notifyListeners);
  }

  bool get isSubmitting => _isSubmitting;
  double get uploadProgress => _uploadProgress;

  void setSubmitting(bool v) {
    _isSubmitting = v;
    notifyListeners();
  }

  void setProgress(double v) {
    _uploadProgress = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  void setRating(int value) {
    selectedRating = value;
    notifyListeners();
  }

  void addImages(List<File> newImages) {
    final remaining = 5 - images.length;
    if (remaining > 0) {
      images.addAll(newImages.take(remaining));
      notifyListeners();
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  void setVideo(File? file) {
    video = file;
    notifyListeners();
  }

  String get trimmedText => reviewController.text.trim();

  // Enable when BOTH rating and text are filled (any order)
  bool get canSubmit =>
      selectedRating > 0 && trimmedText.isNotEmpty && !_isSubmitting;

  void reset() {
    selectedRating = 0;
    reviewController.clear();
    images.clear();
    video = null;
    _isSubmitting = false;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    reviewController.removeListener(notifyListeners);
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
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const SuccessDialog(),
    );
  }

  Future<void> markReviewed(String orderId) async {
    await LocalStorage.markOrderReviewed(orderId);
    _reviewedOrderIds.add(orderId);
    notifyListeners();
  }
}
