import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllProfile_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllProfile_repository.dart';

class GetAllProfileProvider with ChangeNotifier {
  final GetAllProfileRepository repo = GetAllProfileRepository();

  bool isLoading = false;
  GetAllProfileModel? productData;

  Future<void> fetchProfiles() async {
    isLoading = true;
    notifyListeners();

    try {
      productData = await repo.getAllProfile();
    } catch (e) {
      productData = GetAllProfileModel(message: e.toString(), profiles: []);
    }

    isLoading = false;
    notifyListeners();
  }
}
