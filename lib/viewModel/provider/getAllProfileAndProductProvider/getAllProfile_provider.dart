import 'package:flutter/material.dart';
import 'package:user_side/models/GetProfileAndProductModel/getAllProfile_model.dart';
import 'package:user_side/viewModel/repository/homeProfileAndProductRepository/getAllProfile_repository.dart';

class GetAllProfileProvider with ChangeNotifier {
  final GetAllProfileRepository repo = GetAllProfileRepository();

  bool isLoading = false;
  bool isFetchedOnce = false;
  int currentPage = 1;
  int limit = 10;
  GetAllProfileModel? productData;
  List<Profiles> filteredProfiles = [];

  Future<void> fetchProfiles({int page = 1}) async {
    if (isFetchedOnce) return; // ✅ pehli baar sirf
    isFetchedOnce = true;

    isLoading = true;
    notifyListeners();

    try {
      productData = await repo.getAllProfile(page: currentPage, limit: limit);
      filteredProfiles = productData?.profiles ?? []; // ✅ update karo
    } catch (e) {
      productData = GetAllProfileModel(message: e.toString(), profiles: []);
      filteredProfiles = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void applySearch(String query) {
    if (query.isEmpty) {
      filteredProfiles = productData?.profiles ?? [];
    } else {
      filteredProfiles = (productData?.profiles ?? [])
          .where((p) => p.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ✅ Refresh — isFetchedOnce reset karo + filteredProfiles update karo
  Future<void> refreshProfiles() async {
    isFetchedOnce = false; // ✅ yeh missing tha
    isLoading = true;
    notifyListeners();

    try {
      productData = await repo.getAllProfile(page: currentPage, limit: limit);
      filteredProfiles = productData?.profiles ?? []; // ✅ yeh bhi missing tha
    } catch (e) {
      productData = GetAllProfileModel(message: e.toString(), profiles: []);
      filteredProfiles = [];
    }

    isLoading = false;
    isFetchedOnce = true; // ✅ refresh ke baad wapas lock
    notifyListeners();
  }
}
