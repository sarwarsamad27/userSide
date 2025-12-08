import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllProfile_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllProfile_repository.dart';

class GetAllProfileProvider with ChangeNotifier {
  final GetAllProfileRepository repo = GetAllProfileRepository();

  bool isLoading = false;
  bool isFetchedOnce = false;   // 👈 NEW
  GetAllProfileModel? productData;
List<Profiles> filteredProfiles = [];

  Future<void> fetchProfiles() async {
    if (isFetchedOnce) return;  // 👈 ALREADY LOADED → DON'T CALL AGAIN
    isFetchedOnce = true;       // 👈 MARK AS LOADED

    isLoading = true;
    notifyListeners();

    try {
      
      productData = await repo.getAllProfile();
      filteredProfiles = productData?.profiles ?? [];
    } catch (e) {
      productData = GetAllProfileModel(message: e.toString(), profiles: []);
    }

    isLoading = false;
    notifyListeners();
  }

void applySearch(String query) {
  if (query.isEmpty) {
    filteredProfiles = productData?.profiles ?? [];
  } else {
    filteredProfiles = productData!.profiles!
        .where((p) =>
            p.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  notifyListeners();
}
  /// 👇 FOR REFRESHER
  Future<void> refreshProfiles() async {
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
