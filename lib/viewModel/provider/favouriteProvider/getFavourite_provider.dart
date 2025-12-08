import 'package:flutter/material.dart';
import 'package:user_side/models/favouriteModel/getFavouriteList_model.dart';
import 'package:user_side/models/favouriteModel/deleteFavourite_model.dart';
import 'package:user_side/resources/local_storage.dart';
import 'package:user_side/viewModel/repository/favouriteRepository/getFavouriteList_repository.dart';
import 'package:user_side/viewModel/repository/favouriteRepository/deleteFavourite_repository.dart';

class FavouriteProvider extends ChangeNotifier {
  bool loading = false;
  FavouriteListModel? favouriteList;

  // Map to hold frontend-only quantity for each index
  Map<int, int> quantityMap = {};

  final GetFavouriteListRepository repo = GetFavouriteListRepository();
  final DeleteFavouriteRepository deleteRepo = DeleteFavouriteRepository();

  Future<void> deleteAllFavourites() async {
    try {
      String? userId = await LocalStorage.getUserId();

      if (favouriteList?.favourites == null) return;

      // Copy list length first to avoid index shift issues
      int len = favouriteList!.favourites!.length;

      for (int i = 0; i < len; i++) {
        final item = favouriteList!.favourites![0]; // always delete first item
        await deleteRepo.deleteFavourite(userId ?? '', item.product?.sId ?? '');

        favouriteList!.favourites!.removeAt(0);
      }

      quantityMap.clear();
      notifyListeners();
    } catch (e) {
      print("Delete all favourites error: $e");
    }
  }

  /// Fetch favourites
  Future<void> getFavourites() async {
    loading = true;
    notifyListeners();

    String? userId = await LocalStorage.getUserId();
    favouriteList = await repo.getFavouriteList(userId ?? '');

    // Initialize quantity map: default 1
    quantityMap = {};
    for (int i = 0; i < (favouriteList?.favourites?.length ?? 0); i++) {
      quantityMap[i] = 1;
    }

    loading = false;
    notifyListeners();
  }

  /// Increase quantity by 1
  void increaseQuantity(int index) {
    quantityMap[index] = (quantityMap[index] ?? 1) + 1;
    notifyListeners();
  }

  /// Decrease quantity by 1 (min 1)
  void decreaseQuantity(int index) {
    if ((quantityMap[index] ?? 1) > 1) {
      quantityMap[index] = (quantityMap[index] ?? 1) - 1;
      notifyListeners();
    }
  }

  /// Calculate total price with quantity
  double getTotal() {
    double total = 0;
    for (int i = 0; i < (favouriteList?.favourites?.length ?? 0); i++) {
      final item = favouriteList!.favourites![i];
      final qty = quantityMap[i] ?? 1;
      total += (item.product?.afterDiscountPrice?.toDouble() ?? 0) * qty;
    }
    return total;
  }

  /// Get quantity for a specific index
  int getQuantity(int index) {
    return quantityMap[index] ?? 1;
  }

  /// Delete favourite
  Future<bool> deleteFavourite(int index) async {
    try {
      final item = favouriteList!.favourites![index];
      String? userId = await LocalStorage.getUserId();

      final DeleteFavouriteProductModel res = await deleteRepo.deleteFavourite(
        userId ?? '',
        item.product?.sId ?? item.product?.sId ?? '',
      );

      if (res.success == true) {
        // Remove from local list
        favouriteList!.favourites!.removeAt(index);
        quantityMap.remove(index);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Delete favourite error: $e");
      return false;
    }
  }
}
