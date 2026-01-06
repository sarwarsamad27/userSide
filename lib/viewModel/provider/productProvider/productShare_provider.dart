import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/productSharedModel.dart';
import 'package:user_side/viewModel/repository/productAndCategoryRepository/productShare_repository.dart';

class ProductShareProvider extends ChangeNotifier {
  final ProductShareRepository _repo = ProductShareRepository();

  bool _loading = false;
  bool get loading => _loading;

  Future<String?> fetchShareLink({
    required String productId,
    required String profileId,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      final ProductShareModel result =
          await _repo.getShareLink(productId: productId, profileId: profileId);

      return result.shareUrl;
    } catch (_) {
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
