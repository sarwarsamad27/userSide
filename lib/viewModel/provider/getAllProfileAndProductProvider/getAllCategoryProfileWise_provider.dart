import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllCategoryProfileWise_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllCategoryProfileWise_repository.dart';

class GetAllCategoryProfileWiseProvider with ChangeNotifier {
  final GetAllCategoryProfileWiseRepository repo =
      GetAllCategoryProfileWiseRepository();

  bool isLoading = false;
  GetAllCategoryProfileWiseModel? data;

  int selectedIndex = 0;

  void selectCategory(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> fetchCategories(String profileId) async {
    isLoading = true;
    notifyListeners();

    try {
      data = await repo.getAllCategoryProfileWise(profileId);
    } catch (e) {
      data = GetAllCategoryProfileWiseModel(message: e.toString());
    }

    isLoading = false;
    notifyListeners();
  }
}
