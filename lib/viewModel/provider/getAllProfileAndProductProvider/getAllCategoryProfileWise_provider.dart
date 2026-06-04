import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllCategoryProfileWise_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllCategoryProfileWise_repository.dart';

class GetAllCategoryProfileWiseProvider with ChangeNotifier {
  final GetAllCategoryProfileWiseRepository repo =
      GetAllCategoryProfileWiseRepository();

  bool isLoading = false;
  GetAllCategoryProfileWiseModel? data;
  String? _cachedProfileId;

  int selectedIndex = 0;

  void selectCategory(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchCategories(String profileId) async {
    // ✅ Fetch only if profileId changed or data is missing
    if (_cachedProfileId == profileId && data != null) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      data = await repo.getAllCategoryProfileWise(profileId);
      _cachedProfileId = profileId; // ✅ Cache successful ID
    } catch (e) {
      data = GetAllCategoryProfileWiseModel(message: e.toString());
      _cachedProfileId = null; // ❌ Don't cache errors
    }

    isLoading = false;
    notifyListeners();
  }
}
